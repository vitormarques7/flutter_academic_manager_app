import 'package:academic_manager_app/config/routes/app_routes.dart';
import 'package:flutter/material.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_theme_colors.dart';
import '../../models/study_cycle.dart';
import '../../services/setup/academic_setup_service.dart';
import '../widgets/buttons/cancel_button.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/common/section_label.dart';
import '../widgets/inputs/config_text_field.dart';
import '../widgets/inputs/discipline_setup_list.dart';

class IndependentConfigPage extends StatefulWidget {
  const IndependentConfigPage({super.key});

  @override
  State<IndependentConfigPage> createState() => _IndependentConfigPageState();
}

class _IndependentConfigPageState extends State<IndependentConfigPage> {
  final formKey = GlobalKey<FormState>();
  final _setupService = AcademicSetupService();

  final goalController = TextEditingController();
  List<AcademicSetupDisciplineDraft> _disciplines = const [];

  bool isLoading = false;

  @override
  void dispose() {
    goalController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await _setupService.saveSetup(
        studyCycle: StudyCycleInput(
          type: StudyCycleType.independent,
          goal: goalController.text,
        ),
        disciplines: _disciplines,
      );

      if (mounted) AppRoutes.toHomeClearingStack(context);
    } on AcademicSetupException catch (error) {
      if (mounted) _showError(error.message);
    } catch (_) {
      if (mounted) _showError('Não foi possível salvar sua configuração.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(37, 60, 37, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Configure seus\n',
                    style: AppTextStyles.headline2.copyWith(
                      color: context.appColors.textDark,
                    ),
                    children: [
                      TextSpan(
                        text: 'estudos',
                        style: AppTextStyles.headline2.copyWith(
                          color: context.appColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Personalize seu ambiente de estudos para começar',
                  style: AppTextStyles.bodyRegular,
                ),

                const SizedBox(height: 32),

                const SectionLabel(label: 'OBJETIVO (EX: OAB, CONCURSO...)'),
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

                const SizedBox(height: 24),

                const SectionLabel(label: 'DISCIPLINAS'),
                const SizedBox(height: 8),
                DisciplineSetupList(
                  isIndependent: true,
                  onChanged: (disciplines) => _disciplines = disciplines,
                ),

                const SizedBox(height: 24),

                PrimaryButton(
                  label: 'Salvar e continuar',
                  onPressed: _onSave,
                  isLoading: isLoading,
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
