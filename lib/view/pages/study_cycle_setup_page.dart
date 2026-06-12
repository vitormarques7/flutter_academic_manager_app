import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/study_cycle.dart';
import '../../repositories/study_cycle_repository.dart';
import '../../repositories/user_profile_repository.dart';
import '../../services/setup/academic_setup_service.dart';
import '../widgets/buttons/cancel_button.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/common/section_label.dart';
import '../widgets/inputs/config_text_field.dart';
import '../widgets/inputs/discipline_setup_list.dart';
import '../widgets/selectors/series_selector.dart';

class StudyCycleSetupPage extends StatefulWidget {
  const StudyCycleSetupPage({super.key});

  @override
  State<StudyCycleSetupPage> createState() => _StudyCycleSetupPageState();
}

class _StudyCycleSetupPageState extends State<StudyCycleSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _setupService = AcademicSetupService();
  final _studyCycleRepository = StudyCycleRepository();
  final _userProfileRepository = UserProfileRepository();
  final _courseController = TextEditingController();
  final _goalController = TextEditingController();

  _StudyCycleType _selectedType = _StudyCycleType.university;
  int? _selectedPeriod;
  int _selectedSeriesIndex = 0;
  List<String> _courseOptions = const [];
  String? _selectedCourseName;
  List<AcademicSetupDisciplineDraft> _disciplines = const [];
  bool _isLoading = false;
  bool _isLoadingCourses = false;
  bool _isSavingCourse = false;

  @override
  void initState() {
    super.initState();
    _loadCourseOptions();
  }

  @override
  void dispose() {
    _courseController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _loadCourseOptions() async {
    if (mounted) setState(() => _isLoadingCourses = true);

    try {
      final activeStudyCycleId = await _userProfileRepository
          .resolveActiveStudyCycleId();
      final studyCycles = await _studyCycleRepository.fetchStudyCycles();
      final courseOptions = _courseNamesFromStudyCycles(studyCycles);
      final preferredCourseName =
          _preferredCourseName(
            studyCycles: studyCycles,
            activeStudyCycleId: activeStudyCycleId,
          ) ??
          (courseOptions.isEmpty ? null : courseOptions.first);

      if (!mounted) return;

      setState(() {
        _courseOptions = courseOptions;
        _selectedCourseName = preferredCourseName;
        if (preferredCourseName != null &&
            _courseController.text.trim().isEmpty) {
          _courseController.text = preferredCourseName;
        }
      });
    } catch (_) {
      // The field remains editable even when previous courses cannot load.
    } finally {
      if (mounted) {
        setState(() => _isLoadingCourses = false);
      }
    }
  }

  List<String> _courseNamesFromStudyCycles(List<StudyCycle> studyCycles) {
    final courseNamesByKey = <String, String>{};

    for (final studyCycle in studyCycles) {
      final courseName = studyCycle.courseName;
      if (studyCycle.type != StudyCycleType.university || courseName == null) {
        continue;
      }

      courseNamesByKey.putIfAbsent(
        _courseNameKey(courseName),
        () => courseName,
      );
    }

    return courseNamesByKey.values.toList();
  }

  String? _preferredCourseName({
    required List<StudyCycle> studyCycles,
    required String? activeStudyCycleId,
  }) {
    for (final studyCycle in studyCycles) {
      if (studyCycle.id == activeStudyCycleId &&
          studyCycle.type == StudyCycleType.university &&
          studyCycle.courseName != null) {
        return studyCycle.courseName;
      }
    }

    for (final studyCycle in studyCycles) {
      if (studyCycle.type == StudyCycleType.university &&
          studyCycle.courseName != null) {
        return studyCycle.courseName;
      }
    }

    return null;
  }

  void _selectCourse(String? courseName) {
    setState(() {
      _selectedCourseName = courseName;
      _courseController.text = courseName ?? '';
    });
  }

  Future<void> _addCourse() async {
    final courseName = await _showCourseNameDialog(
      title: 'Novo curso',
      confirmLabel: 'Adicionar',
    );
    if (courseName == null) return;

    final existingCourseName = _findExistingCourseName(courseName);
    final selectedCourseName = existingCourseName ?? courseName;

    setState(() {
      if (existingCourseName == null) {
        _courseOptions = [..._courseOptions, courseName];
      }
      _selectedCourseName = selectedCourseName;
      _courseController.text = selectedCourseName;
    });
  }

  Future<void> _editSelectedCourse() async {
    final currentCourseName = _selectedCourseName ?? _courseController.text;
    final normalizedCurrentCourseName = _normalizeCourseName(currentCourseName);

    if (normalizedCurrentCourseName == null) {
      await _addCourse();
      return;
    }

    final newCourseName = await _showCourseNameDialog(
      title: 'Editar curso',
      confirmLabel: 'Salvar',
      initialValue: normalizedCurrentCourseName,
    );
    if (newCourseName == null) return;

    if (_courseNameKey(newCourseName) ==
        _courseNameKey(normalizedCurrentCourseName)) {
      setState(() {
        _selectedCourseName = normalizedCurrentCourseName;
        _courseController.text = normalizedCurrentCourseName;
      });
      return;
    }

    setState(() => _isSavingCourse = true);
    try {
      await _studyCycleRepository.renameUniversityCourse(
        currentName: normalizedCurrentCourseName,
        newName: newCourseName,
      );

      if (!mounted) return;

      setState(() {
        _courseOptions = _renamedCourseOptions(
          currentName: normalizedCurrentCourseName,
          newName: newCourseName,
        );
        _selectedCourseName = newCourseName;
        _courseController.text = newCourseName;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nome do curso atualizado.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on StudyCycleRepositoryException catch (error) {
      if (mounted) _showError(error.message);
    } catch (_) {
      if (mounted) _showError('Não foi possível atualizar o curso.');
    } finally {
      if (mounted) setState(() => _isSavingCourse = false);
    }
  }

  List<String> _renamedCourseOptions({
    required String currentName,
    required String newName,
  }) {
    final nextCourseOptions = <String>[];
    final currentKey = _courseNameKey(currentName);
    final newKey = _courseNameKey(newName);

    for (final courseOption in _courseOptions) {
      final optionKey = _courseNameKey(courseOption);
      if (optionKey == currentKey || optionKey == newKey) continue;
      nextCourseOptions.add(courseOption);
    }

    return [newName, ...nextCourseOptions];
  }

  String? _findExistingCourseName(String courseName) {
    final courseNameKey = _courseNameKey(courseName);

    for (final courseOption in _courseOptions) {
      if (_courseNameKey(courseOption) == courseNameKey) {
        return courseOption;
      }
    }

    return null;
  }

  Future<String?> _showCourseNameDialog({
    required String title,
    required String confirmLabel,
    String initialValue = '',
  }) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: initialValue);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Nome do curso'),
              validator: (value) {
                if (_normalizeCourseName(value) == null) {
                  return 'Informe o nome do curso.';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(
                  dialogContext,
                ).pop(_normalizeCourseName(controller.text));
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(
                  dialogContext,
                ).pop(_normalizeCourseName(controller.text));
              },
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  String? _normalizeCourseName(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  String _courseNameKey(String value) {
    return value.trim().toLowerCase();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _setupService.saveSetup(
        studyCycle: _buildStudyCycleInput(),
        disciplines: _disciplines,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedType.createdLabel} criado.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } on AcademicSetupException catch (error) {
      if (mounted) _showError(error.message);
    } catch (_) {
      if (mounted) _showError('Não foi possível salvar sua configuração.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  StudyCycleInput _buildStudyCycleInput() {
    return switch (_selectedType) {
      _StudyCycleType.university => StudyCycleInput(
        type: StudyCycleType.university,
        courseName: _courseController.text,
        period: _selectedPeriod,
      ),
      _StudyCycleType.highSchool => StudyCycleInput(
        type: StudyCycleType.highSchool,
        schoolYear: _selectedSeriesIndex + 1,
      ),
      _StudyCycleType.independent => StudyCycleInput(
        type: StudyCycleType.independent,
        goal: _goalController.text,
      ),
    };
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(28, 34, 28, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SetupHeader(type: _selectedType),
                const SizedBox(height: 24),
                _CycleTypeSelector(
                  selectedType: _selectedType,
                  onChanged: (type) => setState(() => _selectedType = type),
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _CycleFields(
                    key: ValueKey(_selectedType),
                    type: _selectedType,
                    courseController: _courseController,
                    courseOptions: _courseOptions,
                    selectedCourseName: _selectedCourseName,
                    isLoadingCourses: _isLoadingCourses,
                    isSavingCourse: _isSavingCourse,
                    goalController: _goalController,
                    selectedPeriod: _selectedPeriod,
                    selectedSeriesIndex: _selectedSeriesIndex,
                    onCourseChanged: _selectCourse,
                    onEditCourse: _editSelectedCourse,
                    onAddCourse: _addCourse,
                    onPeriodChanged: (value) {
                      setState(() => _selectedPeriod = value);
                    },
                    onSeriesChanged: (index) {
                      setState(() => _selectedSeriesIndex = index);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const SectionLabel(label: 'DISCIPLINAS E HORÁRIOS'),
                const SizedBox(height: 8),
                DisciplineSetupList(
                  onChanged: (disciplines) => _disciplines = disciplines,
                ),
                const SizedBox(height: 44),
                PrimaryButton(
                  label: _selectedType.saveLabel,
                  onPressed: _onSave,
                  isLoading: _isLoading,
                  textStyle: AppTextStyles.button.copyWith(
                    color: AppColors.textOnPrimary,
                    fontSize: 20,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 14),
                const CancelButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupHeader extends StatelessWidget {
  final _StudyCycleType type;

  const _SetupHeader({required this.type});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tooltip(
          message: 'Voltar',
          child: Material(
            color: const Color(0xFFEDE8FB),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).maybePop(),
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  Icons.chevron_left,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type.title,
                style: AppTextStyles.headline3.copyWith(
                  fontSize: 26,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                type.subtitle,
                style: AppTextStyles.bodyRegular.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CycleTypeSelector extends StatelessWidget {
  final _StudyCycleType selectedType;
  final ValueChanged<_StudyCycleType> onChanged;

  const _CycleTypeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _StudyCycleType.values.map((type) {
        final isSelected = type == selectedType;

        return Material(
          color: isSelected ? AppColors.primary : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onChanged(type),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CycleTypeIcon(type: type, isSelected: isSelected),
                  const SizedBox(width: 7),
                  Text(
                    type.chipLabel,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CycleTypeIcon extends StatelessWidget {
  final _StudyCycleType type;
  final bool isSelected;

  const _CycleTypeIcon({required this.type, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    if (type == _StudyCycleType.highSchool) {
      return Image.asset(
        'lib/view/assets/highschool_icon.png',
        width: 18,
        height: 18,
        fit: BoxFit.contain,
        color: isSelected ? Colors.white : null,
        colorBlendMode: isSelected ? BlendMode.srcIn : null,
      );
    }

    return Icon(
      type.icon,
      size: 17,
      color: isSelected ? Colors.white : AppColors.primary,
    );
  }
}

class _CycleFields extends StatelessWidget {
  final _StudyCycleType type;
  final TextEditingController courseController;
  final List<String> courseOptions;
  final String? selectedCourseName;
  final bool isLoadingCourses;
  final bool isSavingCourse;
  final TextEditingController goalController;
  final int? selectedPeriod;
  final int selectedSeriesIndex;
  final ValueChanged<String?> onCourseChanged;
  final VoidCallback onEditCourse;
  final VoidCallback onAddCourse;
  final ValueChanged<int?> onPeriodChanged;
  final ValueChanged<int> onSeriesChanged;

  const _CycleFields({
    super.key,
    required this.type,
    required this.courseController,
    required this.courseOptions,
    required this.selectedCourseName,
    required this.isLoadingCourses,
    required this.isSavingCourse,
    required this.goalController,
    required this.selectedPeriod,
    required this.selectedSeriesIndex,
    required this.onCourseChanged,
    required this.onEditCourse,
    required this.onAddCourse,
    required this.onPeriodChanged,
    required this.onSeriesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: switch (type) {
        _StudyCycleType.university => [
          const SectionLabel(label: 'CURSO'),
          const SizedBox(height: 8),
          _CoursePicker(
            controller: courseController,
            courseOptions: courseOptions,
            selectedCourseName: selectedCourseName,
            isLoadingCourses: isLoadingCourses,
            isSavingCourse: isSavingCourse,
            onCourseChanged: onCourseChanged,
            onEditCourse: onEditCourse,
            onAddCourse: onAddCourse,
          ),
          const SizedBox(height: 24),
          const SectionLabel(label: 'PERÍODO'),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: selectedPeriod,
            menuMaxHeight: 280,
            hint: Text(
              'Selecione o período',
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.primary,
              size: 28,
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 18,
              ),
            ),
            items: List.generate(12, (index) {
              final period = index + 1;
              return DropdownMenuItem(
                value: period,
                child: Text('$periodº período'),
              );
            }),
            onChanged: onPeriodChanged,
            validator: (value) {
              if (value == null) return 'Selecione o período.';
              return null;
            },
          ),
        ],
        _StudyCycleType.highSchool => [
          const SectionLabel(label: 'SÉRIE'),
          const SizedBox(height: 8),
          SeriesSelector(
            selectedIndex: selectedSeriesIndex,
            onChanged: onSeriesChanged,
          ),
        ],
        _StudyCycleType.independent => [
          const SectionLabel(label: 'OBJETIVO'),
          const SizedBox(height: 8),
          ConfigTextField(
            controller: goalController,
            validator: (value) {
              if ((value?.trim() ?? '').isEmpty) {
                return 'Informe seu objetivo.';
              }
              return null;
            },
          ),
        ],
      },
    );
  }
}

class _CoursePicker extends StatelessWidget {
  final TextEditingController controller;
  final List<String> courseOptions;
  final String? selectedCourseName;
  final bool isLoadingCourses;
  final bool isSavingCourse;
  final ValueChanged<String?> onCourseChanged;
  final VoidCallback onEditCourse;
  final VoidCallback onAddCourse;

  const _CoursePicker({
    required this.controller,
    required this.courseOptions,
    required this.selectedCourseName,
    required this.isLoadingCourses,
    required this.isSavingCourse,
    required this.onCourseChanged,
    required this.onEditCourse,
    required this.onAddCourse,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingCourses) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.defaultFieldBackground,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: AppColors.defaultFieldBorder, width: 1.5),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Carregando cursos...',
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    if (courseOptions.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConfigTextField(
            controller: controller,
            validator: _validateCourseName,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: _CourseActionButton(
              icon: Icons.add,
              label: 'Novo curso',
              onPressed: isSavingCourse ? null : onAddCourse,
            ),
          ),
        ],
      );
    }

    final hasSelectedOption = courseOptions.contains(selectedCourseName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey(
            'course-${selectedCourseName ?? 'none'}-${courseOptions.length}',
          ),
          initialValue: hasSelectedOption ? selectedCourseName : null,
          menuMaxHeight: 280,
          hint: Text(
            'Selecione o curso',
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.primary,
            size: 28,
          ),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          ),
          items: courseOptions.map((courseName) {
            return DropdownMenuItem(
              value: courseName,
              child: Text(
                courseName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: isSavingCourse ? null : onCourseChanged,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Selecione ou adicione um curso.';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _CourseActionButton(
              icon: Icons.edit_outlined,
              label: 'Editar',
              onPressed: isSavingCourse ? null : onEditCourse,
            ),
            _CourseActionButton(
              icon: Icons.add,
              label: 'Novo curso',
              onPressed: isSavingCourse ? null : onAddCourse,
            ),
          ],
        ),
      ],
    );
  }

  String? _validateCourseName(String? value) {
    if ((value?.trim() ?? '').isEmpty) {
      return 'Informe o nome do curso.';
    }
    return null;
  }
}

class _CourseActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _CourseActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        side: const BorderSide(color: AppColors.primary, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(
          fontSize: 14,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

enum _StudyCycleType {
  university,
  highSchool,
  independent;

  String get title {
    return switch (this) {
      _StudyCycleType.university => 'Novo Período',
      _StudyCycleType.highSchool => 'Novo Ano Letivo',
      _StudyCycleType.independent => 'Novo Foco',
    };
  }

  String get subtitle {
    return switch (this) {
      _StudyCycleType.university => 'Cadastre o próximo período e sua grade.',
      _StudyCycleType.highSchool => 'Cadastre o ano letivo e suas matérias.',
      _StudyCycleType.independent => 'Cadastre um foco e seu plano de estudo.',
    };
  }

  String get chipLabel {
    return switch (this) {
      _StudyCycleType.university => 'Faculdade',
      _StudyCycleType.highSchool => 'Ensino médio',
      _StudyCycleType.independent => 'Independente',
    };
  }

  String get createdLabel {
    return switch (this) {
      _StudyCycleType.university => 'Período',
      _StudyCycleType.highSchool => 'Ano letivo',
      _StudyCycleType.independent => 'Foco',
    };
  }

  String get saveLabel {
    return switch (this) {
      _StudyCycleType.university => 'Salvar período',
      _StudyCycleType.highSchool => 'Salvar ano letivo',
      _StudyCycleType.independent => 'Salvar foco',
    };
  }

  IconData get icon {
    return switch (this) {
      _StudyCycleType.university => Icons.school_outlined,
      _StudyCycleType.highSchool => Icons.history_edu_outlined,
      _StudyCycleType.independent => Icons.flag_outlined,
    };
  }
}
