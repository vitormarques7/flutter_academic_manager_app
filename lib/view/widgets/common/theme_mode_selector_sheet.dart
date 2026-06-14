import 'package:flutter/material.dart';

import '../../../config/theme/app_text_styles.dart';
import '../../../config/theme/app_theme_colors.dart';
import '../../../config/theme/app_theme_controller.dart';

class ThemeModeSelectorSheet extends StatefulWidget {
  final AppThemeController controller;

  const ThemeModeSelectorSheet({super.key, required this.controller});

  @override
  State<ThemeModeSelectorSheet> createState() => _ThemeModeSelectorSheetState();
}

class _ThemeModeSelectorSheetState extends State<ThemeModeSelectorSheet> {
  late ThemeMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.controller.themeMode;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aparência',
              style: AppTextStyles.headline3.copyWith(
                color: colors.textDark,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha como o Nexo Estudos deve aparecer neste aparelho.',
              style: AppTextStyles.bodyRegular.copyWith(
                color: colors.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            RadioGroup<ThemeMode>(
              groupValue: _selectedMode,
              onChanged: _updateThemeMode,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ThemeModeOption(
                    title: 'Sistema',
                    subtitle: 'Segue a configuração do dispositivo',
                    icon: Icons.settings_suggest_outlined,
                    value: ThemeMode.system,
                  ),
                  _ThemeModeOption(
                    title: 'Claro',
                    subtitle: 'Mantém o app sempre claro',
                    icon: Icons.light_mode_outlined,
                    value: ThemeMode.light,
                  ),
                  _ThemeModeOption(
                    title: 'Escuro',
                    subtitle: 'Mantém o app sempre escuro',
                    icon: Icons.dark_mode_outlined,
                    value: ThemeMode.dark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateThemeMode(ThemeMode? mode) {
    if (mode == null) return;

    setState(() => _selectedMode = mode);
    widget.controller.updateThemeMode(mode);
  }
}

class _ThemeModeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final ThemeMode value;

  const _ThemeModeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return RadioListTile<ThemeMode>(
      value: value,
      activeColor: colors.primary,
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: colors.primary),
      title: Text(
        title,
        style: AppTextStyles.bodyBold.copyWith(color: colors.textDark),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodyRegular.copyWith(
          color: colors.textMuted,
          fontSize: 13,
        ),
      ),
    );
  }
}
