// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'آٹو ٹیل فلیٹ';

  @override
  String get language => 'زبان';

  @override
  String get english => 'انگریزی';

  @override
  String get urdu => 'اردو';

  @override
  String get arabic => 'عربی';

  @override
  String get settings => 'سیٹنگز';

  @override
  String get logout => 'لاگ آؤٹ';

  @override
  String get logoutConfirmation => 'کیا آپ واقعی لاگ آؤٹ کرنا چاہتے ہیں؟';

  @override
  String get support => 'سپورٹ';

  @override
  String get password => 'پاس ورڈ';

  @override
  String get drivers => 'ڈرائیورز';

  @override
  String get alertSetting => 'الرٹ سیٹنگ';

  @override
  String get playAlertsAnnouncement => 'الرٹس کا اعلان چلائیں';

  @override
  String get appearance => 'ظاہری شکل';

  @override
  String get changePassword => 'پاس ورڈ تبدیل کریں';

  @override
  String get changePasswordSubtitle =>
      'پاس ورڈ تبدیل کرنے کے لیے پرانا اور نیا پاس ورڈ درج کریں';

  @override
  String get change => 'تبدیل کریں';

  @override
  String get cancel => 'منسوخ کریں';

  @override
  String get delete => 'حذف کریں';

  @override
  String get selectLanguage => 'زبان منتخب کریں';

  @override
  String get languageUpdated => 'زبان اپ ڈیٹ ہو گئی';

  @override
  String get galleryPermissionRequired => 'گیلری کی اجازت درکار ہے';

  @override
  String galleryPermissionMessage(Object platform) {
    return 'براہ کرم اس ایپ کے لیے $platform سے تصاویر تک رسائی کی اجازت دیں، پھر دوبارہ کوشش کریں۔';
  }

  @override
  String get ok => 'ٹھیک ہے';

  @override
  String hiUser(Object email) {
    return 'ہیلو، $email';
  }

  @override
  String get hi => 'ہیلو';

  @override
  String get statusTab => 'اسٹیٹس';

  @override
  String get mapTab => 'نقشہ';

  @override
  String get dashboardTab => 'ڈیش بورڈ';

  @override
  String get alertsTab => 'الرٹس';

  @override
  String get settingsTab => 'سیٹنگز';

  @override
  String get managementTab => 'مینجمنٹ';

  @override
  String get backToAdmin => 'ایڈمن پر واپس جائیں';

  @override
  String get settingsTooltip => 'سیٹنگز';

  @override
  String get notificationsTooltip => 'نوٹیفکیشنز';

  @override
  String get customizeDashboard => 'ڈیش بورڈ کو حسبِ ضرورت بنائیں';

  @override
  String get edit => 'ترمیم';

  @override
  String get reset => 'ری سیٹ';

  @override
  String get dashboardCustomizeHint =>
      'کارڈز کی ترتیب بدلنے کے لیے ڈریگ کریں۔ کارڈ دکھانے یا چھپانے کے لیے سوئچ استعمال کریں۔';

  @override
  String get noDashboardCardsSelected =>
      'کوئی ڈیش بورڈ کارڈ منتخب نہیں ہے۔ کارڈ فعال کرنے کے لیے حسبِ ضرورت پر ٹیپ کریں۔';

  @override
  String errorLabel(Object error) {
    return 'خرابی: $error';
  }

  @override
  String get retry => 'دوبارہ کوشش کریں';

  @override
  String get searchVehicle => 'گاڑی تلاش کریں';

  @override
  String get allGroups => 'تمام گروپس';

  @override
  String get allVehicles => 'تمام گاڑیاں';

  @override
  String get viewAllVehicles => 'تمام گاڑیاں دیکھیں';

  @override
  String get vehicleStatusAll => 'تمام';

  @override
  String get vehicleStatusRunning => 'چل رہی';

  @override
  String get vehicleStatusStopped => 'رکی ہوئی';

  @override
  String get vehicleStatusIdle => 'آئیڈل';

  @override
  String get vehicleStatusOffline => 'آف لائن';

  @override
  String get vehicleStatusNoData => 'ڈیٹا نہیں';

  @override
  String get vehicleStatusExpired => 'میعاد ختم';

  @override
  String get vehicleStatusParked => 'پارک شدہ';

  @override
  String get vehicleStatusUnknown => 'نامعلوم';

  @override
  String get noVehiclesAvailable => 'کوئی گاڑی دستیاب نہیں۔';

  @override
  String get noAddressFound => 'کوئی پتہ نہیں ملا';

  @override
  String get noVehiclesInSelectedGroup =>
      'منتخب گروپ میں کوئی گاڑی دستیاب نہیں۔';

  @override
  String noVehiclesCurrentStatus(Object status) {
    return 'اس وقت کوئی گاڑی $status نہیں ہے۔';
  }

  @override
  String get speed => 'رفتار';

  @override
  String get update => 'اپ ڈیٹ';

  @override
  String get notAvailableShort => 'N/A';

  @override
  String get engineKilled => 'انجن بند کیا گیا';

  @override
  String get notificationsTitle => 'نوٹیفکیشنز';

  @override
  String get fromDate => 'شروع کی تاریخ';

  @override
  String get toDate => 'اختتامی تاریخ';

  @override
  String get deleteAlerts => 'الرٹس حذف کریں';

  @override
  String deleteAlertsConfirmation(Object count) {
    return '$count الرٹ حذف کریں؟';
  }

  @override
  String get searchNotification => 'نوٹیفکیشن تلاش کریں';

  @override
  String get noAlertsMatchSearch => 'آپ کی تلاش سے کوئی الرٹ نہیں ملا';

  @override
  String get noAlertsFound => 'کوئی الرٹ نہیں ملا';

  @override
  String get locationUnavailableForAlert =>
      'اس الرٹ کے لیے لوکیشن دستیاب نہیں ہے';

  @override
  String get alertsDeletedSuccessfully => 'الرٹس کامیابی سے حذف ہو گئے';

  @override
  String get noTime => 'وقت موجود نہیں';

  @override
  String get localReminders => 'لوکل یاددہانیاں';

  @override
  String get activeReminders => 'فعال یاددہانیاں';

  @override
  String get pastReminders => 'گزشتہ یاددہانیاں';

  @override
  String itemsCount(Object count) {
    return '$count آئٹمز';
  }

  @override
  String get deleteReminder => 'یاددہانی حذف کریں';

  @override
  String get deleteReminderConfirmation =>
      'کیا آپ واقعی اس یاددہانی کو حذف کرنا چاہتے ہیں؟';

  @override
  String get reminderDeleted => 'یاددہانی حذف ہو گئی';

  @override
  String get noRemindersFound => 'کوئی یاددہانی نہیں ملی';

  @override
  String get noDescription => 'کوئی تفصیل نہیں';

  @override
  String get repeatOneTime => 'ایک بار';

  @override
  String get repeatRecurring => 'بار بار';

  @override
  String get tasksAnalytics => 'ٹاسکس اینالیٹکس';

  @override
  String get seeMore => 'مزید دیکھیں';

  @override
  String get noTasksAvailable => 'کوئی ٹاسک دستیاب نہیں';

  @override
  String get latestTasks => 'تازہ ترین ٹاسکس';

  @override
  String get taskFunnel => 'ٹاسک فنل';

  @override
  String get taskNew => 'نیا';

  @override
  String get taskInProgress => 'جاری';

  @override
  String get taskCompleted => 'مکمل';

  @override
  String get taskFailed => 'ناکام';

  @override
  String get completionRate => 'تکمیل کی شرح';

  @override
  String get failureRate => 'ناکامی کی شرح';

  @override
  String tasksCountSummary(Object count, Object total) {
    return '$total میں سے $count ٹاسکس';
  }

  @override
  String get unstartedTaskAging => 'غیر شروع شدہ ٹاسکس کی عمر';

  @override
  String get inProgressAging => 'جاری ٹاسکس کی عمر';

  @override
  String get tasksNotCompletedWithin10Days =>
      '10 دن میں مکمل نہ ہونے والے ٹاسکس';

  @override
  String get vehicleWorkloadDistribution => 'گاڑیوں کے کام کا بوجھ';

  @override
  String get noVehicleWorkloadData =>
      'گاڑیوں کے کام کے بوجھ کا کوئی ڈیٹا دستیاب نہیں';

  @override
  String get share => 'شیئر';

  @override
  String get export => 'ایکسپورٹ';

  @override
  String get refresh => 'ریفریش';

  @override
  String get maintenanceReminder => 'مینٹیننس یاددہانی';

  @override
  String get allMaintenance => 'تمام مینٹیننس';

  @override
  String get dueMaintenance => 'واجب مینٹیننس';

  @override
  String get overdueMaintenance => 'بقایا مینٹیننس';

  @override
  String get overdue => 'بقایا';

  @override
  String get maintenanceAnalytics => 'مینٹیننس اینالیٹکس';

  @override
  String get healthScore => 'ہیلتھ اسکور';

  @override
  String healthyStateSummary(Object ok, Object total) {
    return '$total میں سے $ok صحت مند حالت میں';
  }

  @override
  String get dueSoon => 'جلد واجب';

  @override
  String overdueCountLabel(Object count) {
    return 'بقایا: $count';
  }

  @override
  String get dueSoonWindows => 'جلد واجب ونڈوز';

  @override
  String dueInNextDays(Object days) {
    return 'اگلے $days دن میں واجب';
  }

  @override
  String get overdueByType => 'قسم کے حساب سے بقایا';

  @override
  String get topOverdueServices => 'اہم بقایا سروسز';

  @override
  String get topVehiclesByOverdue => 'سب سے زیادہ بقایا گاڑیاں';

  @override
  String get nextDueByLeftValue => 'باقی ویلیو کے حساب سے اگلا واجب';

  @override
  String get upcomingCalendar => 'آنے والا کیلنڈر';

  @override
  String get criticalMaintenanceAlerts => 'اہم مینٹیننس الرٹس';

  @override
  String get noOverdueVehicles => 'کوئی بقایا گاڑی نہیں';

  @override
  String get noUpcomingByLeft => 'باقی ویلیو کے حساب سے کچھ نہیں';

  @override
  String get noUpcomingDates => 'کوئی آنے والی تاریخ نہیں';

  @override
  String get noCriticalMaintenanceAlerts => 'کوئی اہم مینٹیننس الرٹ نہیں';

  @override
  String get fuelPrices => 'ایندھن کی قیمتیں';

  @override
  String get petrol => 'پیٹرول';

  @override
  String get diesel => 'ڈیزل';

  @override
  String get lastUpdated => 'آخری اپ ڈیٹ';

  @override
  String get offlineOver24Hours => '24 گھنٹے سے زیادہ آف لائن';

  @override
  String get noVehiclesOffline24h => '24 گھنٹے سے زیادہ کوئی گاڑی آف لائن نہیں';

  @override
  String get expenseAnalytics => 'خرچ اینالیٹکس';

  @override
  String get expenseTrend => 'خرچ کا رجحان';

  @override
  String get topExpenseTypes => 'سب سے بڑی خرچ اقسام';

  @override
  String get topVehiclesByExpense => 'خرچ کے حساب سے اہم گاڑیاں';

  @override
  String get recentExpenseActivity => 'حالیہ خرچ سرگرمی';

  @override
  String get noTypeData => 'قسم کا کوئی ڈیٹا نہیں';

  @override
  String get thisMonth => 'اس ماہ';

  @override
  String get lastMonth => 'پچھلا ماہ';

  @override
  String get changeLabel => 'تبدیلی';

  @override
  String get totalRange => 'کل (رینج)';

  @override
  String get avgPerTxn => 'اوسط / ٹرانزیکشن';

  @override
  String get avgPerDay => 'اوسط / دن';

  @override
  String get noTrendData => 'رجحان کا کوئی ڈیٹا نہیں';

  @override
  String get performanceAnalytics => 'پرفارمنس اینالیٹکس';

  @override
  String get vehicles => 'گاڑیاں';

  @override
  String get scoredFromAlerts => 'الرٹس سے اسکور کیا گیا';

  @override
  String get mappedFromAssignment => 'موجودہ اسائنمنٹ سے منسلک';

  @override
  String get topVehicles => 'اہم گاڑیاں';

  @override
  String get topDrivers => 'اہم ڈرائیورز';

  @override
  String get allVehiclePerformance => 'تمام گاڑیوں کی پرفارمنس';

  @override
  String get allDriverPerformance => 'تمام ڈرائیورز کی پرفارمنس';

  @override
  String get noAlertsForDateRange =>
      'منتخب تاریخ کی حد کے لیے کوئی idle/overspeed الرٹ نہیں ملا۔';

  @override
  String get alertsCount => 'الرٹس کی تعداد';

  @override
  String get totalWord => 'کل';

  @override
  String totalLabel(Object count) {
    return 'کل: $count';
  }

  @override
  String get distanceTravelled => 'طے شدہ فاصلہ';

  @override
  String get totalDistance => 'کل فاصلہ';

  @override
  String get averageDistance => 'اوسط فاصلہ';

  @override
  String get topSpeedingVehicles => 'زیادہ رفتار والی نمایاں گاڑیاں';

  @override
  String get vehicleFallback => 'گاڑی';

  @override
  String get noMaintenanceItems => 'کوئی مینٹیننس آئٹم نہیں';

  @override
  String maintenanceNumber(Object index) {
    return 'مینٹیننس #$index';
  }

  @override
  String get vehicle => 'گاڑی';

  @override
  String get nameLabel => 'نام';

  @override
  String get typeLabel => 'قسم';

  @override
  String get unit => 'یونٹ';

  @override
  String get interval => 'وقفہ';

  @override
  String get lastService => 'آخری سروس';

  @override
  String get current => 'موجودہ';

  @override
  String get percent => 'فیصد';

  @override
  String get leftLabel => 'باقی';

  @override
  String get status => 'اسٹیٹس';

  @override
  String get expiresDate => 'اختتامی تاریخ';

  @override
  String get remindDate => 'یاددہانی کی تاریخ';

  @override
  String get daysTotalElapsed => 'دن (کل/گزرے)';

  @override
  String get daysLeft => 'باقی دن';

  @override
  String get description => 'تفصیل';

  @override
  String get unknownVehicle => 'نامعلوم گاڑی';

  @override
  String daysShort(Object days) {
    return '$days دن';
  }

  @override
  String daysOverdue(Object days) {
    return '$days دن بقایا';
  }

  @override
  String get none => 'کوئی نہیں';

  @override
  String get scopeAllVehicles => 'دائرہ: تمام گاڑیاں';

  @override
  String totalServices(Object count) {
    return 'کل سروسز: $count';
  }

  @override
  String get reportMaintenanceAnalytics => 'مینٹیننس اینالیٹکس رپورٹ';

  @override
  String get reportPerformanceAnalytics => 'پرفارمنس اینالیٹکس رپورٹ';

  @override
  String get reportOffline24h => '24 گھنٹے آف لائن رپورٹ';

  @override
  String generatedAt(Object value) {
    return 'تیار کیا گیا: $value';
  }

  @override
  String totalVehiclesReport(Object count) {
    return 'کل گاڑیاں: $count';
  }

  @override
  String offlineSinceDuration(Object vehicle, Object since, Object duration) {
    return '$vehicle | آف لائن از $since | دورانیہ: $duration';
  }

  @override
  String offlineOver24HoursWithCount(Object count) {
    return '24 گھنٹے سے زیادہ آف لائن ($count)';
  }

  @override
  String get noRecentActivity => 'کوئی حالیہ سرگرمی نہیں';

  @override
  String get liveTab => 'لائیو';

  @override
  String get analyticsTab => 'اینالیٹکس';

  @override
  String get reportTab => 'رپورٹ';

  @override
  String get historyTab => 'ہسٹری';

  @override
  String get alertsTabLong => 'الرٹس';

  @override
  String get infoTab => 'معلومات';

  @override
  String get vehicleOffline => 'گاڑی آف لائن ہے';

  @override
  String vehicleOfflineSince(Object time) {
    return 'گاڑی $time سے آف لائن ہے۔';
  }

  @override
  String get unknownTime => 'نامعلوم وقت';

  @override
  String get vehiclePlanExpired => 'گاڑی کا پلان ختم ہو گیا';

  @override
  String get vehiclePlanExpiredMessage =>
      'اس گاڑی کا پلان ختم ہو چکا ہے۔ براہ کرم اپنا پلان تجدید کریں اور اپنے سروس فراہم کنندہ سے رابطہ کریں۔';

  @override
  String get vehicleLocationUnavailable => 'گاڑی کی لوکیشن دستیاب نہیں ہے۔';

  @override
  String get unableOpenDirections => 'نقشے کی سمتیں نہیں کھولی جا سکیں۔';

  @override
  String get noLiveData => 'کوئی لائیو ڈیٹا نہیں';

  @override
  String get noVehicleDataAvailable =>
      'اس گاڑی کے لیے کوئی ڈیٹا دستیاب نہیں ہے۔';

  @override
  String get unableLoadTracking => 'ٹریکنگ لوڈ نہیں ہو سکی';

  @override
  String get locationUnavailable => 'لوکیشن دستیاب نہیں';

  @override
  String get liveLocationUnavailableVehicle =>
      'اس گاڑی کے لیے لائیو لوکیشن دستیاب نہیں ہے۔';

  @override
  String get yourLocation => 'آپ کی لوکیشن';

  @override
  String get vehicleSensors => 'گاڑی کے سینسرز';

  @override
  String sensorItemsCount(Object count) {
    return '$count آئٹمز';
  }

  @override
  String get noSensorsAvailable => 'کوئی سینسر دستیاب نہیں';

  @override
  String get driverAssignment => 'ڈرائیور اسائنمنٹ';

  @override
  String get alertAssign => 'الرٹ اسائن';

  @override
  String get maintenance => 'مینٹیننس';

  @override
  String get expenses => 'اخراجات';

  @override
  String get trackManageExpenses => 'اخراجات ٹریک اور منظم کریں';

  @override
  String get reminders => 'یاددہانیاں';

  @override
  String get complainVehicle => 'اس گاڑی کے بارے میں شکایت کریں';

  @override
  String get supportChatVehicle => 'اس گاڑی کے ساتھ سپورٹ چیٹ کھولیں';

  @override
  String get assign => 'اسائن';

  @override
  String get add => 'شامل کریں';

  @override
  String get complain => 'شکایت';

  @override
  String get seeDriver => 'ڈرائیور دیکھیں';

  @override
  String get noAlertAssigned => 'کوئی الرٹ اسائن نہیں';

  @override
  String get noUpcomingMaintenance => 'کوئی آنے والی مینٹیننس نہیں';

  @override
  String get viewAllExpenses => 'تمام اخراجات دیکھیں';

  @override
  String get noActiveReminders => 'کوئی فعال یاددہانی نہیں';

  @override
  String talkToSupportVehicle(Object vehicle) {
    return '$vehicle کے بارے میں سپورٹ سے بات کریں';
  }

  @override
  String get singleVehicleNoAlertsFound => 'کوئی الرٹ نہیں ملا';

  @override
  String get singleVehicleNoAlertsCategory => 'منتخب قسم کے لیے کوئی الرٹ نہیں';

  @override
  String get singleVehicleNoAlertsSearch => 'آپ کی تلاش سے کوئی الرٹ نہیں ملا';

  @override
  String get singleVehicleNoAlertsVehicle =>
      'اس گاڑی کے لیے کوئی الرٹ دستیاب نہیں';

  @override
  String get showAllAlerts => 'تمام الرٹس دکھائیں';

  @override
  String get oopsSomethingWrong => 'اوہ! کچھ غلط ہو گیا';

  @override
  String get tryAgain => 'دوبارہ کوشش کریں';

  @override
  String deleteAlertsConfirmCount(Object count) {
    return 'کیا آپ واقعی $count الرٹ حذف کرنا چاہتے ہیں؟';
  }

  @override
  String get failedDeleteAlerts => 'الرٹس حذف نہیں ہو سکے';

  @override
  String get close => 'بند کریں';

  @override
  String get alertsCategory => 'الرٹس کی اقسام';

  @override
  String get overSpeed => 'اوور اسپیڈ';

  @override
  String get idleDuration => 'آئیڈل دورانیہ';

  @override
  String get ignitionDuration => 'اگنیشن دورانیہ';

  @override
  String get moveStart => 'موو اسٹارٹ';

  @override
  String get offlineDuration => 'آف لائن دورانیہ';

  @override
  String get overParking => 'اوور پارکنگ';

  @override
  String get times => 'مرتبہ';

  @override
  String get loadingAlerts => 'الرٹس لوڈ ہو رہے ہیں...';

  @override
  String get vehicleInfo => 'گاڑی کی معلومات';

  @override
  String get averagePerLiter => 'اوسط فی لیٹر';

  @override
  String get engineType => 'انجن کی قسم';

  @override
  String get vehicleType => 'گاڑی کی قسم';

  @override
  String get updateVehicleInfo => 'گاڑی کی معلومات اپ ڈیٹ کریں';

  @override
  String get exampleAveragePerLiter => 'مثال: 11.00';

  @override
  String get selectEngineType => 'انجن کی قسم منتخب کریں';

  @override
  String get selectVehicleType => 'گاڑی کی قسم منتخب کریں';

  @override
  String get pleaseEnterValidAveragePerLiter =>
      'براہ کرم درست اوسط فی لیٹر درج کریں';

  @override
  String get save => 'محفوظ کریں';

  @override
  String get serviceAddedSuccessfully => 'سروس کامیابی سے شامل ہو گئی';

  @override
  String get expenseAddedSuccessfully => 'خرچ کامیابی سے شامل ہو گیا';

  @override
  String get singleActiveReminder => '1 فعال یاددہانی';

  @override
  String multipleActiveReminders(Object count) {
    return '$count فعال یاددہانیاں';
  }

  @override
  String get noPastReminders => 'کوئی پچھلی یاددہانی نہیں';

  @override
  String get singlePastReminder => '1 پچھلی یاددہانی';

  @override
  String multiplePastReminders(Object count) {
    return '$count پچھلی یاددہانیاں';
  }

  @override
  String get oldReminders => 'پرانی یاددہانیاں';

  @override
  String get noOldReminders => 'کوئی پرانی یاددہانی نہیں';

  @override
  String totalCurrencyRs(Object amount) {
    return 'کل: Rs $amount';
  }

  @override
  String fromValue(Object value) {
    return 'سے: $value';
  }

  @override
  String toValue(Object value) {
    return 'تک: $value';
  }

  @override
  String get clearDateFilter => 'تاریخ فلٹر صاف کریں';

  @override
  String get noExpensesRecorded => 'کوئی اخراجات ریکارڈ نہیں ہوئے';

  @override
  String get noServicesRecorded => 'کوئی سروس ریکارڈ نہیں ہوئی';

  @override
  String get deleteExpense => 'خرچ حذف کریں';

  @override
  String get deleteExpenseConfirmation =>
      'کیا آپ واقعی یہ خرچ حذف کرنا چاہتے ہیں؟';

  @override
  String get deleteService => 'سروس حذف کریں';

  @override
  String get deleteServiceConfirmation =>
      'کیا آپ واقعی یہ سروس حذف کرنا چاہتے ہیں؟';

  @override
  String get noName => 'کوئی نام نہیں';

  @override
  String nameValue(Object value) {
    return 'نام: $value';
  }

  @override
  String supplierValue(Object value) {
    return 'سپلائر: $value';
  }

  @override
  String amountCurrencyRs(Object amount) {
    return 'رقم: Rs $amount';
  }

  @override
  String expenseQtyUnitRow(Object date, Object qty, Object unit) {
    return '$date  •  مقدار: $qty  •  یونٹ: Rs $unit';
  }

  @override
  String serviceNumber(Object id) {
    return 'سروس #$id';
  }

  @override
  String typeValue(Object value) {
    return 'قسم: $value';
  }

  @override
  String intervalLastRow(Object interval, Object last) {
    return 'وقفہ: $interval  •  آخری: $last';
  }

  @override
  String expiresRemindRow(Object expires, Object remind) {
    return 'ختم: $expires  •  یاددہانی: $remind';
  }

  @override
  String currentOdometerEngineHoursRow(Object odometer, Object hours) {
    return 'موجودہ اوڈومیٹر: $odometer  •  انجن آورز: $hours';
  }

  @override
  String get daily => 'روزانہ';

  @override
  String get weekly => 'ہفتہ وار';

  @override
  String get monthly => 'ماہانہ';

  @override
  String get yearly => 'سالانہ';

  @override
  String get today => 'آج';

  @override
  String get yesterday => 'گزشتہ روز';

  @override
  String get last3Days => 'آخری 3 دن';

  @override
  String get last7Days => 'آخری 7 دن';

  @override
  String get custom => 'کسٹم';

  @override
  String get done => 'مکمل';

  @override
  String get selectDate => 'تاریخ منتخب کریں';

  @override
  String get selectTime => 'وقت منتخب کریں';

  @override
  String get fromDateCannotBeLaterThanToDate =>
      'شروع کی تاریخ اختتامی تاریخ سے بعد میں نہیں ہو سکتی';

  @override
  String get overview => 'جائزہ';

  @override
  String get loadingAnalytics => 'اینالیٹکس لوڈ ہو رہی ہے...';

  @override
  String get vehicleAnalytics => 'گاڑی کی اینالیٹکس';

  @override
  String get dateTimeRange => 'تاریخ اور وقت کی حد';

  @override
  String get startDateTime => 'شروع کی تاریخ اور وقت';

  @override
  String get endDateTime => 'اختتامی تاریخ اور وقت';

  @override
  String get chartsGroupedByDate => 'چارٹس تاریخ کے مطابق گروپ کیے گئے ہیں';

  @override
  String get chartsGroupedByHour => 'چارٹس گھنٹے کے مطابق گروپ کیے گئے ہیں';

  @override
  String get maximumSpeed => 'زیادہ سے زیادہ رفتار';

  @override
  String get driveTime => 'ڈرائیو ٹائم';

  @override
  String get stopTime => 'اسٹاپ ٹائم';

  @override
  String get fuelUsed => 'استعمال شدہ فیول';

  @override
  String get amountSpent => 'خرچ شدہ رقم';

  @override
  String get maxSpeedPerDay => 'روزانہ زیادہ سے زیادہ رفتار (km/h)';

  @override
  String get speedKmh => 'رفتار (km/h)';

  @override
  String get distancePerDay => 'روزانہ فاصلہ (km)';

  @override
  String get distanceKm => 'فاصلہ (km)';

  @override
  String get fuelUsedLiters => 'استعمال شدہ فیول (لیٹر)';

  @override
  String get stopDurationMinutes => 'اسٹاپ دورانیہ (منٹ)';

  @override
  String get engineHoursPerDay => 'روزانہ انجن آورز';

  @override
  String get engineHoursCumulative => 'انجن آورز (مجموعی)';

  @override
  String get noData => 'کوئی ڈیٹا نہیں';

  @override
  String get noDataAvailable => 'کوئی ڈیٹا دستیاب نہیں';

  @override
  String get liveTracking => 'لائیو ٹریکنگ';

  @override
  String updatedAt(Object value) {
    return 'اپ ڈیٹ وقت : $value';
  }

  @override
  String get traffic => 'ٹریفک';

  @override
  String vehicleLocationShare(Object url) {
    return 'گاڑی کی لوکیشن: $url';
  }

  @override
  String get moving => 'چل رہی ہے';

  @override
  String get callToDriver => 'ڈرائیور کو کال کریں';

  @override
  String get immobilizer => 'اموبلائزر';

  @override
  String get last30Days => 'آخری 30 دن';

  @override
  String get pleaseSelectDateRangeFirst =>
      'براہ کرم پہلے تاریخ کی حد منتخب کریں';

  @override
  String get fromTime => 'شروع کا وقت';

  @override
  String get toTime => 'اختتامی وقت';

  @override
  String get applyRange => 'حد لاگو کریں';

  @override
  String get fleetInsightTitle => 'فلیٹ اِن سائٹ AI';

  @override
  String get fleetStatusStable => 'مستحکم';

  @override
  String get fleetStatusNeedsAttention => 'توجہ درکار';

  @override
  String get fleetStatusCritical => 'انتہائی اہم';

  @override
  String get fleetInsightIntroPositive1 => 'آج فلیٹ کی کارکردگی مستحکم ہے۔';

  @override
  String get fleetInsightIntroPositive2 =>
      'اس وقت آپریشنز متوازن نظر آ رہے ہیں۔';

  @override
  String get fleetInsightIntroPositive3 => 'مجموعی رجحان فلیٹ کے لیے مثبت ہے۔';

  @override
  String get fleetInsightIntroWarning1 =>
      'فلیٹ کے ایک حصے کو توجہ کی ضرورت ہے۔';

  @override
  String get fleetInsightIntroWarning2 => 'کچھ اشارے ہدف سے ہٹ رہے ہیں۔';

  @override
  String get fleetInsightIntroWarning3 =>
      'موجودہ صورتحال معتدل آپریشنل دباؤ دکھا رہی ہے۔';

  @override
  String get fleetInsightIntroCritical1 =>
      'فلیٹ ہیلتھ کے لیے فوری کارروائی تجویز کی جاتی ہے۔';

  @override
  String get fleetInsightIntroCritical2 =>
      'موجودہ اشاریے زیادہ آپریشنل خطرہ ظاہر کر رہے ہیں۔';

  @override
  String get fleetInsightIntroCritical3 =>
      'اہم میٹرکس پر فوری فالو اَپ درکار ہے۔';

  @override
  String get fleetInsightAvailabilityTitle => 'دستیابی پر توجہ درکار ہے۔';

  @override
  String fleetInsightAvailabilityDetail(
      Object offlineNow, Object totalVehicles, Object offline24h) {
    return 'اس وقت $totalVehicles میں سے $offlineNow گاڑیاں آف لائن ہیں، جن میں $offline24h گاڑیاں 24 گھنٹے سے زیادہ آف لائن ہیں۔';
  }

  @override
  String get fleetInsightSafetyTitle => 'اوور اسپیڈ رویہ خطرہ بڑھا رہا ہے۔';

  @override
  String fleetInsightSafetyVehicleDetail(Object vehicleName, Object count) {
    return '$vehicleName پر $count اوور اسپیڈ الرٹس آئے، جو فلیٹ میں سب سے زیادہ ہیں۔';
  }

  @override
  String fleetInsightSafetyOverallDetail(Object overspeed, Object totalAlerts) {
    return 'کل $totalAlerts الرٹس میں سے $overspeed اوور اسپیڈ الرٹس ریکارڈ ہوئے۔';
  }

  @override
  String get fleetInsightMaintenanceTitle =>
      'مینٹیننس بیک لاگ تیاری کو متاثر کر رہا ہے۔';

  @override
  String fleetInsightMaintenanceDetail(Object dueCount) {
    return '$dueCount مینٹیننس آئٹمز اس وقت واجب یا بقایا ہیں۔';
  }

  @override
  String get fleetInsightTasksTitle => 'ٹاسک کی قطار کو متوازن کرنا ضروری ہے۔';

  @override
  String fleetInsightTasksDetail(Object taskBacklog, Object agingCount) {
    return '$taskBacklog ٹاسکس کھلے ہیں، جن میں $agingCount دو دن سے زیادہ پرانے ہیں۔';
  }

  @override
  String get fleetInsightPerformanceTitle =>
      'پرفارمنس اسکور بہتری کا مرکزی نقطہ ہے۔';

  @override
  String fleetInsightPerformanceDetail(Object score) {
    return 'منتخب مدت میں اوسط گاڑی پرفارمنس $score/100 ہے۔';
  }

  @override
  String get fleetInsightPerformanceLoading =>
      'حالیہ ڈیٹا سے پرفارمنس اینالیٹکس ابھی لوڈ ہو رہی ہے۔';

  @override
  String get fleetInsightExpenseTitle => 'اخراجات کا رجحان اہم نگرانی میں ہے۔';

  @override
  String fleetInsightExpenseDetail(Object amount, Object change) {
    return 'اس ماہ خرچ Rs $amount ہے اور ماہ بہ ماہ تبدیلی $change% ہے۔';
  }

  @override
  String get fleetInsightDistanceTitle =>
      'آج فاصلہ کا رجحان فعال نظر آ رہا ہے۔';

  @override
  String fleetInsightDistanceLeaderDetail(
      Object vehicleName, Object distanceKm) {
    return '$vehicleName نے آج $distanceKm کلومیٹر طے کیا، جو فلیٹ میں سب سے زیادہ ہے۔';
  }

  @override
  String fleetInsightDistanceTotalDetail(Object distanceKm) {
    return 'فلیٹ نے آج مجموعی طور پر $distanceKm کلومیٹر طے کیا۔';
  }

  @override
  String fleetInsightDistanceSpeedDetail(
      Object vehicleName, Object topSpeed, Object distanceKm) {
    return '$vehicleName نے $topSpeed km/h کی زیادہ سے زیادہ رفتار حاصل کی، جبکہ فلیٹ کا کل فاصلہ $distanceKm کلومیٹر ہے۔';
  }

  @override
  String fleetInsightDistanceAvgDetail(Object totalKm, Object avgKm) {
    return 'فلیٹ موومنٹ خلاصہ: کل $totalKm کلومیٹر اور اوسط $avgKm کلومیٹر۔';
  }

  @override
  String get fleetInsightMovementLoading => 'موومنٹ اینالیٹکس لوڈ ہو رہی ہے۔';

  @override
  String fleetInsightMovementSummary(Object totalKm, Object avgKm) {
    return 'فلیٹ نے آج $totalKm کلومیٹر طے کیا (اوسط $avgKm کلومیٹر فی گاڑی)۔';
  }

  @override
  String fleetInsightHealthChip(Object score) {
    return 'ہیلتھ $score/100';
  }

  @override
  String fleetInsightOnlineChip(Object count) {
    return 'آن لائن $count';
  }

  @override
  String fleetInsightOfflineChip(Object count) {
    return 'آف لائن $count';
  }

  @override
  String fleetInsightOverspeedChip(Object count) {
    return 'اوور اسپیڈ $count';
  }

  @override
  String fleetInsightMaintenanceChip(Object count) {
    return 'واجب مینٹیننس $count';
  }

  @override
  String fleetInsightOpenTasksChip(Object count) {
    return 'اوپن ٹاسکس $count';
  }

  @override
  String fleetInsightPerformanceChip(Object score) {
    return 'پرف $score/100';
  }

  @override
  String fleetInsightExpenseChip(Object change) {
    return 'اخراجات MoM $change%';
  }
}
