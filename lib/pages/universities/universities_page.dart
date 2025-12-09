// lib/pages/universities/universities_page.dart
import 'package:dentistify/widgets/common/custom_text_field.dart';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/kconstants.dart';
import '../../data/models/country_model.dart';
import '../../data/models/university_model.dart';
import '../../services/university_api_service.dart';
import 'university_detail_page.dart';

class UniversitiesPage extends StatefulWidget {
  const UniversitiesPage({super.key});

  @override
  State<UniversitiesPage> createState() => _UniversitiesPageState();
}

class _UniversitiesPageState extends State<UniversitiesPage>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String? _selectedCountry;
  String? _selectedCity;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // UI State Variables:
  // - _allUniversities: Full list loaded from API based on selected country
  // - _filteredUniversities: List shown in UI after applying city/search filters
  // - _europeanCountries: Countries loaded from HEI API (all European)
  // Loading states: _isLoading (universities), _isLoadingCountries (countries dropdown), _isLoadingCities (cities modal)
  List<UniversityModel> _allUniversities = [];
  List<UniversityModel> _filteredUniversities = [];
  List<CountryModel> _europeanCountries = []; // European countries from API
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoadingCountries = false; // Loading state for countries
  bool _isLoadingCities = false; // Loading state for cities

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

    // NEW: Load European countries and universities on app start
    _loadEuropeanCountries();
    _loadEuropeanUniversities();

    // NEW: Listen to search input
    _searchController.addListener(_onSearchChanged);

    _animationController.forward();
  }

  // NEW: Load European countries method
  Future<void> _loadEuropeanCountries() async {
    developer.log('🇪🇺 Starting to load European countries...');

    setState(() {
      _isLoadingCountries = true;
    });

    try {
      final countries = await UniversityApiService.getEuropeanCountries();
      setState(() {
        _europeanCountries = countries;
        _isLoadingCountries = false;
      });
      developer.log(
        '✅ Successfully loaded ${countries.length} European countries',
      );
    } catch (e) {
      setState(() {
        _isLoadingCountries = false;
      });
      // For now, just log the error. You might want to show it to the user
      developer.log('❌ Failed to load European countries: $e');
    }
  }

  // NEW: Load universities method
  Future<void> _loadEuropeanUniversities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final universities =
          await UniversityApiService.fetchEuropeanUniversities();
      setState(() {
        _allUniversities = universities;
        _filteredUniversities = universities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // NEW: Search handler
  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _applyFilters();
    } else {
      _searchUniversities(query);
    }
  }

  // NEW: Filter universities based on country/city
  void _applyFilters() {
    setState(() {
      _filteredUniversities = _allUniversities.where((university) {
        // Get country code for comparison since university.country is code like "AT"
        final selectedCountryCode = _selectedCountry != null
            ? UniversityApiService.getCountryCode(_selectedCountry!)
            : null;
        final countryMatch =
            selectedCountryCode == null ||
            university.country == selectedCountryCode;
        final cityMatch =
            _selectedCity == null ||
            university.city.toLowerCase() == _selectedCity!.toLowerCase();
        return countryMatch && cityMatch;
      }).toList();
    });
  }

  // NEW: Search universities
  Future<void> _searchUniversities(String query) async {
    if (query.isEmpty) {
      _applyFilters();
      return;
    }

    // Simple implementation for now
    try {
      final searchResults = await UniversityApiService.searchUniversities(
        query,
      );
      setState(() {
        _filteredUniversities = searchResults
            .where((uni) => KConstants.euCountries.contains(uni.country))
            .toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Search failed: $e';
      });
    }
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
        title: const Text('Universities'),
        actions: [
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
                label: AppStrings.searchUniversities,
                prefixIcon: Icons.search,
              ),
            ),

            // Filter Chips - Unconstrained width to prevent overflow
            SizedBox(
              height: 50,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: KConstants.paddingL,
                ),
                child: UnconstrainedBox(
                  child: Row(
                    children: [
                      _buildFilterChip(
                        context,
                        label: _selectedCountry ?? 'Country',
                        icon: Icons.public,
                        onTap: () => _showCountryPicker(),
                      ),
                      const SizedBox(width: KConstants.paddingS),
                      _buildFilterChip(
                        context,
                        label: _selectedCity ?? 'City',
                        icon: Icons.location_city,
                        onTap: () => _showCityPicker(),
                      ),
                      const SizedBox(width: KConstants.paddingS),
                      _buildFilterChip(
                        context,
                        label: 'Programs',
                        icon: Icons.school,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: KConstants.paddingM),

            // Replace the dummy ListView.builder:
            Expanded(
              child: _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(_errorMessage!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadEuropeanUniversities,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    )
                  : _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredUniversities.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No universities found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Try selecting a different country or city',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: KConstants.paddingL,
                      ),
                      itemCount: _filteredUniversities.length,
                      itemBuilder: (context, index) {
                        final university = _filteredUniversities[index];
                        return _buildUniversityCard(context, index, university);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 120), // Limit chip width
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: KConstants.paddingM,
            vertical: KConstants.paddingS,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(KConstants.radiusCircular),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
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
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUniversityCard(
    BuildContext context,
    int index,
    UniversityModel university,
  ) {
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
                      UniversityDetailPage(
                        university: university,
                      ), // NEW: Pass university data
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.1),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                  transitionDuration: KConstants.animationNormal,
                ),
              );
            },
            borderRadius: BorderRadius.circular(KConstants.radiusL),
            child: Column(
              children: [
                // University Image
                Container(
                  height: 150,
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
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          Icons.account_balance,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        top: KConstants.paddingM,
                        right: KConstants.paddingM,
                        child: Container(
                          padding: const EdgeInsets.all(KConstants.paddingS),
                          decoration: BoxDecoration(
                            color: AppColors.darkPrimary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                            size: KConstants.iconM,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // University Info
                Padding(
                  padding: const EdgeInsets.all(KConstants.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        university.name,
                        style: Theme.of(context).textTheme.titleLarge,
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
                          Text(
                            '${university.city}, ${university.country}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: KConstants.paddingS),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildInfoChip(
                              context,
                              Icons.people,
                              university.numberOfStudents != null
                                  ? '${university.numberOfStudents} Students'
                                  : '', // Show blank space if no data
                            ),
                            const SizedBox(width: KConstants.paddingS),
                            _buildInfoChip(
                              context,
                              Icons.star,
                              university.rating != null
                                  ? '${university.rating!.toStringAsFixed(1)}'
                                  : '', // Show blank space if no data
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: KConstants.paddingM),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              university.programs?.join(', ') ?? '',
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: KConstants.iconS,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KConstants.paddingS,
        vertical: KConstants.paddingXS,
      ),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(KConstants.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: KConstants.iconS,
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          ),
          const SizedBox(width: KConstants.paddingXS),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white : Colors.black, // Better contrast
            ),
          ),
        ],
      ),
    );
  }

  void _showCountryPicker() {
    // If countries are still loading, show loading indicator
    if (_isLoadingCountries) {
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
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Loading European Countries...'),
                SizedBox(height: 16),
                CircularProgressIndicator(),
              ],
            ),
          );
        },
      );
      return;
    }

    // If no countries loaded, fall back to static list
    final countriesToShow = _europeanCountries.isNotEmpty
        ? _europeanCountries
        : KConstants.euCountries.map((countryName) {
            // Create CountryModel objects from static list as fallback
            final countryCode =
                UniversityApiService.getCountryCode(countryName) ?? '';
            return CountryModel(
              countryCode: countryCode,
              countryName: countryName,
            );
          }).toList();

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
                'Select European Country',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: KConstants.paddingL),
              Expanded(
                child: ListView.builder(
                  itemCount: countriesToShow.length,
                  itemBuilder: (context, index) {
                    final country = countriesToShow[index];
                    final displayName = _europeanCountries.isNotEmpty
                        ? country
                              .countryName // API data: full name like "France"
                        : country
                              .countryName; // Fallback: static name like "France"
                    final codeDisplay = _europeanCountries.isNotEmpty
                        ? ' (${country.countryCode})' // API data: show code like " (FR)"
                        : ''; // Fallback: no code

                    return ListTile(
                      title: Text('$displayName$codeDisplay'),
                      onTap: () {
                        setState(() {
                          _selectedCountry = country.countryName;
                          _selectedCity = null;
                          _allUniversities = []; // Clear current universities
                        });
                        Navigator.pop(context);
                        // Load universities for selected country using COUNTRY CODE
                        _loadUniversitiesForCountryCode(
                          country.countryCode,
                          country.countryName,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCityPicker() {
    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a country first')),
      );
      return;
    }

    final countryCode = UniversityApiService.getCountryCode(_selectedCountry!);
    if (countryCode == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid country selected')));
      return;
    }

    // Create the future for cities loading
    final citiesFuture = UniversityApiService.getEuropeanCities(countryCode);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(KConstants.radiusL),
        ),
      ),
      builder: (context) => FutureBuilder<List<String>>(
        future: citiesFuture,
        builder: (context, snapshot) {
          Widget content;

          if (snapshot.connectionState == ConnectionState.waiting) {
            content = const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            content = Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Failed to load cities: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: KConstants.paddingM),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final cities = snapshot.data!;
            if (cities.isEmpty) {
              content = const Center(child: Text('No cities found'));
            } else {
              content = Expanded(
                child: ListView.builder(
                  itemCount: cities.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(cities[index]),
                      onTap: () {
                        setState(() {
                          _selectedCity = cities[index];
                        });
                        Navigator.pop(context);
                        _applyFilters();
                      },
                    );
                  },
                ),
              );
            }
          } else {
            content = const Center(child: Text('No cities found'));
          }

          return Container(
            padding: const EdgeInsets.all(KConstants.paddingL),
            constraints: const BoxConstraints(maxHeight: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select City',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: KConstants.paddingL),
                content,
              ],
            ),
          );
        },
      ),
    );
  }

  // NEW: Load universities for selected country using COUNTRY CODE (WORKS FOR ALL COUNTRIES)
  // API Integration: Calls HEI /country/{code}/hei endpoint, parses to UniversityModel list
  Future<void> _loadUniversitiesForCountryCode(
    String countryCode,
    String countryName,
  ) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use getUniversitiesByCountryCode for non-EU countries, fallback to name-based for EU
      final universities =
          await UniversityApiService.getUniversitiesByCountryCode(countryCode);
      setState(() {
        _allUniversities = universities;
        _filteredUniversities = universities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
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
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(KConstants.paddingL),
              child: Column(
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: KConstants.paddingL),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        Text(
                          'Tuition Range',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: KConstants.paddingS),
                        Text(
                          'Program Type',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: KConstants.paddingS),
                        Text(
                          'Language',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
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
