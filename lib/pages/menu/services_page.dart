// lib/pages/menu/services_page.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/kconstants.dart';
// Import pages for navigation
import '../universities/universities_page.dart';
import '../housing/housing_page.dart';
import '../transport/transport_page.dart';
import '../language/language_helper_page.dart';
import '../community/events_page.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  void _navigateToService(BuildContext context, String serviceType) {
    Widget page;

    switch (serviceType) {
      case 'university':
        page = const UniversitiesPage();
        break;
      case 'housing':
        page = const HousingPage();
        break;
      case 'transport':
        page = const TransportPage();
        break;
      case 'language':
        page = const LanguageHelperPage();
        break;
      case 'events':
        page = const EventsPage();
        break;
      default:
        return; // Do nothing if unknown service
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(KConstants.paddingL),
        children: [
          _buildServiceCard(
            context,
            icon: Icons.school_rounded,
            title: 'University Search',
            description: 'Find the perfect university across EU countries',
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            onTap: () => _navigateToService(context, 'university'),
          ),
          _buildServiceCard(
            context,
            icon: Icons.home_rounded,
            title: 'Housing Options',
            description: 'Discover affordable dorms and apartments near campus',
            color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
            onTap: () => _navigateToService(context, 'housing'),
          ),
          _buildServiceCard(
            context,
            icon: Icons.directions_bus_rounded,
            title: 'Transportation',
            description:
                'Navigate your city with ease using our transport maps',
            color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
            onTap: () => _navigateToService(context, 'transport'),
          ),
          _buildServiceCard(
            context,
            icon: Icons.language_rounded,
            title: 'Language Support',
            description: 'Access resources in multiple languages',
            color: isDark ? AppColors.darkSuccess : AppColors.lightSuccess,
            onTap: () => _navigateToService(context, 'language'),
          ),
          _buildServiceCard(
            context,
            icon: Icons.event_rounded,
            title: 'Events & Activities',
            description: 'Join student events and networking opportunities',
            color: isDark ? AppColors.darkWarning : AppColors.lightWarning,
            onTap: () => _navigateToService(context, 'events'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: KConstants.paddingM),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(KConstants.radiusL),
          child: Padding(
            padding: const EdgeInsets.all(KConstants.paddingL),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(KConstants.radiusM),
                  ),
                  child: Icon(icon, color: color, size: KConstants.iconL),
                ),
                const SizedBox(width: KConstants.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: KConstants.paddingXS),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
