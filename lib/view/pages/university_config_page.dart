import 'package:academic_manager_app/config/routes/app_routes.dart';
import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/academic_subject.dart';
import '../../repositories/subject_repository.dart';
import '../widgets/buttons/cancel_button.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/common/section_label.dart';
import '../widgets/inputs/config_text_field.dart';
import '../widgets/inputs/discipline_setup_list.dart';

class UniversityConfigPage extends StatefulWidget {
  const UniversityConfigPage({super.key});

  @override
  State<UniversityConfigPage> createState() => _UniversityConfigPageState();
}

class _UniversityConfigPageState extends State<UniversityConfigPage> {
  final formKey = GlobalKey<FormState>();
  final _disciplineSetupKey = GlobalKey<DisciplineSetupListState>();
  final _subjectRepository = SubjectRepository();

  final courseController = TextEditingController();

  int? selectedPeriod;
  bool isLoading = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    courseController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final disciplineNames =
          _disciplineSetupKey.currentState?.confirmedNames ?? [];

      if (disciplineNames.isNotEmpty) {
        await _subjectRepository.createSubjects(
          disciplineNames
              .map((name) => SubjectInput(name: name))
              .toList(),
        );
      }

      if (mounted) {
        AppRoutes.toHome(context);
      }
    } on SubjectRepositoryException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (_) {
      if (mounted) {
        _showMessage('Não foi possível salvar suas disciplinas. Tente novamente.');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indicador superior
                Container(
                  width: 56,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'ETAPA 2 DE 3',
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 20),

                // Cabeçalho
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),

                    const SizedBox(width: 18),

                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.headline2,
                          children: [
                            const TextSpan(text: 'Configure seus\n'),
                            TextSpan(
                              text: 'estudos',
                              style: AppTextStyles.headline2.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  'Personalize seu ambiente acadêmico para começar sua jornada de estudos.',
                  style: AppTextStyles.bodyRegular.copyWith(height: 1.5),
                ),

                const SizedBox(height: 32),

                // Card principal
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel(label: 'Curso'),

                      const SizedBox(height: 10),

                      ConfigTextField(controller: courseController),

                      const SizedBox(height: 24),

                      const SectionLabel(label: 'Período atual'),

                      const SizedBox(height: 10),

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
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                        ),
                        items: [
                          ...List.generate(12, (index) {
                            final period = index + 1;

                            return DropdownMenuItem(
                              value: period,
                              child: Text('$periodº período'),
                            );
                          }),
                          const DropdownMenuItem(
                            value: 0,
                            child: Text('Prefiro não informar'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedPeriod = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Selecione o período atual.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      const SectionLabel(label: 'Disciplinas'),

                      const SizedBox(height: 10),

                      DisciplineSetupList(key: _disciplineSetupKey),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                PrimaryButton(
                  label: 'Salvar e continuar',
                  onPressed: _onSave,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 12),

                const CancelButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
