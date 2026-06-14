import 'package:flutter/material.dart';

import '../../../config/theme/app_design_tokens.dart';
import '../../../config/theme/app_theme_colors.dart';

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
  final bool softGradient;

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
    this.softGradient = false,
  });

  const AppSurface.card({
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
    this.softGradient = false,
  });

  const AppSurface.soft({
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
    this.softGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final resolvedGradient =
        gradient ?? (softGradient ? colors.softSurfaceGradient : null);
    final resolvedBorder =
        border ?? Border.fromBorderSide(BorderSide(color: colors.outline));
    final resolvedShadows =
        shadows ?? (softGradient ? colors.subtleShadows : colors.cardShadows);

    return Container(
      width: width ?? double.infinity,
      height: height,
      constraints: constraints,
      margin: margin,
      padding: padding,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: resolvedGradient == null ? color ?? colors.surface : null,
        gradient: resolvedGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: resolvedBorder,
        boxShadow: resolvedShadows,
      ),
      child: child,
    );
  }
}
