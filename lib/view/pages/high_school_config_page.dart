import 'package:flutter/material.dart';
import '../../config/routes/app_routes.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/study_cycle.dart';
import '../../services/setup/academic_setup_service.dart';
import '../widgets/buttons/cancel_button.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/common/section_label.dart';
import '../widgets/inputs/discipline_setup_list.dart';
import '../widgets/selectors/series_selector.dart';

class HighSchoolConfigPage extends StatefulWidget {
  const HighSchoolConfigPage({super.key});

  @override
  State<HighSchoolConfigPage> createState() => _HighSchoolConfigPageState();
}

class _HighSchoolConfigPageState extends State<HighSchoolConfigPage> {
  final formKey = GlobalKey<FormState>();
  final _setupService = AcademicSetupService();

  int _selectedSeriesIndex = 0; // Estado para a série selecionada (0 = 1º Ano)
  List<AcademicSetupDisciplineDraft> _disciplines = const [];

  bool isLoading = false;

  Future<void> _onSave() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await _setupService.saveSetup(
        studyCycle: StudyCycleInput(
          type: StudyCycleType.highSchool,
          schoolYear: _selectedSeriesIndex + 1,
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
                DisciplineSetupList(
                  onChanged: (disciplines) => _disciplines = disciplines,
                ),

                const SizedBox(height: 260),

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
