// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Plant Life';

  @override
  String get appTagline => 'Smart Plant Monitoring';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get requiredField => 'Required';

  @override
  String get errUnexpected => 'An unexpected error occurred';

  @override
  String get errTimeout => 'Connection timed out. Please try again.';

  @override
  String get errNoInternet => 'No internet connection.';

  @override
  String get errCancelled => 'Request was cancelled.';

  @override
  String get errGeneric => 'Something went wrong. Please try again.';

  @override
  String get errInvalidResponse => 'Invalid server response. Please try again.';

  @override
  String get errLoadDashboard => 'Failed to load dashboard data';

  @override
  String get errLoadSensors => 'Failed to load sensor data';

  @override
  String get errNoCheckoutUrl => 'No checkout URL was returned.';

  @override
  String get errStoreSession => 'Could not start a store session.';

  @override
  String get errInvalidTask => 'Invalid task reference';

  @override
  String get timeJustNow => 'just now';

  @override
  String timeMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String timeHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String timeDaysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navSensors => 'Sensors';

  @override
  String get navScan => 'Scan';

  @override
  String get navTreatments => 'Treatments';

  @override
  String get navStore => 'Store';

  @override
  String get onbSkip => 'Skip';

  @override
  String get onbNext => 'Next';

  @override
  String get onbGetStarted => 'Get Started';

  @override
  String get onb1Title => 'AI Disease Detection';

  @override
  String get onb1Body =>
      'Snap a photo of your plant and our AI instantly spots diseases and measures their severity.';

  @override
  String get onb2Title => 'Guided Treatment Plans';

  @override
  String get onb2Body =>
      'Turn every diagnosis into a day-by-day treatment plan with reminders, progress tracking, and recovery rescans.';

  @override
  String get onb3Title => 'Sensors & Live Monitoring';

  @override
  String get onb3Body =>
      'Keep an eye on temperature, humidity, and soil moisture in real time — and get alerts before problems grow.';

  @override
  String get onbChooseLanguage => 'Choose your language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get language => 'Language';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInSubtitle => 'Sign in to monitor your plants';

  @override
  String get registerSubtitle => 'Start monitoring your plants today';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get email => 'Email';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get password => 'Password';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get createAPassword => 'Create a password';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterYourFullName => 'Enter your full name';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get pleaseEnterAPassword => 'Please enter a password';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get passwordMinSix => 'Password must be at least 6 characters';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get sensorOverview => 'Sensor Overview';

  @override
  String sensorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sensors',
      one: '1 sensor',
    );
    return '$_temp0';
  }

  @override
  String get todaysTasks => 'Today\'s Tasks';

  @override
  String get alerts => 'Alerts';

  @override
  String get allCaughtUp => 'All caught up!';

  @override
  String get noTasksToday =>
      'No treatment tasks scheduled for today.\nYour plants are in good hands 🌱';

  @override
  String tasksDone(int completed, int total) {
    return '$completed/$total done';
  }

  @override
  String get sensorTemperature => 'Temperature';

  @override
  String get sensorHumidity => 'Humidity';

  @override
  String get sensorSoilMoisture => 'Soil Moisture';

  @override
  String get sensorLight => 'Light';

  @override
  String get statusNormal => 'Normal';

  @override
  String get statusWarning => 'Warning';

  @override
  String get statusCritical => 'Critical';

  @override
  String get liveReadings => 'Live Readings';

  @override
  String get liveLabel => 'LIVE';

  @override
  String get alertHistory => 'Alert History';

  @override
  String get noAlertsRecorded => 'No alerts recorded';

  @override
  String get optimalRange => 'Optimal Range';

  @override
  String minLabel(String value) {
    return 'Min: $value';
  }

  @override
  String maxLabel(String value) {
    return 'Max: $value';
  }

  @override
  String updatedAgo(String ago) {
    return 'Updated $ago';
  }

  @override
  String get resolved => 'Resolved';

  @override
  String get plantScanner => 'Plant Scanner';

  @override
  String get scanYourPlant => 'Scan Your Plant';

  @override
  String get scanHint => 'Take a photo or upload an image to detect diseases';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get esp32 => 'ESP32';

  @override
  String get esp32Cam => 'ESP32-CAM';

  @override
  String get esp32ComingSoon => 'ESP32 camera support is coming soon';

  @override
  String get chooseImageSource => 'Choose image source';

  @override
  String get takeANewPhoto => 'Take a new photo';

  @override
  String get uploadExistingImage => 'Upload an existing image';

  @override
  String get captureFromPlantCamera => 'Capture from your plant camera';

  @override
  String get analyzingPlant => 'Analyzing plant...';

  @override
  String get aiDetecting => 'Our AI is detecting potential diseases';

  @override
  String get scanHistory => 'Scan History';

  @override
  String get viewScanHistory => 'View Scan History';

  @override
  String diseasesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count diseases found',
      one: '1 disease found',
    );
    return '$_temp0';
  }

  @override
  String confidencePct(String pct) {
    return '$pct% conf.';
  }

  @override
  String get noScansYet => 'No scans yet';

  @override
  String get healthy => 'Healthy';

  @override
  String get diseaseDetected => 'Disease Detected';

  @override
  String get plantIsHealthy => 'Plant is Healthy!';

  @override
  String get noSignsOfDisease =>
      'No signs of disease were found in your plant.';

  @override
  String get severity => 'Severity';

  @override
  String get scanAgain => 'Scan Again';

  @override
  String get startTreatment => 'Start Treatment';

  @override
  String get treatmentAvailableHint =>
      'A treatment plan is available for this diagnosis. Start it to track your daily tasks.';

  @override
  String get couldNotStartTreatment => 'Could not start the treatment plan';

  @override
  String get treatmentPlan => 'Treatment Plan';

  @override
  String get noTreatmentPlansYet => 'No treatment plans yet';

  @override
  String get progress => 'Progress';

  @override
  String get dailyTasks => 'Daily Tasks';

  @override
  String dayN(int n) {
    return 'Day $n';
  }

  @override
  String get completed => 'Completed';

  @override
  String get active => 'Active';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get keepPlan => 'Keep plan';

  @override
  String get cancelPlan => 'Cancel plan';

  @override
  String get cancelPlanConfirm =>
      'Are you sure you want to cancel this treatment plan? This cannot be undone.';

  @override
  String get viewRecoveryProgress => 'View Recovery Progress';

  @override
  String unlocksOn(String date) {
    return 'Unlocks $date';
  }

  @override
  String tasksProgress(int completed, int total) {
    return '$completed of $total tasks';
  }

  @override
  String stepsCompleted(int completed, int total) {
    return '$completed of $total steps completed';
  }

  @override
  String get instructions => 'Instructions';

  @override
  String get whyThisMatters => 'Why this matters';

  @override
  String get tips => 'Tips';

  @override
  String get warnings => 'Warnings';

  @override
  String get findProductsInStore => 'Find products in Store';

  @override
  String get searchInStore => 'Search in Store';

  @override
  String get noFurtherDetails => 'No further details for this task.';

  @override
  String get recoveryProgress => 'Recovery Progress';

  @override
  String get recovery => 'Recovery';

  @override
  String get rescanNow => 'Rescan now';

  @override
  String get rescanHistory => 'Rescan History';

  @override
  String get noFollowUpScans => 'No follow-up scans yet';

  @override
  String get rescanHint =>
      'Tap \"Rescan now\" to track your plant\'s recovery over time';

  @override
  String followUpScans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count follow-up scans',
      one: '1 follow-up scan',
    );
    return '$_temp0';
  }

  @override
  String get latest => 'Latest';

  @override
  String get noChange => 'No change';

  @override
  String severityPercent(String percent) {
    return 'Severity $percent%';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get today => 'Today';

  @override
  String get earlier => 'Earlier';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get treatmentTaskDueToday => 'Treatment task due today';

  @override
  String get notifTreatmentReminderTitle => 'Treatment reminder';

  @override
  String get notifTreatmentReminderBody =>
      'You have a treatment task due today.';

  @override
  String unreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread',
      one: '1 unread',
    );
    return '$_temp0';
  }

  @override
  String get profile => 'Profile';

  @override
  String get name => 'Name';

  @override
  String get plantLifeMember => 'Plant Life member';

  @override
  String get logOut => 'Log out';

  @override
  String get logOutConfirm => 'Are you sure you want to log out?';

  @override
  String get plantStore => 'Plant Store';

  @override
  String get searchProducts => 'Search products…';

  @override
  String get all => 'All';

  @override
  String get filtered => 'Filtered';

  @override
  String get allProducts => 'All products';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortPriceLowHigh => 'Price: Low to High';

  @override
  String get sortPriceHighLow => 'Price: High to Low';

  @override
  String get sortBestSelling => 'Best Selling';

  @override
  String get catTreatments => 'Treatments';

  @override
  String get catTools => 'Tools';

  @override
  String get catSeeds => 'Seeds';

  @override
  String get catFertilizers => 'Fertilizers';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get sale => 'SALE';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String addedQtyToCart(int qty) {
    return 'Added $qty to cart';
  }

  @override
  String get myCart => 'My Cart';

  @override
  String get clearCart => 'Clear cart';

  @override
  String get clear => 'Clear';

  @override
  String get removeAllFromCart => 'Remove all items from your cart?';

  @override
  String get cartEmptyTitle => 'Your cart is empty';

  @override
  String get cartEmptyHint => 'Browse the store and add some products';

  @override
  String get goToStore => 'Go to Store';

  @override
  String get proceedToCheckout => 'Proceed to Checkout';

  @override
  String subtotalWithCount(int count) {
    return 'Subtotal ($count)';
  }

  @override
  String get subtotal => 'Subtotal';

  @override
  String get total => 'Total';

  @override
  String get checkout => 'Checkout';

  @override
  String get shippingAddress => 'Shipping Address';

  @override
  String get city => 'City';

  @override
  String get street => 'Street';

  @override
  String get phone => 'Phone';

  @override
  String get detailsOptional => 'Details (optional)';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get cashOnDelivery => 'Cash on Delivery';

  @override
  String get payWhenArrives => 'Pay when your order arrives';

  @override
  String get payWithCardStripe => 'Pay with Card (Stripe)';

  @override
  String get secureOnlinePayment => 'Secure online payment';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get shippingCalculated => 'Shipping is calculated at checkout.';

  @override
  String get couldNotOpenPayment => 'Could not open the payment page';

  @override
  String get myOrders => 'My Orders';

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String get ordersAppearHere => 'Your orders will appear here';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String inStockCount(int stock) {
    return '$stock in stock';
  }

  @override
  String get startShopping => 'Start Shopping';

  @override
  String orderNumber(String id) {
    return 'Order #$id';
  }

  @override
  String get orderDetails => 'Order Details';

  @override
  String get items => 'Items';

  @override
  String get shipping => 'Shipping';

  @override
  String get paid => 'Paid';

  @override
  String get notPaid => 'Not paid';

  @override
  String get cardPayment => 'Card Payment';

  @override
  String get card => 'Card';

  @override
  String get cashOnDeliveryShort => 'Cash on delivery';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusProcessing => 'Processing';

  @override
  String get statusShipped => 'Shipped';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get product => 'Product';

  @override
  String get description => 'Description';

  @override
  String get howToUse => 'How to use';

  @override
  String get activeIngredient => 'Active ingredient';

  @override
  String get brand => 'Brand';

  @override
  String get soldBy => 'Sold by';

  @override
  String perUnit(String unit) {
    return 'per $unit';
  }
}
