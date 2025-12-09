// lib/pages/transport/transport_page.dart
import 'package:dentistify/pages/transport/map_page.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/kconstants.dart';

class TransportPage extends StatefulWidget {
  const TransportPage({super.key});

  @override
  State<TransportPage> createState() => _TransportPageState();
}

class _TransportPageState extends State<TransportPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedCity = 'Munich';

  late final TransportMode mode;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: KConstants.animationSlow,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transportation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_city),
            onPressed: _showCityPicker,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(KConstants.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected City Banner
              Container(
                padding: const EdgeInsets.all(KConstants.paddingL),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.darkPrimary, AppColors.darkAccent]
                        : AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(KConstants.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary)
                              .withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: KConstants.iconL,
                      ),
                      const SizedBox(width: KConstants.paddingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current City',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _selectedCity,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: KConstants.paddingXL),

              // Transport Options
              Text(
                'Transport Options',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: KConstants.paddingM),

              _buildTransportCard(
                context,
                icon: Icons.subway,
                title: 'Metro/U-Bahn',
                description: '8 lines, operates 4:00 - 1:00',
                color: Colors.blue,
                mode: TransportMode.metro,
              ),

              _buildTransportCard(
                context,
                icon: Icons.directions_bus,
                title: 'Bus',
                description: '100+ routes across the city',
                color: Colors.green,
                mode: TransportMode.bus,
              ),

              _buildTransportCard(
                context,
                icon: Icons.tram,
                title: 'Tram',
                description: '12 lines, eco-friendly option',
                color: Colors.orange,
                mode: TransportMode.tram,
              ),

              _buildTransportCard(
                context,
                icon: Icons.train,
                title: 'S-Bahn',
                description: 'Regional trains, connects suburbs',
                color: Colors.red,
                mode: TransportMode.sbahn,
              ),

              _buildTransportCard(
                context,
                icon: Icons.directions_bike,
                title: 'Bike Sharing',
                description: 'MVG Rad - 200+ stations',
                color: Colors.purple,
                mode: TransportMode.bikeSharing,
              ),

              _buildTransportCard(
                context,
                icon: Icons.local_taxi,
                title: 'Taxi & Rideshare',
                description: 'Uber, Taxi München, Free Now',
                color: Colors.amber,
                mode: TransportMode.taxiRideshare,
              ),

              const SizedBox(height: KConstants.paddingXL),

              // Student Passes
              Text(
                'Student Passes',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: KConstants.paddingM),

              _buildPassCard(
                context,
                title: 'Semester Ticket',
                price: '€195/semester',
                benefits: [
                  'All MVG transport',
                  'Valid 24/7',
                  '6 months coverage',
                ],
                isRecommended: true,
              ),

              _buildPassCard(
                context,
                title: 'Monthly Pass',
                price: '€55/month',
                benefits: ['All zones', 'Unlimited rides', 'Transferable'],
                isRecommended: false,
              ),

              // Quick Tips
              Text(
                'Transportation Tips',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: KConstants.paddingM),

              _buildTipCard(
                context,
                icon: Icons.access_time,
                title: 'Peak Hours',
                description:
                    'Avoid 7-9 AM and 5-7 PM for a more comfortable ride',
              ),

              _buildTipCard(
                context,
                icon: Icons.phone_android,
                title: 'MVG App',
                description:
                    'Download the official app for real-time schedules and tickets',
              ),

              _buildTipCard(
                context,
                icon: Icons.euro,
                title: 'Validation',
                description:
                    'Always validate your ticket before boarding to avoid fines',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransportCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required TransportMode mode,
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
          onTap: () {
            // Pass selected city to MapPage so backend can be queried with it.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapPage(mode: mode, city: _selectedCity),
              ),
            );
          },
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
                        style: Theme.of(context).textTheme.titleMedium,
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
                  Icons.arrow_forward_ios,
                  size: KConstants.iconS,
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

  Widget _buildPassCard(
    BuildContext context, {
    required String title,
    required String price,
    required List<String> benefits,
    required bool isRecommended,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: KConstants.paddingM),
      decoration: BoxDecoration(
        gradient: isRecommended
            ? LinearGradient(
                colors: isDark
                    ? [AppColors.darkPrimary, AppColors.darkAccent]
                    : AppColors.primaryGradient,
              )
            : null,
        color: isRecommended
            ? null
            : (isDark ? AppColors.darkCard : AppColors.lightCard),
        borderRadius: BorderRadius.circular(KConstants.radiusL),
        border: isRecommended
            ? null
            : Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
        boxShadow: isRecommended
            ? [
                BoxShadow(
                  color:
                      (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                          .withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(KConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: KConstants.paddingM,
                  vertical: KConstants.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(
                    KConstants.radiusCircular,
                  ),
                ),
                child: const Text(
                  'RECOMMENDED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            if (isRecommended) const SizedBox(height: KConstants.paddingM),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isRecommended
                        ? Colors.white
                        : (isDark ? AppColors.darkText : AppColors.lightText),
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isRecommended
                        ? Colors.white
                        : (isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: KConstants.paddingM),

            ...benefits.map(
              (benefit) => Padding(
                padding: const EdgeInsets.only(bottom: KConstants.paddingS),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: KConstants.iconS,
                      color: isRecommended
                          ? Colors.white
                          : (isDark
                                ? AppColors.darkSuccess
                                : AppColors.lightSuccess),
                    ),
                    const SizedBox(width: KConstants.paddingS),
                    Text(
                      benefit,
                      style: TextStyle(
                        color: isRecommended
                            ? Colors.white
                            : (isDark
                                  ? AppColors.darkText
                                  : AppColors.lightText),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: KConstants.paddingM),
      padding: const EdgeInsets.all(KConstants.paddingL),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(KConstants.radiusM),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
          ),
          const SizedBox(width: KConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: KConstants.paddingXS),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCityPicker() {
    final cities = ['Munich', 'Berlin', 'Hamburg', 'Frankfurt', 'Cologne'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(KConstants.radiusL),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(KConstants.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select City',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: KConstants.paddingL),
              ...cities.map(
                (city) => ListTile(
                  title: Text(city),
                  trailing: _selectedCity == city
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.lightPrimary,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedCity = city;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
