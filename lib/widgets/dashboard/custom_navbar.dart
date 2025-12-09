// lib/widgets/custom_navbar.dart
import 'package:dentistify/core/constants/app_colors.dart';
import 'package:dentistify/core/constants/kconstants.dart';
import 'package:flutter/material.dart';

class CustomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  final List<NavItem> _items = [
    NavItem(icon: Icons.home_rounded, label: 'Home'),
    NavItem(icon: Icons.grid_view_rounded, label: 'Services'),
    NavItem(icon: Icons.chat, label: 'Community'),
    NavItem(icon: Icons.search, label: 'Search'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            _items.length,
            (index) => _buildNavItem(context, index, _items[index]),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, NavItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = widget.currentIndex == index;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
      duration: KConstants.animationNormal,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return GestureDetector(
          onTap: () => widget.onTap(index),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: KConstants.paddingM,
              vertical: KConstants.paddingS,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(KConstants.radiusM),
              color: isSelected
                  ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                        .withOpacity(0.1 * value)
                  : Colors.transparent,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: KConstants.animationNormal,
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(
                    KConstants.paddingS * (1 + value * 0.2),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(KConstants.radiusM),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color:
                                  (isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.lightPrimary)
                                      .withOpacity(0.3 * value),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    item.icon,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                    size: KConstants.iconM,
                  ),
                ),
                const SizedBox(height: KConstants.paddingXS),
                AnimatedDefaultTextStyle(
                  duration: KConstants.animationNormal,
                  curve: Curves.easeInOut,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? (isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary)
                        : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                  ),
                  child: Text(item.label),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;

  NavItem({required this.icon, required this.label});
}
