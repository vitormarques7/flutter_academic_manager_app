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

  Future<void> _manageActiveStudyCycle(_PersonalData data) async {
    final activeCycle = data.activeStudyCycle;
    if (activeCycle == null) {
      _showError('Nenhum ciclo ativo para editar.');
      return;
    }

    final result = await showModalBottomSheet<_StudyCycleManagementResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StudyCycleManagementSheet(data: data),
    );

    if (result == null || !mounted) return;

    switch (result.type) {
      case _StudyCycleManagementResultType.update:
        await _updateActiveStudyCycle(
          activeCycle: activeCycle,
          input: result.input!,
        );
      case _StudyCycleManagementResultType.activate:
        await _activateStudyCycle(result.studyCycleId!);
    }
  }

  Future<void> _updateActiveStudyCycle({
    required StudyCycle activeCycle,
    required StudyCycleInput input,
  }) async {
    setState(() => _isSaving = true);
    try {
      await _studyCycleRepository.updateStudyCycle(
        id: activeCycle.id,
        input: input,
      );
      if (!mounted) return;
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

  Future<void> _activateStudyCycle(String studyCycleId) async {
    setState(() => _isSaving = true);
    try {
      await _userProfileRepository.setActiveStudyCycleId(studyCycleId);
      if (!mounted) return;
      _showSuccess('Ciclo atual alterado.');
      _reload();
    } on UserProfileRepositoryException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Não foi possível alterar o ciclo atual.');
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
                        : () => _manageActiveStudyCycle(data),
                  ),
                  const SizedBox(height: 18),
                  _CyclesCard(
                    cycles: data.studyCycles,
                    activeCycleId: data.activeStudyCycle?.id,
                    onActivate: _isSaving ? null : _activateStudyCycle,
                  ),
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
              TextButton.icon(
                onPressed: activeCycle == null ? null : onEdit,
                icon: const Icon(Icons.tune_rounded, size: 19),
                label: const Text('Gerenciar'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800,
                  ),
                ),
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
  final String? activeCycleId;
  final ValueChanged<String>? onActivate;

  const _CyclesCard({
    required this.cycles,
    required this.activeCycleId,
    required this.onActivate,
  });

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
                child: _CycleRow(
                  cycle: cycle,
                  isCurrent: cycle.id == activeCycleId,
                  onActivate: cycle.id == activeCycleId || onActivate == null
                      ? null
                      : () => onActivate!(cycle.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CycleRow extends StatelessWidget {
  final StudyCycle cycle;
  final bool isCurrent;
  final VoidCallback? onActivate;

  const _CycleRow({
    required this.cycle,
    required this.isCurrent,
    required this.onActivate,
  });

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
            child: Icon(_cycleIcon(cycle), color: AppColors.primary, size: 22),
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
          const SizedBox(width: 8),
          if (isCurrent)
            const _CurrentCycleBadge()
          else
            TextButton.icon(
              onPressed: onActivate,
              icon: const Icon(Icons.check_circle_outline_rounded, size: 17),
              label: const Text('Ativar'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CurrentCycleBadge extends StatelessWidget {
  const _CurrentCycleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: const Text(
        'Atual',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w900,
          height: 1,
        ),
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

enum _StudyCycleManagementMode { activate, edit }

enum _StudyCycleManagementResultType { update, activate }

class _StudyCycleManagementResult {
  final _StudyCycleManagementResultType type;
  final String? studyCycleId;
  final StudyCycleInput? input;

  const _StudyCycleManagementResult.activate(this.studyCycleId)
    : type = _StudyCycleManagementResultType.activate,
      input = null;

  const _StudyCycleManagementResult.update(this.input)
    : type = _StudyCycleManagementResultType.update,
      studyCycleId = null;
}

class _StudyCycleManagementSheet extends StatefulWidget {
  final _PersonalData data;

  const _StudyCycleManagementSheet({required this.data});

  @override
  State<_StudyCycleManagementSheet> createState() =>
      _StudyCycleManagementSheetState();
}

class _StudyCycleManagementSheetState
    extends State<_StudyCycleManagementSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _courseController;
  late final TextEditingController _goalController;
  late _StudyCycleManagementMode _mode;
  late int _period;
  late int _schoolYear;

  StudyCycle get _activeCycle => widget.data.activeStudyCycle!;

  bool get _hasPreviousCycles {
    return widget.data.studyCycles.any((cycle) => cycle.id != _activeCycle.id);
  }

  @override
  void initState() {
    super.initState();
    _mode = _hasPreviousCycles
        ? _StudyCycleManagementMode.activate
        : _StudyCycleManagementMode.edit;
    _courseController = TextEditingController(
      text: _activeCycle.courseName ?? '',
    );
    _goalController = TextEditingController(text: _activeCycle.goal ?? '');
    _period = _activeCycle.period ?? 0;
    _schoolYear = _activeCycle.schoolYear ?? 1;
  }

  @override
  void dispose() {
    _courseController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final input = switch (_activeCycle.type) {
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

    Navigator.of(context).pop(_StudyCycleManagementResult.update(input));
  }

  void _activateCycle(String studyCycleId) {
    Navigator.of(
      context,
    ).pop(_StudyCycleManagementResult.activate(studyCycleId));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottomInset),
        child: AppSurface.card(
          constraints: BoxConstraints(maxHeight: maxHeight),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          borderRadius: AppRadius.xl,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Gerenciar ciclo atual',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 22,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Fechar',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _CycleManagementModeSwitch(
                  mode: _mode,
                  canActivate: _hasPreviousCycles,
                  onChanged: (mode) => setState(() => _mode = mode),
                ),
                const SizedBox(height: 16),
                if (_mode == _StudyCycleManagementMode.activate)
                  _CycleActivationList(
                    cycles: widget.data.studyCycles,
                    activeCycleId: _activeCycle.id,
                    onActivate: _activateCycle,
                  )
                else
                  _buildEditForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...switch (_activeCycle.type) {
            StudyCycleType.university => [
              TextFormField(
                controller: _courseController,
                textInputAction: TextInputAction.next,
                decoration: _sheetInputDecoration(
                  label: 'Curso',
                  icon: Icons.school_outlined,
                ),
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
                decoration: _sheetInputDecoration(
                  label: 'Período',
                  icon: Icons.layers_outlined,
                ),
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
                decoration: _sheetInputDecoration(
                  label: 'Ano letivo',
                  icon: Icons.auto_stories_outlined,
                ),
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
                textInputAction: TextInputAction.done,
                decoration: _sheetInputDecoration(
                  label: 'Meta',
                  icon: Icons.flag_outlined,
                ),
                validator: (value) {
                  if ((value?.trim() ?? '').isEmpty) {
                    return 'Informe sua meta.';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          },
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CycleManagementModeSwitch extends StatelessWidget {
  final _StudyCycleManagementMode mode;
  final bool canActivate;
  final ValueChanged<_StudyCycleManagementMode> onChanged;

  const _CycleManagementModeSwitch({
    required this.mode,
    required this.canActivate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CycleManagementModeButton(
            icon: Icons.swap_horiz_rounded,
            label: 'Trocar',
            selected: mode == _StudyCycleManagementMode.activate,
            enabled: canActivate,
            onPressed: () => onChanged(_StudyCycleManagementMode.activate),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CycleManagementModeButton(
            icon: Icons.edit_outlined,
            label: 'Editar',
            selected: mode == _StudyCycleManagementMode.edit,
            onPressed: () => onChanged(_StudyCycleManagementMode.edit),
          ),
        ),
      ],
    );
  }
}

class _CycleManagementModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;

  const _CycleManagementModeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final style = selected
        ? FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            padding: const EdgeInsets.symmetric(vertical: 12),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.outlineStrong),
            padding: const EdgeInsets.symmetric(vertical: 12),
          );

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );

    if (selected) {
      return FilledButton(
        onPressed: enabled ? onPressed : null,
        style: style,
        child: child,
      );
    }

    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      style: style,
      child: child,
    );
  }
}

class _CycleActivationList extends StatelessWidget {
  final List<StudyCycle> cycles;
  final String activeCycleId;
  final ValueChanged<String> onActivate;

  const _CycleActivationList({
    required this.cycles,
    required this.activeCycleId,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: cycles.map((cycle) {
        final isCurrent = cycle.id == activeCycleId;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _CycleActivationRow(
            cycle: cycle,
            isCurrent: isCurrent,
            onActivate: isCurrent ? null : () => onActivate(cycle.id),
          ),
        );
      }).toList(),
    );
  }
}

class _CycleActivationRow extends StatelessWidget {
  final StudyCycle cycle;
  final bool isCurrent;
  final VoidCallback? onActivate;

  const _CycleActivationRow({
    required this.cycle,
    required this.isCurrent,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface.soft(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(_cycleIcon(cycle), color: AppColors.primary, size: 22),
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
          const SizedBox(width: 8),
          if (isCurrent)
            const _CurrentCycleBadge()
          else
            FilledButton.icon(
              onPressed: onActivate,
              icon: const Icon(Icons.check_circle_outline_rounded, size: 17),
              label: const Text('Ativar'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

InputDecoration _sheetInputDecoration({
  required String label,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: AppColors.primary),
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.outlineStrong),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );
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

IconData _cycleIcon(StudyCycle cycle) {
  return switch (cycle.type) {
    StudyCycleType.university => Icons.school_outlined,
    StudyCycleType.highSchool => Icons.auto_stories_outlined,
    StudyCycleType.independent => Icons.flag_outlined,
  };
}
