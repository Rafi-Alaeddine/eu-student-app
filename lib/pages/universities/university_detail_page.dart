// lib/pages/universities/university_detail_page.dart
import '../../data/models/university_model.dart';
import 'package:dentistify/widgets/common/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/app_colors.dart';
import '../../core/constants/kconstants.dart';
import '../../services/university_api_service.dart';

class UniversityDetailPage extends StatefulWidget {
  final UniversityModel? university;
  const UniversityDetailPage({super.key, this.university});

  @override
  State<UniversityDetailPage> createState() => _UniversityDetailPageState();
}

class _UniversityDetailPageState extends State<UniversityDetailPage>
    with SingleTickerProviderStateMixin {
  // Access the passed university
  UniversityModel? get university => widget.university;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isFavorite = false;

  // Optional: Full HEI details from individual API endpoint
  Map<String, dynamic>? _fullHeidetails; // Store complete HEI response
  bool _isLoadingDetails = false; // Loading state for full details

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: KConstants.animationSlow,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Optional: Load full HEI details if university data is available
    if (university != null) {
      _loadFullHeidetails();
    }

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
    // Use real data if available, fallback to current content
    final displayName = university?.name ?? 'Technical University of Munich';
    final displayOfficialName = university?.officialName ?? displayName; // NEW
    final displayLocation = university != null
        ? '${university!.city}, ${university!.country}'
        : 'Munich, Germany';

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.darkPrimary, AppColors.darkAccent]
                            : AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.account_balance,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
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
                      // University Name - USE REAL NAME
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),

                      const SizedBox(height: KConstants.paddingS),

                      // Location - USE REAL LOCATION
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                          ),
                          const SizedBox(width: KConstants.paddingS),
                          Text(
                            displayLocation,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),

                      const SizedBox(height: KConstants.paddingL),

                      // Quick Stats - SHOW BLANK SPACES IF NOT AVAILABLE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            context,
                            Icons.people,
                            university?.numberOfStudents?.toString() ?? '',
                            'Students',
                          ),
                          _buildStatCard(
                            context,
                            Icons.school,
                            university?.programs != null &&
                                    university!.programs!.isNotEmpty
                                ? university!.programs!.length.toString()
                                : '',
                            'Programs',
                          ),
                          _buildStatCard(
                            context,
                            Icons.star,
                            university?.rating?.toStringAsFixed(1) ?? '',
                            'Rating',
                          ),
                        ],
                      ),

                      const SizedBox(height: KConstants.paddingXL),

                      // About Section - USE REAL DESCRIPTION
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: KConstants.paddingM),
                      Text(
                        university?.description ?? 'Information not available',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),

                      const SizedBox(height: KConstants.paddingXL),

                      // Programs Section - USE REAL PROGRAMS (ONLY SHOW IF AVAILABLE)
                      if (university?.programs != null &&
                          university!.programs!.isNotEmpty) ...[
                        Text(
                          'Programs',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: KConstants.paddingM),
                        ...university!.programs!.map(
                          (program) => _buildProgramCard(
                            context,
                            program,
                            'Degree Program', // Better to enhance this with real data
                          ),
                        ),
                      ],

                      const SizedBox(height: KConstants.paddingXL),

                      // Tuition & Fees - SHOW BLANK WHEN NOT AVAILABLE
                      Text(
                        'Tuition & Fees',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: KConstants.paddingM),
                      if (university != null &&
                          (university!.tuitionFeeMin != null ||
                              university!.tuitionFeeMax != null)) ...[
                        _buildInfoRow(
                          context,
                          'Tuition Range (per semester)',
                          university!.tuitionFeeMin != null &&
                                  university!.tuitionFeeMax != null
                              ? '€${university!.tuitionFeeMin!.toStringAsFixed(0)} - €${university!.tuitionFeeMax!.toStringAsFixed(0)}'
                              : '',
                        ),
                      ],
                      if (university != null &&
                          university!.applicationFee != null) ...[
                        _buildInfoRow(
                          context,
                          'Application Fee',
                          '€${university!.applicationFee!.toStringAsFixed(0)}',
                        ),
                      ],

                      const SizedBox(height: KConstants.paddingXL),

                      // Codes & Identifiers - SHOW NEW FIELDS
                      Text(
                        'Codes & Identifiers',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: KConstants.paddingM),
                      if (university?.erasmusCode != null &&
                          university!.erasmusCode!.isNotEmpty)
                        _buildInfoRow(
                          context,
                          'Erasmus Code',
                          university!.erasmusCode!,
                        ),
                      if (university?.picCode != null &&
                          university!.picCode!.isNotEmpty)
                        _buildInfoRow(
                          context,
                          'PIC Code',
                          university!.picCode!,
                        ),
                      if (university?.erasmusCharterCode != null &&
                          university!.erasmusCharterCode!.isNotEmpty)
                        _buildInfoRow(
                          context,
                          'Erasmus Charter Code',
                          university!.erasmusCharterCode!,
                        ),
                      if (university?.abbreviation != null &&
                          university!.abbreviation!.isNotEmpty)
                        _buildInfoRow(
                          context,
                          'Abbreviation',
                          university!.abbreviation!,
                        ),

                      const SizedBox(height: KConstants.paddingXL),

                      // Status Information - SHOW NEW STATUS FIELDS
                      Text(
                        'Status Information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: KConstants.paddingM),
                      if (university?.status != null)
                        _buildInfoRow(
                          context,
                          'Status',
                          university!.status! ? 'Active' : 'Inactive',
                        ),
                      if (university?.isEcheHolder != null)
                        _buildInfoRow(
                          context,
                          'Erasmus Charter Holder',
                          university!.isEcheHolder! ? 'Yes' : 'No',
                        ),
                      if (university?.echeStartDate != null &&
                          university!.echeStartDate!.isNotEmpty)
                        _buildInfoRow(
                          context,
                          'Erasmus Charter Start',
                          university!.echeStartDate!,
                        ),
                      if (university?.echeEndDate != null &&
                          university!.echeEndDate!.isNotEmpty)
                        _buildInfoRow(
                          context,
                          'Erasmus Charter End',
                          university!.echeEndDate!,
                        ),

                      const SizedBox(height: KConstants.paddingXL),

                      // Contact Information - USE REAL CONTACT
                      Text(
                        'Contact Information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: KConstants.paddingM),
                      if (university?.website != null &&
                          university!.website.isNotEmpty)
                        _buildInfoRow(context, 'Website', university!.website),
                      if (university?.email != null &&
                          university!.email!.isNotEmpty)
                        _buildInfoRow(context, 'Email', university!.email!),
                      if (university?.phone != null &&
                          university!.phone!.isNotEmpty)
                        _buildInfoRow(context, 'Phone', university!.phone!),
                      if (university?.address != null &&
                          university!.address.isNotEmpty)
                        _buildInfoRow(context, 'Address', university!.address),

                      // Additional address details from mailing address
                      if (university?.recipientName != null &&
                          university!.recipientName!.isNotEmpty)
                        _buildInfoRow(
                          context,
                          'Recipient Name',
                          university!.recipientName!,
                        ),
                      if (university?.addressLine1 != null &&
                          university!.addressLine1!.isNotEmpty &&
                          university!.addressLine1 != university!.address)
                        _buildInfoRow(
                          context,
                          'Address Line 1',
                          university!.addressLine1!,
                        ),
                      if (university?.addressLine2 != null &&
                          university!.addressLine2!.isNotEmpty)
                        _buildInfoRow(
                          context,
                          'Address Line 2',
                          university!.addressLine2!,
                        ),
                      if (university?.region != null &&
                          university!.region!.isNotEmpty)
                        _buildInfoRow(context, 'Region', university!.region!),
                      if (university?.postalCode != null)
                        _buildInfoRow(
                          context,
                          'Postal Code',
                          university!.postalCode!,
                        ),
                      if (university?.locality != null)
                        _buildInfoRow(
                          context,
                          'Locality',
                          university!.locality!,
                        ),

                      const SizedBox(height: KConstants.paddingXL),

                      // Important Dates - SHOW NEW DATE FIELDS
                      Text(
                        'Important Dates',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: KConstants.paddingM),
                      if (university?.createdDate != null &&
                          university!.createdDate!.isNotEmpty)
                        _buildInfoRow(
                          context,
                          'Institution Created',
                          _formatDate(university!.createdDate!),
                        ),
                      if (university?.changedDate != null &&
                          university!.changedDate!.isNotEmpty)
                        _buildInfoRow(
                          context,
                          'Last Modified',
                          _formatDate(university!.changedDate!),
                        ),

                      const SizedBox(height: KConstants.paddingXL),

                      // Apply Button
                      CustomButton(
                        text: 'Visit university website',
                        onPressed: () {},
                        gradient: LinearGradient(
                          colors: isDark
                              ? [AppColors.darkPrimary, AppColors.darkAccent]
                              : AppColors.primaryGradient,
                        ),
                        icon: Icons.send,
                      ),

                      const SizedBox(height: KConstants.paddingL),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(KConstants.paddingS),
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

  Widget _buildProgramCard(BuildContext context, String title, String degree) {
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
        children: [
          Container(
            padding: const EdgeInsets.all(KConstants.paddingM),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                  .withValues(alpha: (0.1 * 255).round().toDouble()),
              borderRadius: BorderRadius.circular(KConstants.radiusS),
            ),
            child: Icon(
              Icons.school,
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            ),
          ),
          const SizedBox(width: KConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(degree, style: Theme.of(context).textTheme.bodyMedium),
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
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KConstants.paddingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: KConstants.paddingM),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.right,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Format date string for better display
  String _formatDate(String dateString) {
    try {
      // Parse the date (format: Y-m-d\TH:i:sP)
      final dateTime = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      // Format based on how recent
      if (difference.inDays < 1) {
        return 'Today ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks week${weeks == 1 ? '' : 's'} ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '$months month${months == 1 ? '' : 's'} ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return '$years year${years == 1 ? '' : 's'} ago';
      }
    } catch (e) {
      // Return original string if parsing fails
      return dateString;
    }
  }

  // Optional: Load complete HEI details from individual API endpoint
  Future<void> _loadFullHeidetails() async {
    setState(() => _isLoadingDetails = true);

    try {
      final heiId = university?.id; // hei_id like "istitutotoscanini.it"
      if (heiId != null) {
        // API call to get full individual HEI data
        final response = await http.get(
          Uri.parse('${UniversityApiService.heisApiUrl}/schac/$heiId/hei'),
          headers: {'Accept': 'application/vnd.api+json'},
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          // Store the complete attributes for additional display
          setState(() {
            _fullHeidetails =
                jsonResponse['data']['attributes'] as Map<String, dynamic>?;
            _isLoadingDetails = false;
          });
        } else {
          setState(() => _isLoadingDetails = false);
        }
      } else {
        setState(() => _isLoadingDetails = false);
      }
    } catch (e) {
      setState(() => _isLoadingDetails = false);
    }
  }
}
