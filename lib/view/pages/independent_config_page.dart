import 'package:academic_manager_app/config/routes/app_routes.dart';
import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../widgets/primary_button.dart';

class IndependentConfigPage extends StatefulWidget {
  const IndependentConfigPage({super.key});

  @override
  State<IndependentConfigPage> createState() => IndependentConfigPageState();
}

class IndependentConfigPageState extends State<IndependentConfigPage> {
  final formKey = GlobalKey<FormState>();

  final goalController = TextEditingController();

  final discipline1Controller = TextEditingController();
  final discipline2Controller = TextEditingController();
  final discipline3Controller = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    goalController.dispose();
    discipline1Controller.dispose();
    discipline2Controller.dispose();
    discipline3Controller.dispose();
    super.dispose();
  }

  Future<void> onSave() async {
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
                      const SectionLabel(
                        label: 'OBJETIVO (EX: OAB, CONCURSO...)',
                      ),
                      const SizedBox(height: 8),
                      ConfigTextField(controller: goalController),

                      const SizedBox(height: 24),

                      const SectionLabel(label: 'DISCIPLINAS'),
                      const SizedBox(height: 8),
                      ConfigTextField(controller: discipline1Controller),
                      const SizedBox(height: 12),
                      ConfigTextField(controller: discipline2Controller),
                      const SizedBox(height: 12),
                      ConfigTextField(controller: discipline3Controller),

                      const AddDisciplineButton(),

                      const SizedBox(height: 32),

                      PrimaryButton(
                        label: 'Salvar e continuar',
                        onPressed: onSave,
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

class SectionLabel extends StatelessWidget {
  final String label;
  const SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.sectionLabel);
  }
}

class ConfigTextField extends StatelessWidget {
  final TextEditingController controller;
  const ConfigTextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textDark),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.defaultFieldBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(35),
          borderSide: const BorderSide(
            color: AppColors.defaultFieldBorder,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(35),
          borderSide: const BorderSide(
            color: AppColors.defaultFieldBorder,
            width: 2.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(35),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(35),
          borderSide: const BorderSide(color: Colors.red, width: 2.5),
        ),
      ),
    );
  }
}

class AddDisciplineButton extends StatelessWidget {
  const AddDisciplineButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            'Adicionar Disciplina',
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
