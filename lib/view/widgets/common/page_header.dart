import 'package:flutter/material.dart';
import '../../../config/routes/app_routes.dart';
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
        Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: AppShadows.subtle,
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: Ink.image(
              image: const AssetImage('lib/view/assets/profile_pic_v2.png'),
              fit: BoxFit.cover,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => AppRoutes.toProfile(context),
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
