import 'package:flutter/material.dart';

import '../../config/routes/app_routes.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/academic_subject.dart';
import '../../models/user_profile.dart';
import '../../repositories/subject_repository.dart';
import '../../repositories/user_profile_repository.dart';
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
  final _disciplineSetupKey = GlobalKey<DisciplineSetupListState>();
  final _subjectRepository = SubjectRepository();
  final _profileRepository = UserProfileRepository();

  static const _seriesOptions = ['1º Ano', '2º Ano', '3º Ano', '4º Ano'];

  int _selectedSeriesIndex = 0;
  bool isLoading = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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

      await _profileRepository.saveProfile(
        UserProfileInput(
          periodLabel: _seriesOptions[_selectedSeriesIndex],
          studentType: 'ensino_medio',
          onboardingCompleted: true,
        ),
      );

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
                  'Personalize seu ambiente de estudos para começar sua jornada acadêmica.',
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
                      const SectionLabel(label: 'Série'),

                      const SizedBox(height: 12),

                      SeriesSelector(
                        selectedIndex: _selectedSeriesIndex,
                        onChanged: (index) {
                          setState(() => _selectedSeriesIndex = index);
                        },
                      ),

                      const SizedBox(height: 28),

                      const SectionLabel(label: 'Disciplinas'),

                      const SizedBox(height: 12),

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
