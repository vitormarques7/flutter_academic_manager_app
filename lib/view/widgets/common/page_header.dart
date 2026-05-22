import 'package:flutter/material.dart';
import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class PageHeader extends StatelessWidget {
  final String title;

  const PageHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => AppRoutes.toProfile(context),
            child: Ink(
              width: 66,
              height: 66,
              decoration: const ShapeDecoration(
                color: AppColors.primary,
                shape: OvalBorder(),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  'lib/view/assets/image_profile_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(title, style: AppTextStyles.headline2),
      ],
    );
  }
}
