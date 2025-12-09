import 'package:dentistify/core/constants/app_colors.dart';
import 'package:dentistify/core/constants/app_strings.dart';
import 'package:dentistify/core/constants/kconstants.dart';
import 'package:dentistify/pages/auth/login_page.dart';
import 'package:flutter/material.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KConstants.paddingL),
        child: Column(
          children: [
            // Profile Avatar
            Hero(
              tag: 'profile_avatar',
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.darkPrimary, AppColors.darkAccent]
                        : AppColors.primaryGradient,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary)
                              .withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),

            const SizedBox(height: KConstants.paddingL),

            Text(
              'Student Name',
              style: Theme.of(context).textTheme.displaySmall,
            ),

            const SizedBox(height: KConstants.paddingS),

            Text(
              'student@email.com',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: KConstants.paddingXL),

            _buildProfileOption(
              context,
              icon: Icons.edit_outlined,
              title: AppStrings.editProfile,
              onTap: () {},
            ),

            _buildProfileOption(
              context,
              icon: Icons.settings_outlined,
              title: AppStrings.settings,
              onTap: () {},
            ),

            _buildProfileOption(
              context,
              icon: Icons.dark_mode_outlined,
              title: AppStrings.darkMode,
              onTap: () {},
            ),

            _buildProfileOption(
              context,
              icon: Icons.info_outline,
              title: AppStrings.aboutUs,
              onTap: () {},
            ),

            const SizedBox(height: KConstants.paddingL),

            _buildProfileOption(
              context,
              icon: Icons.logout,
              title: AppStrings.logout,
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: KConstants.paddingM),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(KConstants.radiusM),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive
              ? (isDark ? AppColors.darkError : AppColors.lightError)
              : (isDark ? AppColors.darkPrimary : AppColors.lightPrimary),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive
                ? (isDark ? AppColors.darkError : AppColors.lightError)
                : null,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
