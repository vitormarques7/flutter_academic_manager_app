import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_design_tokens.dart';

class AppSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final Border? border;
  final List<BoxShadow>? shadows;
  final double borderRadius;
  final Clip clipBehavior;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;

  const AppSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.color,
    this.gradient,
    this.border,
    this.shadows,
    this.borderRadius = AppRadius.lg,
    this.clipBehavior = Clip.antiAlias,
    this.width,
    this.height,
    this.constraints,
  });

  const AppSurface.card({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.color = AppColors.surface,
    this.gradient,
    this.border = const Border.fromBorderSide(
      BorderSide(color: AppColors.outline),
    ),
    this.shadows = AppShadows.card,
    this.borderRadius = AppRadius.lg,
    this.clipBehavior = Clip.antiAlias,
    this.width,
    this.height,
    this.constraints,
  });

  const AppSurface.soft({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.color,
    this.gradient = AppGradients.softSurface,
    this.border = const Border.fromBorderSide(
      BorderSide(color: AppColors.outline),
    ),
    this.shadows = AppShadows.subtle,
    this.borderRadius = AppRadius.lg,
    this.clipBehavior = Clip.antiAlias,
    this.width,
    this.height,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      constraints: constraints,
      margin: margin,
      padding: padding,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: gradient == null ? color ?? AppColors.surface : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: shadows,
      ),
      child: child,
    );
  }
}
