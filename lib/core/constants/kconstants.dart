// User Feature Toggles - Control app features with single boolean changes
// THESE ARE THE MASTER SWITCHES FOR ALL MAJOR FEATURES
// Change to 'false' to disable any feature instantly (including API calls)
final Map<String, bool> kFeatureToggles = {
  // University Features
  'university_country_api_all_countries':
      true, // Use ALL 43 HEI API countries instead of 27 EU-only
  'university_city_filter_all_countries':
      true, // Allow city filtering for all countries, not just EU
  'university_advanced_search': true, // Enable advanced search functionality
  'university_favorites':
      true, // Enable favorite/unfavorite universities feature
  'university_gemini_ai_integration':
      false, // Experimental AI features (disabled for production)
  'university_rating_system': true, // Show star ratings and review counts
  'university_application_tracking':
      false, // Track application status (future feature)
  // Housing Features
  'housing_search_enabled': true, // Enable housing property search
  'housing_maps_integration': true, // Show housing on maps
  'housing_roommate_finder': false, // Roommate matching system
  'housing_price_filter': true, // Filter by rent prices
  'housing_photos_required': true, // Require photos for listings
  // Transport Features
  'transport_route_planner': true, // Public transport route planning
  'transport_live_updates': false, // Real-time arrival updates
  'transport_passes_integration': true, // Public transport pass purchasing
  'transport_bicycle_sharing': false, // Bike sharing integration
  // Community Features
  'community_events': true, // Events listing and RSVPs
  'community_forum': true, // Discussion forum
  'community_groups': false, // Interest-based groups
  'community_notifications': true, // Event/forum notifications
  // Study Life Features
  'studylife_banking': true, // Bank account guidance
  'studylife_healthcare': true, // Healthcare information
  'studylife_legal_docs': true, // Legal documents assistance
  'studylife_social_life': true, // Social activities and events
  // Emergency Features
  'emergency_contacts': true, // Emergency contact management
  'emergency_translations': true, // Emergency language translations
  'emergency_location_sharing': false, // Real-time location sharing
  // Language Features
  'language_helper_enabled': true, // Language learning tools
  'language_cultural_guides': true, // Cultural adaptation guides
  'language_translation_services': false, // Real-time translation
  // Weather Features
  'weather_forecasts': true, // Multi-day weather forecasts
  'weather_alerts': true, // Severe weather notifications
  'weather_integration_events': false, // Weather-based event recommendations
  // Document Features
  'document_scanner': true, // Scan and organize documents
  'document_ai_processing': false, // AI-powered document analysis
  'document_cloud_sync': true, // Cloud backup and sync
  // Finance Features
  'finance_budget_tracker': true, // Budget planning and tracking
  'finance_expense_tracker': true, // Expense logging
  'finance_scholarships': true, // Scholarship discovery
  'finance_currency_converter': true, // Currency conversion tool
  // General Features
  'push_notifications': true, // All push notification types
  'dark_mode': true, // Dark theme support
  'multiple_languages': true, // Multi-language support
  'analytics_tracking': false, // Usage analytics (privacy concern)
  'crash_reporting': true, // Error reporting for app stability
};

// Feature toggle helper functions
bool isFeatureEnabled(String featureName) {
  return kFeatureToggles[featureName] ?? false;
}

// University-specific toggles
bool get useAllCountriesInsteadOfEuOnly =>
    isFeatureEnabled('university_country_api_all_countries');

bool get enableCityFilterForAllCountries =>
    isFeatureEnabled('university_city_filter_all_countries');

bool get enableUniversityAdvancedSearch =>
    isFeatureEnabled('university_advanced_search');

bool get enableUniversityFavorites => isFeatureEnabled('university_favorites');

// Housing-specific toggles
bool get enableHousingSearch => isFeatureEnabled('housing_search_enabled');

bool get enableHousingMaps => isFeatureEnabled('housing_maps_integration');

// Transport-specific toggles
bool get enableTransportRoutePlanning =>
    isFeatureEnabled('transport_route_planner');

bool get enableTransportPasses =>
    isFeatureEnabled('transport_passes_integration');

// Community-specific toggles
bool get enableCommunityEvents => isFeatureEnabled('community_events');

bool get enableCommunityForum => isFeatureEnabled('community_forum');

// Study Life specific toggles
bool get enableStudyLifeBanking => isFeatureEnabled('studylife_banking');

bool get enableStudyLifeHealthcare => isFeatureEnabled('studylife_healthcare');

bool get enableStudyLifeLegal => isFeatureEnabled('studylife_legal_docs');

bool get enableStudyLifeSocial => isFeatureEnabled('studylife_social_life');

// Emergency specific toggles
bool get enableEmergencyContacts => isFeatureEnabled('emergency_contacts');

bool get enableEmergencyPage => isFeatureEnabled('emergency_page_enabled');

// Language specific toggles
bool get enableLanguageHelper => isFeatureEnabled('language_helper_enabled');

bool get enableLanguageCulturalGuides =>
    isFeatureEnabled('language_cultural_guides');

// Weather specific toggles
bool get enableWeatherForecasts => isFeatureEnabled('weather_forecasts');

// Document specific toggles
bool get enableDocumentScanner => isFeatureEnabled('document_scanner');

// Finance specific toggles
bool get enableBudgetTracker => isFeatureEnabled('finance_budget_tracker');

bool get enableExpenseTracker => isFeatureEnabled('finance_expense_tracker');

bool get enableScholarships => isFeatureEnabled('finance_scholarships');

// General toggles
bool get enablePushNotifications => isFeatureEnabled('push_notifications');

bool get enableDarkMode => isFeatureEnabled('dark_mode');

bool get enableMultipleLanguages => isFeatureEnabled('multiple_languages');

// =============================================================================
// ORIGINAL KCONSTANTS CLASS - DO NOT DELETE
// These constants are used throughout the app and cannot be removed
// =============================================================================

class KConstants {
  // Animation durations
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 800);
  static const Duration animationFast = Duration(milliseconds: 150);

  // Theme constants
  static const double radiusCircular = 8.0;
  static const double radiusS = 4.0;
  static const double radiusM = 12.0; // ADD: Medium radius
  static const double radiusL = 16.0;
  static const double radiusXL = 32.0;

  // Icon sizes
  static const double iconXS = 12.0;
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Padding constants
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 20.0;
  static const double paddingXL = 32.0;

  // European countries list
  static const List<String> euCountries = [
    'Austria',
    'Belgium',
    'Bulgaria',
    'Croatia',
    'Cyprus',
    'Czech Republic',
    'Denmark',
    'Estonia',
    'Finland',
    'France',
    'Germany',
    'Greece',
    'Hungary',
    'Ireland',
    'Italy',
    'Latvia',
    'Lithuania',
    'Luxembourg',
    'Malta',
    'Netherlands',
    'Poland',
    'Portugal',
    'Romania',
    'Slovakia',
    'Slovenia',
    'Spain',
    'Sweden',
  ];

  // University programs list
  static const List<String> universityPrograms = [
    'Bachelor of Arts',
    'Bachelor of Science',
    'Master of Arts',
    'Master of Science',
    'Doctor of Philosophy',
    'MBBS (Medicine)',
    'LLB (Law)',
    'MBA (Business)',
    'Engineering',
    'Architecture',
    'Design',
    'Nursing',
    'Dentistry',
  ];

  // Housing types
  static const List<String> housingTypes = [
    'Apartment',
    'House',
    'Room',
    'Studio',
    'Shared Housing',
    'Student Dormitory',
  ];

  // Transport types
  static const List<String> transportTypes = [
    'Bus',
    'Train',
    'Metro',
    'Tram',
    'Taxi',
    'Bike',
    'Car Sharing',
    'Walking',
  ];

  // Emergency contact categories
  static const List<String> emergencyCategories = [
    'Police',
    'Fire Department',
    'Medical Emergency',
    'Embassy',
    'University Security',
    'Local Authorities',
  ];

  // Language levels
  static const List<String> languageLevels = [
    'A1 - Beginner',
    'A2 - Elementary',
    'B1 - Intermediate',
    'B2 - Upper Intermediate',
    'C1 - Advanced',
    'C2 - Proficient',
  ];

  // Document types
  static const List<String> documentTypes = [
    'Passport',
    'Visa',
    'Student Card',
    'Bank Documents',
    'Health Insurance',
    'Residence Permit',
    'Academic Records',
  ];

  // Finance categories
  static const List<String> financeCategories = [
    'Tuition Fees',
    'Housing',
    'Food',
    'Transportation',
    'Entertainment',
    'Healthcare',
    'Utilities',
    'Textbooks',
    'Miscellaneous',
  ];

  // API endpoints
  static const String baseUrl = 'YOUR_API_BASE_URL';

  // Map zoom levels
  static const double mapZoomLevel = 15.0;
  static const double mapZoomLevelCity = 12.0;
  static const double mapZoomLevelCountry = 6.0;

  // Image quality settings
  static const double imageQualityHigh = 1.0;
  static const double imageQualityMedium = 0.8;
  static const double imageQualityLow = 0.6;

  // Text field limits
  static const int maxTextLength = 500;
  static const int maxTitleLength = 100;
  static const int maxCommentLength = 200;

  // Grid item counts
  static const int gridCountSmall = 2;
  static const int gridCountMedium = 3;
  static const int gridCountLarge = 4;

  // Cache durations (in seconds)
  static const int cacheDurationShort = 300; // 5 minutes
  static const int cacheDurationMedium = 1800; // 30 minutes
  static const int cacheDurationLong = 3600; // 1 hour

  // Retry limits
  static const int maxRetryAttempts = 3;
  static const int retryDelaySeconds = 2;
}
