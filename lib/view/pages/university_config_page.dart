import 'package:academic_manager_app/config/routes/app_routes.dart';
import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_label.dart';
import '../widgets/config_text_field.dart';
import '../widgets/add_discipline_button.dart';

class UniversityConfigPage extends StatefulWidget {
  const UniversityConfigPage({super.key});

  @override
  State<UniversityConfigPage> createState() => UniversityConfigPageState();
}

class UniversityConfigPageState extends State<UniversityConfigPage> {
  final formKey = GlobalKey<FormState>();

  final courseController = TextEditingController();

  final List<TextEditingController> disciplineControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  bool isLoading = false;

  @override
  void dispose() {
    courseController.dispose();
    for (final c in disciplineControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addDiscipline() {
    setState(() => disciplineControllers.add(TextEditingController()));
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

                      ...disciplineControllers.map(
                        (controller) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ConfigTextField(controller: controller),
                        ),
                      ),

                      const SizedBox(height: 4),

                      AddDisciplineButton(onTap: _addDiscipline),

                      const SizedBox(height: 32),

                      PrimaryButton(
                        label: 'Salvar e continuar',
                        onPressed: _onSave,
                        isLoading: isLoading,
                      ),
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
