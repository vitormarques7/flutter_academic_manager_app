import 'package:flutter/material.dart';
import '../../config/routes/app_routes.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/common/section_label.dart';
import '../widgets/inputs/config_text_field.dart';
import '../widgets/buttons/add_discipline_button.dart';
import '../widgets/selectors/series_selector.dart';

class HighSchoolConfigPage extends StatefulWidget {
  const HighSchoolConfigPage({super.key});

  @override
  State<HighSchoolConfigPage> createState() => _HighSchoolConfigPageState();
}

class _HighSchoolConfigPageState extends State<HighSchoolConfigPage> {
  final formKey = GlobalKey<FormState>();

  int _selectedSeriesIndex = 0; // Estado para a série selecionada (0 = 1º Ano)

  final List<TextEditingController> disciplineControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  bool isLoading = false;

  @override
  void dispose() {
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
      // Mock da API/Firebase
      await Future.delayed(const Duration(seconds: 1));

      // Aqui, salvar o _selectedSeriesIndex (+1 para o ano real) e as disciplinas
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
                      const SectionLabel(label: 'SÉRIE'),
                      const SizedBox(height: 8),

                      SeriesSelector(
                        selectedIndex: _selectedSeriesIndex,
                        onChanged: (index) {
                          setState(() => _selectedSeriesIndex = index);
                        },
                      ),

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
