import 'package:flutter/material.dart';

import '../../../config/theme/app_theme_colors.dart';

class CancelButton extends StatelessWidget {
  final VoidCallback? onTap;

  const CancelButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: colors.textDark,
                fontSize: 20,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
                height: 1.10,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
