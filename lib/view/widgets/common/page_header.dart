import 'package:flutter/material.dart';
import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_design_tokens.dart';
import '../../../config/theme/app_text_styles.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const PageHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: AppColors.surface,
          shape: const CircleBorder(),
          elevation: 0,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => AppRoutes.toProfile(context),
            child: Ink(
              width: 58,
              height: 58,
              decoration: ShapeDecoration(
                color: AppColors.primarySoft,
                shape: OvalBorder(),
                shadows: AppShadows.subtle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: Image.asset(
                  'lib/view/assets/image_profile_icon.png',
                  fit: BoxFit.contain,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.headline2.copyWith(
              fontSize: 26,
              height: 1.08,
              letterSpacing: 0,
            ),
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}
