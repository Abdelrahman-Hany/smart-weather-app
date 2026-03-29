import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static const supportedLocales = [Locale('en'), Locale('ar')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localization = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localization != null, 'AppLocalizations not found in context.');
    return localization!;
  }

  bool get _isArabic => locale.languageCode == 'ar';

  String _tr(String en, String ar) => _isArabic ? ar : en;

  String get appTitle => _tr('Weather', 'الطقس');
  String get weather => _tr('Weather', 'الطقس');
  String get language => _tr('Language', 'اللغة');
  String get english => 'English';
  String get arabic => 'العربية';

  String get manageLocations => _tr('Manage locations', 'إدارة المواقع');
  String get searchCity => _tr('Search city', 'ابحث عن مدينة');
  String get loadingWeather => _tr('Loading weather...', 'جاري تحميل الطقس...');
  String get humidity => _tr('Humidity', 'الرطوبة');
  String get wind => _tr('Wind', 'الرياح');
  String get pressure => _tr('Pressure', 'الضغط');
  String get visibility => _tr('Visibility', 'مدى الرؤية');
  String get cloudiness => _tr('Cloudiness', 'الغيوم');
  String get feelsLike => _tr('Feels Like', 'المحسوسة');
  String get dataProvidedBy => _tr(
    'Data provided by OpenWeatherMap',
    'البيانات مقدمة من OpenWeatherMap',
  );
  String get useLocation => _tr('Use Location', 'استخدام الموقع');
  String get profile => _tr('Profile', 'الملف الشخصي');
  String get signIn => _tr('Sign In', 'تسجيل الدخول');
  String get aiOutfitAdvisor =>
      _tr('AI Outfit Advisor', 'مستشار الأزياء الذكي');
  String get pro => 'PRO';
  String get aiOutfitSubtitle =>
      _tr('What should I wear today?', 'ماذا يجب أن أرتدي اليوم؟');
  String get lowLabel => _tr('Low', 'الصغرى');

  String lowTemperature(int temp) => _tr('Low $temp°C.', 'الصغرى $temp°م.');

  String get deleteLocationsTitle => _tr('Delete locations', 'حذف المواقع');
  String removeLocationsContent(int count) => _tr(
    'Remove $count location${count > 1 ? 's' : ''}?',
    'حذف $count ${count == 1 ? 'موقع' : 'مواقع'}؟',
  );
  String get cancel => _tr('Cancel', 'إلغاء');
  String get delete => _tr('Delete', 'حذف');
  String get locationsInfo => _tr(
    'The location at the top of the list will be used to provide weather information in notifications and other connected services.',
    'سيتم استخدام الموقع الموجود أعلى القائمة لتوفير معلومات الطقس في الإشعارات والخدمات المتصلة الأخرى.',
  );
  String get select => _tr('Select', 'تحديد');
  String get selectAll => _tr('Select all', 'تحديد الكل');
  String selectedCount(int count) => _tr('$count selected', 'تم تحديد $count');
  String get updateCurrentLocation =>
      _tr('Update current location', 'تحديث الموقع الحالي');
  String get addCurrentLocation =>
      _tr('Add current location', 'إضافة الموقع الحالي');
  String get noLocationsSaved => _tr(
    'No locations saved yet.\nAdd a city or use your current location.',
    'لا توجد مواقع محفوظة بعد.\nأضف مدينة أو استخدم موقعك الحالي.',
  );
  String get removeLabel => _tr('Remove label', 'إزالة التسمية');
  String get editLabel => _tr('Edit label', 'تعديل التسمية');
  String get addLabel => _tr('Add label', 'إضافة تسمية');

  String get searchCityHint => _tr('Search city...', 'ابحث عن مدينة...');
  String get recentSearches => _tr('Recent Searches', 'عمليات البحث الأخيرة');
  String get popularCities => _tr('Popular Cities', 'المدن الشائعة');
  String searchForCity(String city) =>
      _tr('Search for "$city"', 'ابحث عن "$city"');

  String get createAccount => _tr('Create Account', 'إنشاء حساب');
  String get weatherPremium => _tr('Weather Premium', 'طقس بريميوم');
  String get createAccountUnlockPremium => _tr(
    'Create an account to unlock premium features',
    'أنشئ حسابًا لفتح الميزات المميزة',
  );
  String get signInAccessPremium => _tr(
    'Sign in to access your premium features',
    'سجّل الدخول للوصول إلى ميزاتك المميزة',
  );
  String get nameOptional => _tr('Name (optional)', 'الاسم (اختياري)');
  String get email => _tr('Email', 'البريد الإلكتروني');
  String get password => _tr('Password', 'كلمة المرور');
  String get pleaseEnterEmail =>
      _tr('Please enter your email', 'يرجى إدخال بريدك الإلكتروني');
  String get pleaseEnterValidEmail =>
      _tr('Please enter a valid email', 'يرجى إدخال بريد إلكتروني صحيح');
  String get pleaseEnterPassword =>
      _tr('Please enter your password', 'يرجى إدخال كلمة المرور');
  String get passwordMinLength => _tr(
    'Password must be at least 6 characters',
    'يجب أن تكون كلمة المرور 6 أحرف على الأقل',
  );
  String get alreadyHaveAccount =>
      _tr('Already have an account? Sign In', 'لديك حساب بالفعل؟ سجّل الدخول');
  String get dontHaveAccount =>
      _tr("Don't have an account? Sign Up", 'ليس لديك حساب؟ أنشئ حسابًا');
  String get continueWithGoogle =>
      _tr('Continue with Google', 'المتابعة باستخدام Google');
  String get continueAsGuest => _tr('Continue as Guest', 'المتابعة كضيف');

  String get guest => _tr('Guest', 'ضيف');
  String get user => _tr('User', 'مستخدم');
  String get guestAccount => _tr('Guest Account', 'حساب ضيف');
  String get guestAccountDescription => _tr(
    'Create an account to keep your data and access premium features.',
    'أنشئ حسابًا للحفاظ على بياناتك والوصول إلى الميزات المميزة.',
  );
  String get premiumBadge => _tr('PREMIUM', 'بريميوم');
  String get upgradeToPremium =>
      _tr('Upgrade to Premium', 'الترقية إلى بريميوم');
  String get premiumOutfitSubtitle => _tr(
    'Get AI-powered outfit recommendations',
    'احصل على توصيات أزياء مدعومة بالذكاء الاصطناعي',
  );
  String get appVersion => _tr('App Version', 'إصدار التطبيق');
  String get notSet => _tr('Not set', 'غير محدد');
  String get exitGuestMode => _tr('Exit Guest Mode', 'الخروج من وضع الضيف');
  String get signOut => _tr('Sign Out', 'تسجيل الخروج');

  String get premium => _tr('Premium', 'بريميوم');
  String get premiumMember =>
      _tr("You're a Premium member!", 'أنت عضو بريميوم!');
  String get unlockAiFeatures => _tr(
    'Unlock AI-powered features',
    'افتح الميزات المدعومة بالذكاء الاصطناعي',
  );
  String get premiumActive => _tr('Premium Active', 'اشتراك بريميوم نشط');
  String expiresDate(String formatted) =>
      _tr('Expires: $formatted', 'ينتهي في: $formatted');
  String get aiOutfitRecommendations =>
      _tr('AI Outfit Recommendations', 'توصيات أزياء ذكية');
  String get aiOutfitRecommendationsDesc => _tr(
    'Get smart clothing suggestions based on current weather conditions',
    'احصل على اقتراحات ملابس ذكية بناءً على ظروف الطقس الحالية',
  );
  String get shoppingLinks => _tr('Shopping Links', 'روابط التسوق');
  String get shoppingLinksDesc => _tr(
    'Find and buy recommended clothes from top retailers',
    'اعثر على الملابس المقترحة واشترها من أفضل المتاجر',
  );
  String get personalizedTips => _tr('Personalized Tips', 'نصائح مخصصة');
  String get personalizedTipsDesc => _tr(
    'Weather-based activity and wardrobe planning tips',
    'نصائح للأنشطة وتخطيط الملابس بناءً على الطقس',
  );
  String get signInRequired => _tr('Sign in required', 'تسجيل الدخول مطلوب');
  String get signInRequiredPremium => _tr(
    'You need to create an account before purchasing Premium.',
    'تحتاج إلى إنشاء حساب قبل شراء بريميوم.',
  );
  String get signInSignUp =>
      _tr('Sign In / Sign Up', 'تسجيل الدخول / إنشاء حساب');
  String get monthly => _tr('Monthly', 'شهري');
  String get yearly => _tr('Yearly', 'سنوي');
  String get restorePurchases => _tr('Restore Purchases', 'استعادة المشتريات');
  String get bestValue => _tr('BEST VALUE', 'أفضل قيمة');

  String get regenerate => _tr('Regenerate', 'إعادة الإنشاء');
  String get unknownError => _tr('Unknown error', 'خطأ غير معروف');
  String get aiAnalyzingWeather =>
      _tr('AI is analyzing the weather...', 'الذكاء الاصطناعي يحلل الطقس...');
  String get preparingRecommendations =>
      _tr('Preparing outfit recommendations', 'جاري تجهيز توصيات الملابس');
  String get recommendedOutfit => _tr('Recommended Outfit', 'الملابس المقترحة');
  String get weatherTips => _tr('Weather Tips', 'نصائح الطقس');
  String get shopThisItem => _tr('Shop this item', 'تسوق هذا العنصر');
  String weatherSummaryDetails(
    String description,
    int feelsLike,
    double wind,
  ) => _tr(
    '$description · Feels like $feelsLike°C · Wind ${wind.toStringAsFixed(1)} m/s',
    '$description · المحسوسة $feelsLike°م · الرياح ${wind.toStringAsFixed(1)} م/ث',
  );
  String get oopsSomethingWrong =>
      _tr('Oops! Something went wrong', 'عذرًا! حدث خطأ ما');
  String get tryAgain => _tr('Try Again', 'حاول مرة أخرى');

  String get signInRequiredTitle =>
      _tr('Sign In Required', 'تسجيل الدخول مطلوب');
  String get signInRequiredDescription => _tr(
    'Please sign in to access AI outfit recommendations.',
    'يرجى تسجيل الدخول للوصول إلى توصيات الأزياء الذكية.',
  );
  String get accountRequiredTitle => _tr('Account Required', 'الحساب مطلوب');
  String get accountRequiredDescription => _tr(
    'Guest accounts cannot access premium features.\nCreate an account to unlock AI outfit recommendations.',
    'حسابات الضيوف لا يمكنها الوصول إلى الميزات المميزة.\nأنشئ حسابًا لفتح توصيات الأزياء الذكية.',
  );
  String get premiumFeatureTitle => _tr('Premium Feature', 'ميزة بريميوم');
  String get premiumFeatureDescription => _tr(
    'AI outfit recommendations are available exclusively for Premium members.',
    'توصيات الأزياء الذكية متاحة حصريًا لأعضاء بريميوم.',
  );

  String get sunriseSunset => _tr('SUNRISE & SUNSET', 'الشروق والغروب');
  String get sunrise => _tr('Sunrise', 'الشروق');
  String get sunset => _tr('Sunset', 'الغروب');
  String get now => _tr('Now', 'الآن');
  String get today => _tr('Today', 'اليوم');
  String get tomorrowShort => _tr('Tmrw', 'غدًا');
  String get highShort => _tr('H', 'ع');
  String get lowShort => _tr('L', 'ص');
  String feelsLikeTemp(int temp) => _tr('Feels like $temp°', 'المحسوسة $temp°');

  String get humidityLow => _tr('Low', 'منخفضة');
  String get humidityComfortable => _tr('Comfortable', 'مريحة');
  String get humidityHumid => _tr('Humid', 'رطبة');
  String get humidityVeryHumid => _tr('Very humid', 'رطوبة عالية جدًا');

  String get visibilityClear => _tr('Clear', 'واضحة');
  String get visibilityModerate => _tr('Moderate', 'متوسطة');
  String get visibilityLow => _tr('Low', 'منخفضة');
  String get visibilityVeryLow => _tr('Very low', 'منخفضة جدًا');

  String get cloudClearSky => _tr('Clear sky', 'سماء صافية');
  String get cloudPartlyCloudy => _tr('Partly cloudy', 'غائم جزئيًا');
  String get cloudMostlyCloudy => _tr('Mostly cloudy', 'غائم في الغالب');
  String get cloudOvercast => _tr('Overcast', 'غيوم كثيفة');

  String get feelsSimilar => _tr('Similar to actual', 'مشابهة للحقيقية');
  String get feelsWarmer => _tr('Warmer than actual', 'أدفأ من الحقيقية');
  String get feelsCooler => _tr('Cooler than actual', 'أبرد من الحقيقية');

  String get editCustomLabel => _tr('Edit custom label', 'تعديل تسمية مخصصة');
  String get addCustomLabel => _tr('Add a custom label', 'إضافة تسمية مخصصة');
  String get save => _tr('Save', 'حفظ');
  String get add => _tr('Add', 'إضافة');
  String localizePresetLabel(String label) {
    switch (label) {
      case 'Home':
        return _tr('Home', 'المنزل');
      case 'Office':
        return _tr('Office', 'العمل');
      case 'School':
        return _tr('School', 'المدرسة');
      default:
        return label;
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
