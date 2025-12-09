// lib/pages/housing/housing_detail_page.dart
import 'package:dentistify/widgets/common/custom_button.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/kconstants.dart';

class HousingDetailPage extends StatefulWidget {
  const HousingDetailPage({super.key});

  @override
  State<HousingDetailPage> createState() => _HousingDetailPageState();
}

class _HousingDetailPageState extends State<HousingDetailPage> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image Gallery
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    itemCount: 3,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    AppColors.darkSecondary,
                                    AppColors.darkPrimary,
                                  ]
                                : AppColors.secondaryGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.home,
                            size: 100,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: KConstants.paddingL,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentImageIndex == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentImageIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(KConstants.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Modern Student Apartment',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                      Text(
                        '€550',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: KConstants.paddingS),

                  Text(
                    'per month',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: KConstants.paddingL),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary,
                      ),
                      const SizedBox(width: KConstants.paddingS),
                      Expanded(
                        child: Text(
                          'Studentenstadt, Munich, 5 min walk to TU Munich',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: KConstants.paddingXL),

                  // Features
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeatureCard(context, Icons.bed, '2', 'Bedrooms'),
                      _buildFeatureCard(
                        context,
                        Icons.bathtub,
                        '1',
                        'Bathroom',
                      ),
                      _buildFeatureCard(
                        context,
                        Icons.square_foot,
                        '45m²',
                        'Area',
                      ),
                    ],
                  ),

                  const SizedBox(height: KConstants.paddingXL),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: KConstants.paddingM),
                  Text(
                    'Spacious and bright apartment perfect for students. Located in a quiet neighborhood with excellent public transport connections. Close to supermarkets, cafes, and the university campus. Fully furnished with modern amenities.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: KConstants.paddingXL),

                  // Amenities
                  Text(
                    'Amenities',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: KConstants.paddingM),
                  Wrap(
                    spacing: KConstants.paddingS,
                    runSpacing: KConstants.paddingS,
                    children: [
                      _buildAmenityChip(context, Icons.wifi, 'WiFi'),
                      _buildAmenityChip(
                        context,
                        Icons.local_laundry_service,
                        'Laundry',
                      ),
                      _buildAmenityChip(context, Icons.kitchen, 'Kitchen'),
                      _buildAmenityChip(context, Icons.ac_unit, 'Heating'),
                      _buildAmenityChip(context, Icons.balcony, 'Balcony'),
                      _buildAmenityChip(context, Icons.pets, 'Pet Friendly'),
                    ],
                  ),

                  const SizedBox(height: KConstants.paddingXL),

                  // Additional Costs
                  Text(
                    'Additional Costs',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: KConstants.paddingM),
                  _buildCostRow(context, 'Utilities', '€80/month'),
                  _buildCostRow(context, 'Deposit', '€1,100'),
                  _buildCostRow(context, 'Internet', 'Included'),

                  const SizedBox(height: KConstants.paddingXL),

                  // Contact Landlord
                  Text(
                    'Landlord',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: KConstants.paddingM),
                  Container(
                    padding: const EdgeInsets.all(KConstants.paddingL),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(KConstants.radiusL),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      AppColors.darkPrimary,
                                      AppColors.darkAccent,
                                    ]
                                  : AppColors.primaryGradient,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: KConstants.paddingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'John Müller',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'Property Manager',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.phone),
                          onPressed: () {},
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: KConstants.paddingXL),

                  // Contact Buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Contact',
                          onPressed: () {},
                          gradient: LinearGradient(
                            colors: isDark
                                ? [AppColors.darkPrimary, AppColors.darkAccent]
                                : AppColors.primaryGradient,
                          ),
                          icon: Icons.message,
                        ),
                      ),
                      const SizedBox(width: KConstants.paddingM),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(
                            KConstants.radiusM,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.share,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: KConstants.paddingL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(KConstants.paddingL),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(KConstants.radiusL),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            size: KConstants.iconL,
          ),
          const SizedBox(height: KConstants.paddingS),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(BuildContext context, IconData icon, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KConstants.paddingM,
        vertical: KConstants.paddingS,
      ),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(KConstants.radiusCircular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: KConstants.iconS,
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          ),
          const SizedBox(width: KConstants.paddingS),
          Text(
            label,
            style: TextStyle(
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KConstants.paddingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
