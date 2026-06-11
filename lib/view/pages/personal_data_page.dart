import 'package:academic_manager_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_design_tokens.dart';
import '../../models/discipline.dart';
import '../../models/study_cycle.dart';
import '../../repositories/discipline_repository.dart';
import '../../repositories/study_cycle_repository.dart';
import '../../repositories/user_profile_repository.dart';
import '../widgets/common/app_surface.dart';
import '../widgets/common/empty_state_card.dart';
import '../widgets/common/metadata_chip.dart';

class PersonalDataPage extends StatefulWidget {
  const PersonalDataPage({super.key});

  @override
  State<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {
  final AuthService _authService = AuthService();
  final UserProfileRepository _userProfileRepository = UserProfileRepository();
  final StudyCycleRepository _studyCycleRepository = StudyCycleRepository();
  final DisciplineRepository _disciplineRepository = DisciplineRepository();

  late Future<_PersonalData> _personalDataFuture;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _personalDataFuture = _loadPersonalData();
  }

  Future<_PersonalData> _loadPersonalData() async {
    final authUser = _authService.currentUser;
    final profile = await _userProfileRepository.fetchCurrentUserProfile();
    final activeStudyCycleId = await _userProfileRepository
        .resolveActiveStudyCycleId();
    final studyCycles = await _studyCycleRepository.fetchStudyCycles();

    StudyCycle? activeStudyCycle;
    for (final cycle in studyCycles) {
      if (cycle.id == activeStudyCycleId) {
        activeStudyCycle = cycle;
        break;
      }
    }

    final disciplines = activeStudyCycleId == null
        ? const <Discipline>[]
        : await _disciplineRepository.fetchDisciplines(
            studyCycleId: activeStudyCycleId,
          );

    return _PersonalData(
      displayName: profile?.displayName ?? authUser?.displayName ?? 'Usuário',
      email: profile?.email ?? authUser?.email ?? 'E-mail não disponível',
      activeStudyCycle: activeStudyCycle,
      studyCycles: studyCycles,
      disciplines: disciplines,
    );
  }

  void _reload() {
    setState(() {
      _personalDataFuture = _loadPersonalData();
    });
  }

  Future<void> _editDisplayName(_PersonalData data) async {
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => _NameDialog(initialName: data.displayName),
    );

    if (result == null || !mounted) return;

    setState(() => _isSaving = true);
    try {
      await _authService.updateDisplayName(result);
      _showSuccess('Nome atualizado.');
      _reload();
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível atualizar seu nome.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _editActiveStudyCycle(_PersonalData data) async {
    final activeCycle = data.activeStudyCycle;
    if (activeCycle == null) {
      _showError('Nenhum ciclo ativo para editar.');
      return;
    }

    final input = await showDialog<StudyCycleInput>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => _StudyCycleEditDialog(cycle: activeCycle),
    );

    if (input == null || !mounted) return;

    setState(() => _isSaving = true);
    try {
      await _studyCycleRepository.updateStudyCycle(
        id: activeCycle.id,
        input: input,
      );
      _showSuccess('Dados acadêmicos atualizados.');
      _reload();
    } on StudyCycleRepositoryException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível atualizar seus dados acadêmicos.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<_PersonalData>(
          future: _personalDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: EmptyStateCard(
                    icon: Icons.error_outline_rounded,
                    message: 'Não foi possível carregar seus dados pessoais.',
                  ),
                ),
              );
            }

            final data = snapshot.data!;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PersonalDataHeader(isSaving: _isSaving),
                  const SizedBox(height: 18),
                  _AccountCard(
                    data: data,
                    onEditName: _isSaving ? null : () => _editDisplayName(data),
                  ),
                  const SizedBox(height: 18),
                  _AcademicCard(
                    data: data,
                    onEdit: _isSaving
                        ? null
                        : () => _editActiveStudyCycle(data),
                  ),
                  const SizedBox(height: 18),
                  _CyclesCard(cycles: data.studyCycles),
                  const SizedBox(height: 18),
                  _DisciplinesCard(disciplines: data.disciplines),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PersonalDataHeader extends StatelessWidget {
  final bool isSaving;

  const _PersonalDataHeader({required this.isSaving});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Tooltip(
          message: 'Voltar',
          child: Material(
            color: AppColors.primarySoft,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: isSaving ? null : () => Navigator.of(context).maybePop(),
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
        const Expanded(
          child: Text(
            'Dados pessoais',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 28,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  final _PersonalData data;
  final VoidCallback? onEditName;

  const _AccountCard({required this.data, required this.onEditName});

  @override
  Widget build(BuildContext context) {
    return AppSurface.card(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const ShapeDecoration(
              gradient: AppGradients.brand,
              shape: OvalBorder(),
              shadows: AppShadows.subtle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.background,
              size: 42,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  data.email,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 13,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    MetadataChip(
                      icon: Icons.lock_outline,
                      label: 'E-mail somente leitura',
                      foregroundColor: AppColors.textMedium,
                      backgroundColor: AppColors.surfaceAlt,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Editar nome',
            onPressed: onEditName,
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _AcademicCard extends StatelessWidget {
  final _PersonalData data;
  final VoidCallback? onEdit;

  const _AcademicCard({required this.data, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final activeCycle = data.activeStudyCycle;

    return AppSurface.card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Ciclo atual',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Editar ciclo atual',
                onPressed: activeCycle == null ? null : onEdit,
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (activeCycle == null)
            const Text(
              'Nenhum ciclo acadêmico configurado.',
              style: TextStyle(
                color: AppColors.textMedium,
                fontSize: 14,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
              ),
            )
          else ...[
            Text(
              _cycleTitle(activeCycle),
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                MetadataChip(
                  icon: Icons.school_outlined,
                  label: _cycleLabel(activeCycle),
                ),
                MetadataChip(
                  icon: Icons.menu_book_outlined,
                  label:
                      '${data.disciplines.length} ${data.disciplines.length == 1 ? 'disciplina' : 'disciplinas'}',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CyclesCard extends StatelessWidget {
  final List<StudyCycle> cycles;

  const _CyclesCard({required this.cycles});

  @override
  Widget build(BuildContext context) {
    return AppSurface.card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ciclos cadastrados',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (cycles.isEmpty)
            const Text(
              'Nenhum ciclo cadastrado.',
              style: TextStyle(
                color: AppColors.textMedium,
                fontSize: 14,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
              ),
            )
          else
            ...cycles.map(
              (cycle) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CycleRow(cycle: cycle),
              ),
            ),
        ],
      ),
    );
  }
}

class _CycleRow extends StatelessWidget {
  final StudyCycle cycle;

  const _CycleRow({required this.cycle});

  @override
  Widget build(BuildContext context) {
    return AppSurface.soft(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.school_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _cycleTitle(cycle),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _cycleLabel(cycle),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 12,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DisciplinesCard extends StatelessWidget {
  final List<Discipline> disciplines;

  const _DisciplinesCard({required this.disciplines});

  @override
  Widget build(BuildContext context) {
    return AppSurface.card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Disciplinas do ciclo atual',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (disciplines.isEmpty)
            const Text(
              'Nenhuma disciplina vinculada ao ciclo atual.',
              style: TextStyle(
                color: AppColors.textMedium,
                fontSize: 14,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: disciplines.map((discipline) {
                final color = Color(discipline.colorValue);
                return MetadataChip(
                  icon: Icons.menu_book_outlined,
                  label: discipline.name,
                  foregroundColor: color,
                  backgroundColor: color.withValues(alpha: 0.10),
                  maxWidth: 220,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _NameDialog extends StatefulWidget {
  final String initialName;

  const _NameDialog({required this.initialName});

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar nome'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(labelText: 'Nome'),
          validator: (value) {
            if ((value?.trim() ?? '').isEmpty) return 'Informe seu nome.';
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Salvar')),
      ],
    );
  }
}

class _StudyCycleEditDialog extends StatefulWidget {
  final StudyCycle cycle;

  const _StudyCycleEditDialog({required this.cycle});

  @override
  State<_StudyCycleEditDialog> createState() => _StudyCycleEditDialogState();
}

class _StudyCycleEditDialogState extends State<_StudyCycleEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _courseController;
  late final TextEditingController _goalController;
  late int _period;
  late int _schoolYear;

  @override
  void initState() {
    super.initState();
    _courseController = TextEditingController(
      text: widget.cycle.courseName ?? '',
    );
    _goalController = TextEditingController(text: widget.cycle.goal ?? '');
    _period = widget.cycle.period ?? 0;
    _schoolYear = widget.cycle.schoolYear ?? 1;
  }

  @override
  void dispose() {
    _courseController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final input = switch (widget.cycle.type) {
      StudyCycleType.university => StudyCycleInput(
        type: StudyCycleType.university,
        courseName: _courseController.text,
        period: _period == 0 ? null : _period,
      ),
      StudyCycleType.highSchool => StudyCycleInput(
        type: StudyCycleType.highSchool,
        schoolYear: _schoolYear,
      ),
      StudyCycleType.independent => StudyCycleInput(
        type: StudyCycleType.independent,
        goal: _goalController.text,
      ),
    };

    Navigator.of(context).pop(input);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar ciclo atual'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: switch (widget.cycle.type) {
            StudyCycleType.university => [
              TextFormField(
                controller: _courseController,
                decoration: const InputDecoration(labelText: 'Curso'),
                validator: (value) {
                  if ((value?.trim() ?? '').isEmpty) {
                    return 'Informe o curso.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _period,
                decoration: const InputDecoration(labelText: 'Período'),
                items: [
                  const DropdownMenuItem(
                    value: 0,
                    child: Text('Prefiro não informar'),
                  ),
                  ...List.generate(12, (index) {
                    final period = index + 1;
                    return DropdownMenuItem(
                      value: period,
                      child: Text('$periodº período'),
                    );
                  }),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _period = value);
                },
              ),
            ],
            StudyCycleType.highSchool => [
              DropdownButtonFormField<int>(
                initialValue: _schoolYear,
                decoration: const InputDecoration(labelText: 'Ano letivo'),
                items: List.generate(3, (index) {
                  final year = index + 1;
                  return DropdownMenuItem(
                    value: year,
                    child: Text('$yearº ano'),
                  );
                }),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _schoolYear = value);
                },
              ),
            ],
            StudyCycleType.independent => [
              TextFormField(
                controller: _goalController,
                decoration: const InputDecoration(labelText: 'Meta'),
                validator: (value) {
                  if ((value?.trim() ?? '').isEmpty) {
                    return 'Informe sua meta.';
                  }
                  return null;
                },
              ),
            ],
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Salvar')),
      ],
    );
  }
}

class _PersonalData {
  final String displayName;
  final String email;
  final StudyCycle? activeStudyCycle;
  final List<StudyCycle> studyCycles;
  final List<Discipline> disciplines;

  const _PersonalData({
    required this.displayName,
    required this.email,
    required this.activeStudyCycle,
    required this.studyCycles,
    required this.disciplines,
  });
}

String _cycleTitle(StudyCycle cycle) {
  return switch (cycle.type) {
    StudyCycleType.university => cycle.courseName ?? 'Curso não informado',
    StudyCycleType.highSchool => 'Ensino médio',
    StudyCycleType.independent => cycle.goal ?? 'Meta não informada',
  };
}

String _cycleLabel(StudyCycle cycle) {
  return switch (cycle.type) {
    StudyCycleType.university =>
      cycle.period == null
          ? 'Período não informado'
          : '${cycle.period}º período',
    StudyCycleType.highSchool =>
      cycle.schoolYear == null
          ? 'Ano letivo não informado'
          : '${cycle.schoolYear}º ano',
    StudyCycleType.independent => 'Estudo independente',
  };
}
