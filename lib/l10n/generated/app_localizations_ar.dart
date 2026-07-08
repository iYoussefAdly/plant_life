// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Plant Life';

  @override
  String get appTagline => 'مراقبة ذكية للنباتات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get requiredField => 'مطلوب';

  @override
  String get errUnexpected => 'حدث خطأ غير متوقع';

  @override
  String get errTimeout => 'انتهت مهلة الاتصال. حاول مرة أخرى.';

  @override
  String get errNoInternet => 'لا يوجد اتصال بالإنترنت.';

  @override
  String get errCancelled => 'تم إلغاء الطلب.';

  @override
  String get errGeneric => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get errInvalidResponse =>
      'استجابة غير صالحة من الخادم. حاول مرة أخرى.';

  @override
  String get errLoadDashboard => 'تعذر تحميل بيانات لوحة المعلومات';

  @override
  String get errLoadSensors => 'تعذر تحميل بيانات المستشعرات';

  @override
  String get errNoCheckoutUrl => 'لم يتم إرجاع رابط الدفع.';

  @override
  String get errStoreSession => 'تعذر بدء جلسة المتجر.';

  @override
  String get errInvalidTask => 'مرجع مهمة غير صالح';

  @override
  String get timeJustNow => 'الآن';

  @override
  String timeMinutesAgo(int minutes) {
    return 'منذ $minutes د';
  }

  @override
  String timeHoursAgo(int hours) {
    return 'منذ $hours س';
  }

  @override
  String timeDaysAgo(int days) {
    return 'منذ $days ي';
  }

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navSensors => 'المستشعرات';

  @override
  String get navScan => 'فحص';

  @override
  String get navTreatments => 'العلاجات';

  @override
  String get navStore => 'المتجر';

  @override
  String get onbSkip => 'تخطي';

  @override
  String get onbNext => 'التالي';

  @override
  String get onbGetStarted => 'ابدأ الآن';

  @override
  String get onb1Title => 'كشف الأمراض بالذكاء الاصطناعي';

  @override
  String get onb1Body =>
      'التقط صورة لنباتك وسيكتشف الذكاء الاصطناعي الأمراض فورًا ويقيس درجة شدتها.';

  @override
  String get onb2Title => 'خطط علاج موجَّهة';

  @override
  String get onb2Body =>
      'حوِّل كل تشخيص إلى خطة علاج يومية مع تذكيرات ومتابعة للتقدم وفحوصات متابعة للتعافي.';

  @override
  String get onb3Title => 'مستشعرات ومراقبة مباشرة';

  @override
  String get onb3Body =>
      'راقب درجة الحرارة والرطوبة ورطوبة التربة لحظيًا، واحصل على تنبيهات قبل تفاقم المشكلات.';

  @override
  String get onbChooseLanguage => 'اختر لغتك';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get language => 'اللغة';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String get signInSubtitle => 'سجّل الدخول لمراقبة نباتاتك';

  @override
  String get registerSubtitle => 'ابدأ مراقبة نباتاتك اليوم';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟ ';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get enterYourEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get enterYourPassword => 'أدخل كلمة المرور';

  @override
  String get createAPassword => 'أنشئ كلمة مرور';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get enterYourFullName => 'أدخل اسمك الكامل';

  @override
  String get plantType => 'نوع النبات';

  @override
  String get plantTypeTomato => 'طماطم';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get comingSoon => 'قريبًا';

  @override
  String get pleaseEnterEmail => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get pleaseEnterValidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get pleaseEnterPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get pleaseEnterAPassword => 'يرجى إدخال كلمة مرور';

  @override
  String get pleaseEnterName => 'يرجى إدخال اسمك';

  @override
  String get passwordMinSix => 'يجب ألا تقل كلمة المرور عن 6 أحرف';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get sensorOverview => 'نظرة عامة على المستشعرات';

  @override
  String sensorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مستشعرًا',
      few: '$count مستشعرات',
      two: 'مستشعران',
      one: 'مستشعر واحد',
    );
    return '$_temp0';
  }

  @override
  String get todaysTasks => 'مهام اليوم';

  @override
  String get alerts => 'التنبيهات';

  @override
  String get allCaughtUp => 'أنجزت كل المهام!';

  @override
  String get noTasksToday =>
      'لا توجد مهام علاج مجدولة اليوم.\nنباتاتك في أيدٍ أمينة 🌱';

  @override
  String tasksDone(int completed, int total) {
    return 'أُنجز $completed/$total';
  }

  @override
  String get sensorTemperature => 'درجة الحرارة';

  @override
  String get sensorHumidity => 'الرطوبة';

  @override
  String get sensorSoilMoisture => 'رطوبة التربة';

  @override
  String get sensorLight => 'الإضاءة';

  @override
  String get statusNormal => 'طبيعي';

  @override
  String get statusWarning => 'تحذير';

  @override
  String get statusCritical => 'حرج';

  @override
  String get liveReadings => 'قراءات مباشرة';

  @override
  String get liveLabel => 'مباشر';

  @override
  String get alertHistory => 'سجل التنبيهات';

  @override
  String get noAlertsRecorded => 'لا توجد تنبيهات مسجلة';

  @override
  String get noAlertsRecordedSubtitle => 'مستشعراتك تعمل ضمن النطاقات الآمنة';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get optimalRange => 'النطاق الأمثل';

  @override
  String minLabel(String value) {
    return 'الأدنى: $value';
  }

  @override
  String maxLabel(String value) {
    return 'الأقصى: $value';
  }

  @override
  String updatedAgo(String ago) {
    return 'آخر تحديث $ago';
  }

  @override
  String get resolved => 'تم الحل';

  @override
  String get connectYourDevice => 'اربط جهاز المستشعر';

  @override
  String get connectYourDeviceSubtitle =>
      'أدخل معرّف الجهاز لبدء مراقبة بيئة نباتك في الوقت الفعلي.';

  @override
  String get deviceIdLabel => 'معرّف الجهاز';

  @override
  String get deviceIdHint => 'مثال: DEVICE_ABC123';

  @override
  String get connectDevice => 'ربط الجهاز';

  @override
  String get deviceIdHelp => 'ستجد معرّف الجهاز على جهاز المستشعر الخاص بك.';

  @override
  String get changeDevice => 'تغيير الجهاز';

  @override
  String get noReadingsYet => 'لا توجد قراءات بعد';

  @override
  String get noReadingsYetSubtitle =>
      'تظهر قراءات المستشعرات هنا بمجرد أن يُبلغ جهازك عن حالة تحذير أو حرجة.';

  @override
  String get connectSensorCardTitle => 'اربط مستشعرك';

  @override
  String get connectSensorCardSubtitle =>
      'أضف معرّف جهازك لمراقبة نباتك وتلقّي التنبيهات الفورية.';

  @override
  String get connectSensorAction => 'ربط المستشعر';

  @override
  String get browseSensorsAction => 'اطلب جهاز الأن';

  @override
  String get plantScanner => 'فحص النبات';

  @override
  String get scanYourPlant => 'افحص نباتك';

  @override
  String get scanHint => 'التقط صورة أو ارفع صورة لاكتشاف الأمراض';

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get esp32 => 'ESP32';

  @override
  String get esp32Cam => 'ESP32-CAM';

  @override
  String get esp32ComingSoon => 'دعم كاميرا ESP32 قادم قريبًا';

  @override
  String get chooseImageSource => 'اختر مصدر الصورة';

  @override
  String get takeANewPhoto => 'التقط صورة جديدة';

  @override
  String get uploadExistingImage => 'ارفع صورة موجودة';

  @override
  String get captureFromPlantCamera => 'التقط من كاميرا النبات';

  @override
  String get analyzingPlant => 'جارٍ تحليل النبات...';

  @override
  String get aiDetecting => 'الذكاء الاصطناعي يبحث عن الأمراض المحتملة';

  @override
  String get scanHistory => 'سجل الفحوصات';

  @override
  String get viewScanHistory => 'عرض سجل الفحوصات';

  @override
  String diseasesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم العثور على $count مرضًا',
      few: 'تم العثور على $count أمراض',
      two: 'تم العثور على مرضين',
      one: 'تم العثور على مرض واحد',
    );
    return '$_temp0';
  }

  @override
  String confidencePct(String pct) {
    return 'دقة $pct٪';
  }

  @override
  String leavesDetected(int count) {
    return 'عدد الأوراق المكتشفة: $count';
  }

  @override
  String get noScansYet => 'لا توجد فحوصات بعد';

  @override
  String get healthy => 'سليم';

  @override
  String get diseaseDetected => 'تم اكتشاف مرض';

  @override
  String get plantIsHealthy => 'النبات سليم!';

  @override
  String get noSignsOfDisease => 'لم يتم العثور على أي علامات مرض في نباتك.';

  @override
  String get severity => 'الشدة';

  @override
  String get scanAgain => 'فحص جديد';

  @override
  String get startTreatment => 'بدء العلاج';

  @override
  String get treatmentAvailableHint =>
      'تتوفر خطة علاج لهذا التشخيص. ابدأها لمتابعة مهامك اليومية.';

  @override
  String get couldNotStartTreatment => 'تعذر بدء خطة العلاج';

  @override
  String get treatmentPlan => 'خطة العلاج';

  @override
  String get noTreatmentPlansYet => 'لا توجد خطط علاج بعد';

  @override
  String get progress => 'التقدم';

  @override
  String get dailyTasks => 'المهام اليومية';

  @override
  String dayN(int n) {
    return 'اليوم $n';
  }

  @override
  String get completed => 'مكتمل';

  @override
  String get active => 'نشط';

  @override
  String get cancelled => 'ملغي';

  @override
  String get keepPlan => 'الاحتفاظ بالخطة';

  @override
  String get cancelPlan => 'إلغاء الخطة';

  @override
  String get cancelPlanConfirm =>
      'هل أنت متأكد من إلغاء خطة العلاج هذه؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get viewRecoveryProgress => 'عرض تقدم التعافي';

  @override
  String unlocksOn(String date) {
    return 'يُفتح $date';
  }

  @override
  String tasksProgress(int completed, int total) {
    return '$completed من $total مهام';
  }

  @override
  String stepsCompleted(int completed, int total) {
    return 'اكتمل $completed من $total خطوات';
  }

  @override
  String get instructions => 'التعليمات';

  @override
  String get whyThisMatters => 'لماذا هذا مهم';

  @override
  String get tips => 'نصائح';

  @override
  String get warnings => 'تحذيرات';

  @override
  String get findProductsInStore => 'ابحث عن المنتجات في المتجر';

  @override
  String get searchInStore => 'ابحث في المتجر';

  @override
  String get noFurtherDetails => 'لا توجد تفاصيل إضافية لهذه المهمة.';

  @override
  String get recoveryProgress => 'تقدم التعافي';

  @override
  String get recovery => 'التعافي';

  @override
  String get rescanNow => 'إعادة الفحص الآن';

  @override
  String get rescanHistory => 'سجل إعادة الفحص';

  @override
  String get noFollowUpScans => 'لا توجد فحوصات متابعة بعد';

  @override
  String get rescanHint =>
      'اضغط \"إعادة الفحص الآن\" لمتابعة تعافي نباتك مع الوقت';

  @override
  String followUpScans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فحص متابعة',
      few: '$count فحوصات متابعة',
      two: 'فحصا متابعة',
      one: 'فحص متابعة واحد',
    );
    return '$_temp0';
  }

  @override
  String get latest => 'الأحدث';

  @override
  String get noChange => 'لا تغيير';

  @override
  String severityPercent(String percent) {
    return 'الشدة $percent٪';
  }

  @override
  String get notifications => 'الإشعارات';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get today => 'اليوم';

  @override
  String get earlier => 'سابقًا';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get treatmentTaskDueToday => 'مهمة علاج مستحقة اليوم';

  @override
  String get notifTreatmentReminderTitle => 'تذكير بالعلاج';

  @override
  String get notifTreatmentReminderBody => 'لديك مهمة علاج مستحقة اليوم.';

  @override
  String unreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count غير مقروء',
      few: '$count إشعارات غير مقروءة',
      two: 'إشعاران غير مقروءين',
      one: 'إشعار واحد غير مقروء',
    );
    return '$_temp0';
  }

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get name => 'الاسم';

  @override
  String get plantLifeMember => 'عضو Plant Life';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get logOutConfirm => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get plantStore => 'متجر النباتات';

  @override
  String get searchProducts => 'ابحث عن المنتجات…';

  @override
  String get all => 'الكل';

  @override
  String get filtered => 'مُصفّى';

  @override
  String get allProducts => 'كل المنتجات';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get sortNewest => 'الأحدث';

  @override
  String get sortPriceLowHigh => 'السعر: من الأقل إلى الأعلى';

  @override
  String get sortPriceHighLow => 'السعر: من الأعلى إلى الأقل';

  @override
  String get sortBestSelling => 'الأكثر مبيعًا';

  @override
  String get catTreatments => 'علاجات';

  @override
  String get catTools => 'أدوات';

  @override
  String get catSeeds => 'بذور';

  @override
  String get catFertilizers => 'أسمدة';

  @override
  String get catDevices => 'الأجهزة';

  @override
  String get noProductsFound => 'لم يتم العثور على منتجات';

  @override
  String get clearFilters => 'مسح عوامل التصفية';

  @override
  String get outOfStock => 'غير متوفر';

  @override
  String get sale => 'خصم';

  @override
  String get addedToCart => 'تمت الإضافة إلى السلة';

  @override
  String get addToCart => 'أضف إلى السلة';

  @override
  String addedQtyToCart(int qty) {
    return 'تمت إضافة $qty إلى السلة';
  }

  @override
  String get myCart => 'سلتي';

  @override
  String get clearCart => 'إفراغ السلة';

  @override
  String get clear => 'إفراغ';

  @override
  String get removeAllFromCart => 'هل تريد إزالة كل العناصر من سلتك؟';

  @override
  String get cartEmptyTitle => 'سلتك فارغة';

  @override
  String get cartEmptyHint => 'تصفح المتجر وأضف بعض المنتجات';

  @override
  String get goToStore => 'اذهب إلى المتجر';

  @override
  String get proceedToCheckout => 'إتمام الشراء';

  @override
  String subtotalWithCount(int count) {
    return 'الإجمالي الفرعي ($count)';
  }

  @override
  String get subtotal => 'الإجمالي الفرعي';

  @override
  String get total => 'الإجمالي';

  @override
  String get checkout => 'إتمام الطلب';

  @override
  String get shippingAddress => 'عنوان الشحن';

  @override
  String get city => 'المدينة';

  @override
  String get street => 'الشارع';

  @override
  String get phone => 'الهاتف';

  @override
  String get detailsOptional => 'تفاصيل (اختياري)';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get cashOnDelivery => 'الدفع عند الاستلام';

  @override
  String get payWhenArrives => 'ادفع عند وصول طلبك';

  @override
  String get payWithCardStripe => 'الدفع بالبطاقة (Stripe)';

  @override
  String get secureOnlinePayment => 'دفع إلكتروني آمن';

  @override
  String get placeOrder => 'تأكيد الطلب';

  @override
  String get shippingCalculated => 'تُحسب تكلفة الشحن عند إتمام الطلب.';

  @override
  String get couldNotOpenPayment => 'تعذر فتح صفحة الدفع';

  @override
  String get myOrders => 'طلباتي';

  @override
  String get noOrdersYet => 'لا توجد طلبات بعد';

  @override
  String get ordersAppearHere => 'ستظهر طلباتك هنا';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصرًا',
      few: '$count عناصر',
      two: 'عنصران',
      one: 'عنصر واحد',
    );
    return '$_temp0';
  }

  @override
  String inStockCount(int stock) {
    return '$stock متوفر بالمخزون';
  }

  @override
  String get startShopping => 'ابدأ التسوق';

  @override
  String orderNumber(String id) {
    return 'طلب #$id';
  }

  @override
  String get orderDetails => 'تفاصيل الطلب';

  @override
  String get items => 'العناصر';

  @override
  String get shipping => 'الشحن';

  @override
  String get paid => 'مدفوع';

  @override
  String get notPaid => 'غير مدفوع';

  @override
  String get cardPayment => 'دفع بالبطاقة';

  @override
  String get card => 'بطاقة';

  @override
  String get cashOnDeliveryShort => 'الدفع عند الاستلام';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusProcessing => 'قيد التجهيز';

  @override
  String get statusShipped => 'تم الشحن';

  @override
  String get statusDelivered => 'تم التوصيل';

  @override
  String get statusCancelled => 'ملغي';

  @override
  String get product => 'منتج';

  @override
  String get description => 'الوصف';

  @override
  String get howToUse => 'طريقة الاستخدام';

  @override
  String get activeIngredient => 'المادة الفعالة';

  @override
  String get brand => 'العلامة التجارية';

  @override
  String get soldBy => 'البائع';

  @override
  String perUnit(String unit) {
    return 'لكل $unit';
  }
}
