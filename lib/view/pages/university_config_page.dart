import 'package:academic_manager_app/config/routes/app_routes.dart';
import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
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

  final courseController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    courseController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) AppRoutes.toHome(context);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(37, 60, 37, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'Configure seus\n',
                        style: AppTextStyles.headline2,
                        children: [
                          TextSpan(
                            text: 'estudos',
                            style: AppTextStyles.headline2.copyWith(
                              color: AppColors.primary,
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
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(37, 0, 37, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel(label: 'NOME DO CURSO'),
                      const SizedBox(height: 8),
                      ConfigTextField(controller: courseController),

                      const SizedBox(height: 24),

                      const SectionLabel(label: 'DISCIPLINAS'),
                      const SizedBox(height: 8),
                      const DisciplineSetupList(),

                      const SizedBox(height: 184),

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
            ],
          ),
        ),
      ),
    );
  }
}
