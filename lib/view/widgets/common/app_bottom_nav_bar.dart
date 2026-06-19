import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/theme/app_theme_extension.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavItemData> _items = [
    _NavItemData(
      label: 'Início',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    _NavItemData(
      label: 'Disciplinas',
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book,
    ),
    _NavItemData(
      label: 'Tarefas',
      icon: Icons.check_box_outlined,
      activeIcon: Icons.check_box,
    ),
    _NavItemData(
      label: 'Horário',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final appTheme = context.appTheme;

    return Material(
      color: appTheme.navBackground,
      elevation: 10,
      shadowColor: appTheme.shadow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 8, 12, bottomInset > 0 ? 8 : 10),
          child: SizedBox(
            height: 62,
            child: Row(
              children: List.generate(_items.length, (index) {
                final item = _items[index];

                return Expanded(
                  child: _AnimatedNavItem(
                    label: item.label,
                    icon: item.icon,
                    activeIcon: item.activeIcon,
                    isSelected: currentIndex == index,
                    onTap: () => onTap(index),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final color = isSelected ? AppColors.navActive : appTheme.navInactive;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.navActive.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: isSelected ? 1 : 0),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: Offset(0, -2 * value),
                      child: Transform.scale(
                        scale: 1 + (0.08 * value),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(
                                  begin: 0.82,
                                  end: 1,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Icon(
                            isSelected ? activeIcon : icon,
                            key: ValueKey('$label-$isSelected'),
                            color: color,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      style: AppTextStyles.navLabel.copyWith(
                        color: color,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        letterSpacing: 0,
                        height: 1.2,
                      ),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      width: 18 + (10 * value),
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.navActive.withValues(alpha: value),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
