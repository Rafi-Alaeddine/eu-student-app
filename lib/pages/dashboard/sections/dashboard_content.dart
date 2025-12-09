// lib/pages/dashboard/sections/dashboard_content.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/kconstants.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

enum Menu { profile, settings, darkMode, contactUs }

class _DashboardContentState extends State<DashboardContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  void _handleMenuSelection(Menu item) {
    switch (item) {
      case Menu.profile:
        Navigator.pushNamed(context, '/profile');
      case Menu.settings:
        Navigator.pushNamed(context, '/settings');
      case Menu.darkMode:
        Navigator.pushNamed(context, '/darkMode');
      case Menu.contactUs:
        Navigator.pushNamed(context, '/contactUs');
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: KConstants.animationSlow,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(KConstants.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppStrings.welcome}!',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: KConstants.paddingXS),
                          Text(
                            'Explore your European journey',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [AppColors.darkPrimary, AppColors.darkAccent]
                                : AppColors.primaryGradient,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: PopupMenuButton<Menu>(
                          icon: const Icon(
                            Icons.table_rows_rounded,
                            color: Colors.white,
                          ),
                          onSelected: _handleMenuSelection,
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<Menu>>[
                                const PopupMenuItem<Menu>(
                                  value: Menu.profile,
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.person_outline,
                                      color: AppColors.darkPrimary,
                                    ),
                                    title: Text('Profile'),
                                  ),
                                ),
                                const PopupMenuItem<Menu>(
                                  value: Menu.settings,
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.settings_outlined,
                                      color: AppColors.darkPrimary,
                                    ),
                                    title: Text('Settings'),
                                  ),
                                ),
                                const PopupMenuItem<Menu>(
                                  value: Menu.darkMode,
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.dark_mode,
                                      color: AppColors.darkPrimary,
                                    ),
                                    title: Text('Dark Mode'),
                                  ),
                                ),
                                const PopupMenuDivider(),
                                const PopupMenuItem<Menu>(
                                  value: Menu.contactUs,
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.info_outline,
                                      color: AppColors.darkPrimary,
                                    ),
                                    title: Text('Contact us'),
                                  ),
                                ),
                              ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: KConstants.paddingXL),

                  // Quick Actions Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: KConstants.paddingM,
                    crossAxisSpacing: KConstants.paddingM,
                    childAspectRatio: 0.9,
                    children: [
                      _buildQuickActionCard(
                        context,
                        title: AppStrings.exploreUniversities,
                        icon: Icons.school_rounded,
                        gradient: isDark
                            ? [AppColors.darkPrimary, AppColors.darkAccent]
                            : AppColors.primaryGradient,
                        delay: 0,
                      ),
                      _buildQuickActionCard(
                        context,
                        title: AppStrings.findHousing,
                        icon: Icons.home_rounded,
                        gradient: isDark
                            ? [AppColors.darkSecondary, AppColors.darkPrimary]
                            : AppColors.secondaryGradient,
                        delay: 100,
                      ),
                      _buildQuickActionCard(
                        context,
                        title: AppStrings.transportInfo,
                        icon: Icons.directions_bus_rounded,
                        gradient: isDark
                            ? [AppColors.darkAccent, AppColors.darkPrimary]
                            : AppColors.accentGradient,
                        delay: 200,
                      ),
                      _buildQuickActionCard(
                        context,
                        title: AppStrings.studentGuide,
                        icon: Icons.menu_book_rounded,
                        gradient: const [Color(0xFFFF6B9D), Color(0xFFC06C84)],
                        delay: 300,
                      ),
                    ],
                  ),

                  const SizedBox(height: KConstants.paddingXL),

                  // Featured Section
                  Text(
                    'Featured Universities',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: KConstants.paddingM),

                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return _buildFeaturedCard(context, index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Color> gradient,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(KConstants.radiusL),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(KConstants.radiusL),
            child: Padding(
              padding: const EdgeInsets.all(KConstants.paddingM),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: KConstants.iconXL, color: Colors.white),
                  const SizedBox(height: KConstants.paddingM),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: KConstants.paddingS),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(KConstants.radiusL),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.darkPrimary, AppColors.darkAccent]
                      : AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(KConstants.radiusL),
                  topRight: Radius.circular(KConstants.radiusL),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.account_balance,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(KConstants.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'University Name ${index + 1}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: KConstants.paddingXS),
                  Text(
                    'City, Country',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
