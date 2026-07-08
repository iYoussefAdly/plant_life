import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Plant Life'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Smart Plant Monitoring'**
  String get appTagline;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @errUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get errUnexpected;

  /// No description provided for @errTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Please try again.'**
  String get errTimeout;

  /// No description provided for @errNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get errNoInternet;

  /// No description provided for @errCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request was cancelled.'**
  String get errCancelled;

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errGeneric;

  /// No description provided for @errInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid server response. Please try again.'**
  String get errInvalidResponse;

  /// No description provided for @errLoadDashboard.
  ///
  /// In en, this message translates to:
  /// **'Failed to load dashboard data'**
  String get errLoadDashboard;

  /// No description provided for @errLoadSensors.
  ///
  /// In en, this message translates to:
  /// **'Failed to load sensor data'**
  String get errLoadSensors;

  /// No description provided for @errNoCheckoutUrl.
  ///
  /// In en, this message translates to:
  /// **'No checkout URL was returned.'**
  String get errNoCheckoutUrl;

  /// No description provided for @errStoreSession.
  ///
  /// In en, this message translates to:
  /// **'Could not start a store session.'**
  String get errStoreSession;

  /// No description provided for @errInvalidTask.
  ///
  /// In en, this message translates to:
  /// **'Invalid task reference'**
  String get errInvalidTask;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String timeMinutesAgo(int minutes);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String timeHoursAgo(int hours);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String timeDaysAgo(int days);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSensors.
  ///
  /// In en, this message translates to:
  /// **'Sensors'**
  String get navSensors;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @navTreatments.
  ///
  /// In en, this message translates to:
  /// **'Treatments'**
  String get navTreatments;

  /// No description provided for @navStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get navStore;

  /// No description provided for @onbSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onbSkip;

  /// No description provided for @onbNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onbNext;

  /// No description provided for @onbGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onbGetStarted;

  /// No description provided for @onb1Title.
  ///
  /// In en, this message translates to:
  /// **'AI Disease Detection'**
  String get onb1Title;

  /// No description provided for @onb1Body.
  ///
  /// In en, this message translates to:
  /// **'Snap a photo of your plant and our AI instantly spots diseases and measures their severity.'**
  String get onb1Body;

  /// No description provided for @onb2Title.
  ///
  /// In en, this message translates to:
  /// **'Guided Treatment Plans'**
  String get onb2Title;

  /// No description provided for @onb2Body.
  ///
  /// In en, this message translates to:
  /// **'Turn every diagnosis into a day-by-day treatment plan with reminders, progress tracking, and recovery rescans.'**
  String get onb2Body;

  /// No description provided for @onb3Title.
  ///
  /// In en, this message translates to:
  /// **'Sensors & Live Monitoring'**
  String get onb3Title;

  /// No description provided for @onb3Body.
  ///
  /// In en, this message translates to:
  /// **'Keep an eye on temperature, humidity, and soil moisture in real time — and get alerts before problems grow.'**
  String get onb3Body;

  /// No description provided for @onbChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get onbChooseLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to monitor your plants'**
  String get signInSubtitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start monitoring your plants today'**
  String get registerSubtitle;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @createAPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createAPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterYourFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullName;

  /// No description provided for @plantType.
  ///
  /// In en, this message translates to:
  /// **'Plant Type'**
  String get plantType;

  /// No description provided for @plantTypeTomato.
  ///
  /// In en, this message translates to:
  /// **'Tomato'**
  String get plantTypeTomato;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @pleaseEnterAPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterAPassword;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// No description provided for @passwordMinSix.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinSix;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @sensorOverview.
  ///
  /// In en, this message translates to:
  /// **'Sensor Overview'**
  String get sensorOverview;

  /// No description provided for @sensorsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 sensor} other{{count} sensors}}'**
  String sensorsCount(int count);

  /// No description provided for @todaysTasks.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Tasks'**
  String get todaysTasks;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get allCaughtUp;

  /// No description provided for @noTasksToday.
  ///
  /// In en, this message translates to:
  /// **'No treatment tasks scheduled for today.\nYour plants are in good hands 🌱'**
  String get noTasksToday;

  /// No description provided for @tasksDone.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} done'**
  String tasksDone(int completed, int total);

  /// No description provided for @sensorTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get sensorTemperature;

  /// No description provided for @sensorHumidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get sensorHumidity;

  /// No description provided for @sensorSoilMoisture.
  ///
  /// In en, this message translates to:
  /// **'Soil Moisture'**
  String get sensorSoilMoisture;

  /// No description provided for @sensorLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get sensorLight;

  /// No description provided for @statusNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get statusNormal;

  /// No description provided for @statusWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get statusWarning;

  /// No description provided for @statusCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get statusCritical;

  /// No description provided for @liveReadings.
  ///
  /// In en, this message translates to:
  /// **'Live Readings'**
  String get liveReadings;

  /// No description provided for @liveLabel.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get liveLabel;

  /// No description provided for @alertHistory.
  ///
  /// In en, this message translates to:
  /// **'Alert History'**
  String get alertHistory;

  /// No description provided for @noAlertsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No alerts recorded'**
  String get noAlertsRecorded;

  /// No description provided for @noAlertsRecordedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your sensors are operating within safe ranges'**
  String get noAlertsRecordedSubtitle;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @optimalRange.
  ///
  /// In en, this message translates to:
  /// **'Optimal Range'**
  String get optimalRange;

  /// No description provided for @minLabel.
  ///
  /// In en, this message translates to:
  /// **'Min: {value}'**
  String minLabel(String value);

  /// No description provided for @maxLabel.
  ///
  /// In en, this message translates to:
  /// **'Max: {value}'**
  String maxLabel(String value);

  /// No description provided for @updatedAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {ago}'**
  String updatedAgo(String ago);

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @connectYourDevice.
  ///
  /// In en, this message translates to:
  /// **'Connect your sensor device'**
  String get connectYourDevice;

  /// No description provided for @connectYourDeviceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your Device ID to start monitoring your plant\'s environment in real time.'**
  String get connectYourDeviceSubtitle;

  /// No description provided for @deviceIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Device ID'**
  String get deviceIdLabel;

  /// No description provided for @deviceIdHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. DEVICE_ABC123'**
  String get deviceIdHint;

  /// No description provided for @connectDevice.
  ///
  /// In en, this message translates to:
  /// **'Connect device'**
  String get connectDevice;

  /// No description provided for @deviceIdHelp.
  ///
  /// In en, this message translates to:
  /// **'You\'ll find the Device ID on your sensor device.'**
  String get deviceIdHelp;

  /// No description provided for @changeDevice.
  ///
  /// In en, this message translates to:
  /// **'Change device'**
  String get changeDevice;

  /// No description provided for @noReadingsYet.
  ///
  /// In en, this message translates to:
  /// **'No readings yet'**
  String get noReadingsYet;

  /// No description provided for @noReadingsYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sensor readings appear here once your device reports a warning or critical status.'**
  String get noReadingsYetSubtitle;

  /// No description provided for @connectSensorCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect your sensor'**
  String get connectSensorCardTitle;

  /// No description provided for @connectSensorCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your Device ID to monitor your plant and get live alerts.'**
  String get connectSensorCardSubtitle;

  /// No description provided for @connectSensorAction.
  ///
  /// In en, this message translates to:
  /// **'Connect Sensor'**
  String get connectSensorAction;

  /// No description provided for @browseSensorsAction.
  ///
  /// In en, this message translates to:
  /// **'Buy device'**
  String get browseSensorsAction;

  /// No description provided for @plantScanner.
  ///
  /// In en, this message translates to:
  /// **'Plant Scanner'**
  String get plantScanner;

  /// No description provided for @scanYourPlant.
  ///
  /// In en, this message translates to:
  /// **'Scan Your Plant'**
  String get scanYourPlant;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or upload an image to detect diseases'**
  String get scanHint;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @esp32.
  ///
  /// In en, this message translates to:
  /// **'ESP32'**
  String get esp32;

  /// No description provided for @esp32Cam.
  ///
  /// In en, this message translates to:
  /// **'ESP32-CAM'**
  String get esp32Cam;

  /// No description provided for @esp32ComingSoon.
  ///
  /// In en, this message translates to:
  /// **'ESP32 camera support is coming soon'**
  String get esp32ComingSoon;

  /// No description provided for @chooseImageSource.
  ///
  /// In en, this message translates to:
  /// **'Choose image source'**
  String get chooseImageSource;

  /// No description provided for @takeANewPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a new photo'**
  String get takeANewPhoto;

  /// No description provided for @uploadExistingImage.
  ///
  /// In en, this message translates to:
  /// **'Upload an existing image'**
  String get uploadExistingImage;

  /// No description provided for @captureFromPlantCamera.
  ///
  /// In en, this message translates to:
  /// **'Capture from your plant camera'**
  String get captureFromPlantCamera;

  /// No description provided for @analyzingPlant.
  ///
  /// In en, this message translates to:
  /// **'Analyzing plant...'**
  String get analyzingPlant;

  /// No description provided for @aiDetecting.
  ///
  /// In en, this message translates to:
  /// **'Our AI is detecting potential diseases'**
  String get aiDetecting;

  /// No description provided for @scanHistory.
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get scanHistory;

  /// No description provided for @viewScanHistory.
  ///
  /// In en, this message translates to:
  /// **'View Scan History'**
  String get viewScanHistory;

  /// No description provided for @diseasesFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 disease found} other{{count} diseases found}}'**
  String diseasesFound(int count);

  /// No description provided for @confidencePct.
  ///
  /// In en, this message translates to:
  /// **'{pct}% conf.'**
  String confidencePct(String pct);

  /// No description provided for @noScansYet.
  ///
  /// In en, this message translates to:
  /// **'No scans yet'**
  String get noScansYet;

  /// No description provided for @healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// No description provided for @diseaseDetected.
  ///
  /// In en, this message translates to:
  /// **'Disease Detected'**
  String get diseaseDetected;

  /// No description provided for @plantIsHealthy.
  ///
  /// In en, this message translates to:
  /// **'Plant is Healthy!'**
  String get plantIsHealthy;

  /// No description provided for @noSignsOfDisease.
  ///
  /// In en, this message translates to:
  /// **'No signs of disease were found in your plant.'**
  String get noSignsOfDisease;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @scanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get scanAgain;

  /// No description provided for @startTreatment.
  ///
  /// In en, this message translates to:
  /// **'Start Treatment'**
  String get startTreatment;

  /// No description provided for @treatmentAvailableHint.
  ///
  /// In en, this message translates to:
  /// **'A treatment plan is available for this diagnosis. Start it to track your daily tasks.'**
  String get treatmentAvailableHint;

  /// No description provided for @couldNotStartTreatment.
  ///
  /// In en, this message translates to:
  /// **'Could not start the treatment plan'**
  String get couldNotStartTreatment;

  /// No description provided for @treatmentPlan.
  ///
  /// In en, this message translates to:
  /// **'Treatment Plan'**
  String get treatmentPlan;

  /// No description provided for @noTreatmentPlansYet.
  ///
  /// In en, this message translates to:
  /// **'No treatment plans yet'**
  String get noTreatmentPlansYet;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @dailyTasks.
  ///
  /// In en, this message translates to:
  /// **'Daily Tasks'**
  String get dailyTasks;

  /// No description provided for @dayN.
  ///
  /// In en, this message translates to:
  /// **'Day {n}'**
  String dayN(int n);

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @keepPlan.
  ///
  /// In en, this message translates to:
  /// **'Keep plan'**
  String get keepPlan;

  /// No description provided for @cancelPlan.
  ///
  /// In en, this message translates to:
  /// **'Cancel plan'**
  String get cancelPlan;

  /// No description provided for @cancelPlanConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this treatment plan? This cannot be undone.'**
  String get cancelPlanConfirm;

  /// No description provided for @viewRecoveryProgress.
  ///
  /// In en, this message translates to:
  /// **'View Recovery Progress'**
  String get viewRecoveryProgress;

  /// No description provided for @unlocksOn.
  ///
  /// In en, this message translates to:
  /// **'Unlocks {date}'**
  String unlocksOn(String date);

  /// No description provided for @tasksProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} tasks'**
  String tasksProgress(int completed, int total);

  /// No description provided for @stepsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} steps completed'**
  String stepsCompleted(int completed, int total);

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @whyThisMatters.
  ///
  /// In en, this message translates to:
  /// **'Why this matters'**
  String get whyThisMatters;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// No description provided for @warnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get warnings;

  /// No description provided for @findProductsInStore.
  ///
  /// In en, this message translates to:
  /// **'Find products in Store'**
  String get findProductsInStore;

  /// No description provided for @searchInStore.
  ///
  /// In en, this message translates to:
  /// **'Search in Store'**
  String get searchInStore;

  /// No description provided for @noFurtherDetails.
  ///
  /// In en, this message translates to:
  /// **'No further details for this task.'**
  String get noFurtherDetails;

  /// No description provided for @recoveryProgress.
  ///
  /// In en, this message translates to:
  /// **'Recovery Progress'**
  String get recoveryProgress;

  /// No description provided for @recovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get recovery;

  /// No description provided for @rescanNow.
  ///
  /// In en, this message translates to:
  /// **'Rescan now'**
  String get rescanNow;

  /// No description provided for @rescanHistory.
  ///
  /// In en, this message translates to:
  /// **'Rescan History'**
  String get rescanHistory;

  /// No description provided for @noFollowUpScans.
  ///
  /// In en, this message translates to:
  /// **'No follow-up scans yet'**
  String get noFollowUpScans;

  /// No description provided for @rescanHint.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Rescan now\" to track your plant\'s recovery over time'**
  String get rescanHint;

  /// No description provided for @followUpScans.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 follow-up scan} other{{count} follow-up scans}}'**
  String followUpScans(int count);

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// No description provided for @noChange.
  ///
  /// In en, this message translates to:
  /// **'No change'**
  String get noChange;

  /// No description provided for @severityPercent.
  ///
  /// In en, this message translates to:
  /// **'Severity {percent}%'**
  String severityPercent(String percent);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @treatmentTaskDueToday.
  ///
  /// In en, this message translates to:
  /// **'Treatment task due today'**
  String get treatmentTaskDueToday;

  /// No description provided for @notifTreatmentReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Treatment reminder'**
  String get notifTreatmentReminderTitle;

  /// No description provided for @notifTreatmentReminderBody.
  ///
  /// In en, this message translates to:
  /// **'You have a treatment task due today.'**
  String get notifTreatmentReminderBody;

  /// No description provided for @unreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread} other{{count} unread}}'**
  String unreadCount(int count);

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @plantLifeMember.
  ///
  /// In en, this message translates to:
  /// **'Plant Life member'**
  String get plantLifeMember;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @logOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logOutConfirm;

  /// No description provided for @plantStore.
  ///
  /// In en, this message translates to:
  /// **'Plant Store'**
  String get plantStore;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products…'**
  String get searchProducts;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @filtered.
  ///
  /// In en, this message translates to:
  /// **'Filtered'**
  String get filtered;

  /// No description provided for @allProducts.
  ///
  /// In en, this message translates to:
  /// **'All products'**
  String get allProducts;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortPriceLowHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get sortPriceLowHigh;

  /// No description provided for @sortPriceHighLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get sortPriceHighLow;

  /// No description provided for @sortBestSelling.
  ///
  /// In en, this message translates to:
  /// **'Best Selling'**
  String get sortBestSelling;

  /// No description provided for @catTreatments.
  ///
  /// In en, this message translates to:
  /// **'Treatments'**
  String get catTreatments;

  /// No description provided for @catTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get catTools;

  /// No description provided for @catSeeds.
  ///
  /// In en, this message translates to:
  /// **'Seeds'**
  String get catSeeds;

  /// No description provided for @catFertilizers.
  ///
  /// In en, this message translates to:
  /// **'Fertilizers'**
  String get catFertilizers;

  /// No description provided for @catDevices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get catDevices;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @sale.
  ///
  /// In en, this message translates to:
  /// **'SALE'**
  String get sale;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @addedQtyToCart.
  ///
  /// In en, this message translates to:
  /// **'Added {qty} to cart'**
  String addedQtyToCart(int qty);

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get myCart;

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear cart'**
  String get clearCart;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @removeAllFromCart.
  ///
  /// In en, this message translates to:
  /// **'Remove all items from your cart?'**
  String get removeAllFromCart;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Browse the store and add some products'**
  String get cartEmptyHint;

  /// No description provided for @goToStore.
  ///
  /// In en, this message translates to:
  /// **'Go to Store'**
  String get goToStore;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// No description provided for @subtotalWithCount.
  ///
  /// In en, this message translates to:
  /// **'Subtotal ({count})'**
  String subtotalWithCount(int count);

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @shippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address'**
  String get shippingAddress;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @street.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @detailsOptional.
  ///
  /// In en, this message translates to:
  /// **'Details (optional)'**
  String get detailsOptional;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @cashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cashOnDelivery;

  /// No description provided for @payWhenArrives.
  ///
  /// In en, this message translates to:
  /// **'Pay when your order arrives'**
  String get payWhenArrives;

  /// No description provided for @payWithCardStripe.
  ///
  /// In en, this message translates to:
  /// **'Pay with Card (Stripe)'**
  String get payWithCardStripe;

  /// No description provided for @secureOnlinePayment.
  ///
  /// In en, this message translates to:
  /// **'Secure online payment'**
  String get secureOnlinePayment;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @shippingCalculated.
  ///
  /// In en, this message translates to:
  /// **'Shipping is calculated at checkout.'**
  String get shippingCalculated;

  /// No description provided for @couldNotOpenPayment.
  ///
  /// In en, this message translates to:
  /// **'Could not open the payment page'**
  String get couldNotOpenPayment;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @ordersAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your orders will appear here'**
  String get ordersAppearHere;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemsCount(int count);

  /// No description provided for @inStockCount.
  ///
  /// In en, this message translates to:
  /// **'{stock} in stock'**
  String inStockCount(int stock);

  /// No description provided for @startShopping.
  ///
  /// In en, this message translates to:
  /// **'Start Shopping'**
  String get startShopping;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderNumber(String id);

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @notPaid.
  ///
  /// In en, this message translates to:
  /// **'Not paid'**
  String get notPaid;

  /// No description provided for @cardPayment.
  ///
  /// In en, this message translates to:
  /// **'Card Payment'**
  String get cardPayment;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @cashOnDeliveryShort.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get cashOnDeliveryShort;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get statusProcessing;

  /// No description provided for @statusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get statusShipped;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How to use'**
  String get howToUse;

  /// No description provided for @activeIngredient.
  ///
  /// In en, this message translates to:
  /// **'Active ingredient'**
  String get activeIngredient;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @soldBy.
  ///
  /// In en, this message translates to:
  /// **'Sold by'**
  String get soldBy;

  /// No description provided for @perUnit.
  ///
  /// In en, this message translates to:
  /// **'per {unit}'**
  String perUnit(String unit);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
