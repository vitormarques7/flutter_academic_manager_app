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
  int? selectedPeriod;

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(37, 60, 37, 40),
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

                const SizedBox(height: 32),

                const SectionLabel(label: 'NOME DO CURSO'),
                const SizedBox(height: 8),
                ConfigTextField(controller: courseController),

                const SizedBox(height: 24),

                const SectionLabel(label: 'PERÍODO DO CURSO'),
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
                    setState(() => selectedPeriod = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecione o período atual.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                const SectionLabel(label: 'DISCIPLINAS'),
                const SizedBox(height: 8),
                const DisciplineSetupList(),

                const SizedBox(height: 190),

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
