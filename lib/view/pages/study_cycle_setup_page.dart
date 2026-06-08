import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/study_cycle.dart';
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
  final _courseController = TextEditingController(
    text: 'Engenharia de Software',
  );
  final _goalController = TextEditingController();

  _StudyCycleType _selectedType = _StudyCycleType.university;
  int? _selectedPeriod = 6;
  int _selectedSeriesIndex = 0;
  List<AcademicSetupDisciplineDraft> _disciplines = const [];
  bool _isLoading = false;

  @override
  void dispose() {
    _courseController.dispose();
    _goalController.dispose();
    super.dispose();
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
                    goalController: _goalController,
                    selectedPeriod: _selectedPeriod,
                    selectedSeriesIndex: _selectedSeriesIndex,
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
                  Icon(
                    type.icon,
                    size: 17,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
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

class _CycleFields extends StatelessWidget {
  final _StudyCycleType type;
  final TextEditingController courseController;
  final TextEditingController goalController;
  final int? selectedPeriod;
  final int selectedSeriesIndex;
  final ValueChanged<int?> onPeriodChanged;
  final ValueChanged<int> onSeriesChanged;

  const _CycleFields({
    super.key,
    required this.type,
    required this.courseController,
    required this.goalController,
    required this.selectedPeriod,
    required this.selectedSeriesIndex,
    required this.onPeriodChanged,
    required this.onSeriesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: switch (type) {
        _StudyCycleType.university => [
          const SectionLabel(label: 'NOME DO CURSO'),
          const SizedBox(height: 8),
          ConfigTextField(
            controller: courseController,
            validator: (value) {
              if ((value?.trim() ?? '').isEmpty) {
                return 'Informe o nome do curso.';
              }
              return null;
            },
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
