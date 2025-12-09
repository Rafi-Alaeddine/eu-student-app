// lib/pages/housing/housing_page.dart
import 'package:dentistify/widgets/common/custom_text_field.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/kconstants.dart';
import 'housing_detail_page.dart';

class HousingPage extends StatefulWidget {
  const HousingPage({super.key});

  @override
  State<HousingPage> createState() => _HousingPageState();
}

class _HousingPageState extends State<HousingPage>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _selectedType = 'All';
  RangeValues _priceRange = const RangeValues(200, 800);
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _housingTypes = [
    'All',
    'Dormitory',
    'Apartment',
    'Studio',
    'Shared',
  ];

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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Housing'),
        actions: [
          IconButton(icon: const Icon(Icons.map_outlined), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(KConstants.paddingL),
              child: CustomTextField(
                controller: _searchController,
                label: 'Search housing',
                prefixIcon: Icons.search,
              ),
            ),

            // Type Filter
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: KConstants.paddingL,
                ),
                itemCount: _housingTypes.length,
                itemBuilder: (context, index) {
                  final type = _housingTypes[index];
                  final isSelected = _selectedType == type;

                  return Padding(
                    padding: const EdgeInsets.only(right: KConstants.paddingS),
                    child: _buildTypeChip(context, type, isSelected),
                  );
                },
              ),
            ),

            const SizedBox(height: KConstants.paddingM),

            // Price Range Display
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KConstants.paddingL,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Price Range',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '€${_priceRange.start.round()} - €${_priceRange.end.round()}',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: KConstants.paddingS),

            // Housing List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: KConstants.paddingL,
                ),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return _buildHousingCard(context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context, String type, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: AnimatedContainer(
        duration: KConstants.animationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: KConstants.paddingL,
          vertical: KConstants.paddingS,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: isDark
                      ? [AppColors.darkPrimary, AppColors.darkAccent]
                      : AppColors.primaryGradient,
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(KConstants.radiusCircular),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        (isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary)
                            .withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          type,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkText : AppColors.lightText),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildHousingCard(BuildContext context, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
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
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const HousingDetailPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                  transitionDuration: KConstants.animationNormal,
                ),
              );
            },
            borderRadius: BorderRadius.circular(KConstants.radiusL),
            child: Row(
              children: [
                // Image
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppColors.darkSecondary, AppColors.darkPrimary]
                          : AppColors.secondaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(KConstants.radiusL),
                      bottomLeft: Radius.circular(KConstants.radiusL),
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.home, size: 50, color: Colors.white),
                  ),
                ),

                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(KConstants.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Student Apartment ${index + 1}',
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(
                                KConstants.paddingXS,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.favorite_border,
                                size: KConstants.iconS,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: KConstants.paddingS),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: KConstants.iconS,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            const SizedBox(width: KConstants.paddingXS),
                            Expanded(
                              child: Text(
                                'Near TU Munich',
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: KConstants.paddingS),
                        Row(
                          children: [
                            _buildFeatureChip(context, Icons.bed, '2 Rooms'),
                            const SizedBox(width: KConstants.paddingS),
                            _buildFeatureChip(
                              context,
                              Icons.square_foot,
                              '45m²',
                            ),
                          ],
                        ),
                        const SizedBox(height: KConstants.paddingS),
                        Text(
                          '€${450 + (index * 50)}/month',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(BuildContext context, IconData icon, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KConstants.paddingS,
        vertical: KConstants.paddingXS,
      ),
      decoration: BoxDecoration(
        color:
            (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary)
                .withOpacity(0.1),
        borderRadius: BorderRadius.circular(KConstants.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: KConstants.iconS,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          const SizedBox(width: KConstants.paddingXS),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(KConstants.radiusL),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(KConstants.paddingL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: KConstants.paddingL),

                  // Price Range Slider
                  Text(
                    'Price Range: €${_priceRange.start.round()} - €${_priceRange.end.round()}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 100,
                    max: 1500,
                    divisions: 28,
                    onChanged: (values) {
                      setModalState(() {
                        _priceRange = values;
                      });
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),

                  const SizedBox(height: KConstants.paddingL),

                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
