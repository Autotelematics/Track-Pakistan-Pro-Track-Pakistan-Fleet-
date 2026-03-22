// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'أوتوتيل فليت';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get urdu => 'الأردية';

  @override
  String get arabic => 'العربية';

  @override
  String get settings => 'الإعدادات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmation => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get support => 'الدعم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get drivers => 'السائقون';

  @override
  String get alertSetting => 'إعدادات التنبيه';

  @override
  String get playAlertsAnnouncement => 'تشغيل الإعلانات الصوتية للتنبيهات';

  @override
  String get appearance => 'المظهر';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get changePasswordSubtitle =>
      'أدخل كلمة المرور القديمة والجديدة لتغييرها';

  @override
  String get change => 'تغيير';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get languageUpdated => 'تم تحديث اللغة';

  @override
  String get galleryPermissionRequired => 'مطلوب إذن المعرض';

  @override
  String galleryPermissionMessage(Object platform) {
    return 'يرجى السماح بالوصول إلى الصور من $platform لهذا التطبيق ثم المحاولة مرة أخرى.';
  }

  @override
  String get ok => 'حسنًا';

  @override
  String hiUser(Object email) {
    return 'مرحبًا، $email';
  }

  @override
  String get hi => 'مرحبًا';

  @override
  String get statusTab => 'الحالة';

  @override
  String get mapTab => 'الخريطة';

  @override
  String get dashboardTab => 'لوحة التحكم';

  @override
  String get alertsTab => 'التنبيهات';

  @override
  String get settingsTab => 'الإعدادات';

  @override
  String get managementTab => 'الإدارة';

  @override
  String get backToAdmin => 'العودة إلى المدير';

  @override
  String get settingsTooltip => 'الإعدادات';

  @override
  String get notificationsTooltip => 'الإشعارات';

  @override
  String get customizeDashboard => 'تخصيص لوحة التحكم';

  @override
  String get edit => 'تعديل';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get dashboardCustomizeHint =>
      'اسحب لإعادة ترتيب البطاقات. استخدم المفتاح لإظهار أو إخفاء البطاقات.';

  @override
  String get noDashboardCardsSelected =>
      'لم يتم تحديد أي بطاقات للوحة التحكم. اضغط على تخصيص لتفعيل البطاقات.';

  @override
  String errorLabel(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get searchVehicle => 'ابحث عن مركبة';

  @override
  String get allGroups => 'كل المجموعات';

  @override
  String get allVehicles => 'كل المركبات';

  @override
  String get viewAllVehicles => 'عرض كل المركبات';

  @override
  String get vehicleStatusAll => 'الكل';

  @override
  String get vehicleStatusRunning => 'تعمل';

  @override
  String get vehicleStatusStopped => 'متوقفة';

  @override
  String get vehicleStatusIdle => 'خمول';

  @override
  String get vehicleStatusOffline => 'غير متصل';

  @override
  String get vehicleStatusNoData => 'لا توجد بيانات';

  @override
  String get vehicleStatusExpired => 'منتهي';

  @override
  String get vehicleStatusParked => 'متوقفة';

  @override
  String get vehicleStatusUnknown => 'غير معروف';

  @override
  String get noVehiclesAvailable => 'لا توجد مركبات متاحة.';

  @override
  String get noAddressFound => 'لم يتم العثور على عنوان';

  @override
  String get noVehiclesInSelectedGroup =>
      'لا توجد مركبات متاحة في المجموعة المحددة.';

  @override
  String noVehiclesCurrentStatus(Object status) {
    return 'لا توجد مركبات حالياً بحالة $status.';
  }

  @override
  String get speed => 'السرعة';

  @override
  String get update => 'التحديث';

  @override
  String get notAvailableShort => 'N/A';

  @override
  String get engineKilled => 'تم إيقاف المحرك';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get fromDate => 'من تاريخ';

  @override
  String get toDate => 'إلى تاريخ';

  @override
  String get deleteAlerts => 'حذف التنبيهات';

  @override
  String deleteAlertsConfirmation(Object count) {
    return 'حذف $count تنبيه(ات)؟';
  }

  @override
  String get searchNotification => 'ابحث في الإشعارات';

  @override
  String get noAlertsMatchSearch => 'لا توجد تنبيهات تطابق بحثك';

  @override
  String get noAlertsFound => 'لم يتم العثور على تنبيهات';

  @override
  String get locationUnavailableForAlert => 'الموقع غير متاح لهذا التنبيه';

  @override
  String get alertsDeletedSuccessfully => 'تم حذف التنبيهات بنجاح';

  @override
  String get noTime => 'لا يوجد وقت';

  @override
  String get localReminders => 'التذكيرات المحلية';

  @override
  String get activeReminders => 'التذكيرات النشطة';

  @override
  String get pastReminders => 'التذكيرات السابقة';

  @override
  String itemsCount(Object count) {
    return '$count عناصر';
  }

  @override
  String get deleteReminder => 'حذف التذكير';

  @override
  String get deleteReminderConfirmation =>
      'هل أنت متأكد أنك تريد حذف هذا التذكير؟';

  @override
  String get reminderDeleted => 'تم حذف التذكير';

  @override
  String get noRemindersFound => 'لم يتم العثور على تذكيرات';

  @override
  String get noDescription => 'لا يوجد وصف';

  @override
  String get repeatOneTime => 'مرة واحدة';

  @override
  String get repeatRecurring => 'متكرر';

  @override
  String get tasksAnalytics => 'تحليلات المهام';

  @override
  String get seeMore => 'عرض المزيد';

  @override
  String get noTasksAvailable => 'لا توجد مهام متاحة';

  @override
  String get latestTasks => 'أحدث المهام';

  @override
  String get taskFunnel => 'مسار المهام';

  @override
  String get taskNew => 'جديد';

  @override
  String get taskInProgress => 'قيد التنفيذ';

  @override
  String get taskCompleted => 'مكتمل';

  @override
  String get taskFailed => 'فشل';

  @override
  String get completionRate => 'معدل الإنجاز';

  @override
  String get failureRate => 'معدل الفشل';

  @override
  String tasksCountSummary(Object count, Object total) {
    return '$count من أصل $total مهمة';
  }

  @override
  String get unstartedTaskAging => 'تقادم المهام غير المبدوءة';

  @override
  String get inProgressAging => 'تقادم المهام قيد التنفيذ';

  @override
  String get tasksNotCompletedWithin10Days =>
      'المهام غير المكتملة خلال 10 أيام';

  @override
  String get vehicleWorkloadDistribution => 'توزيع عبء عمل المركبات';

  @override
  String get noVehicleWorkloadData => 'لا توجد بيانات عن عبء عمل المركبات';

  @override
  String get share => 'مشاركة';

  @override
  String get export => 'تصدير';

  @override
  String get refresh => 'تحديث';

  @override
  String get maintenanceReminder => 'تذكير الصيانة';

  @override
  String get allMaintenance => 'كل الصيانة';

  @override
  String get dueMaintenance => 'الصيانة المستحقة';

  @override
  String get overdueMaintenance => 'الصيانة المتأخرة';

  @override
  String get overdue => 'متأخر';

  @override
  String get maintenanceAnalytics => 'تحليلات الصيانة';

  @override
  String get healthScore => 'درجة الحالة';

  @override
  String healthyStateSummary(Object ok, Object total) {
    return '$ok من $total في حالة جيدة';
  }

  @override
  String get dueSoon => 'مستحق قريباً';

  @override
  String overdueCountLabel(Object count) {
    return 'متأخر: $count';
  }

  @override
  String get dueSoonWindows => 'فترات الاستحقاق القريب';

  @override
  String dueInNextDays(Object days) {
    return 'مستحق خلال $days أيام';
  }

  @override
  String get overdueByType => 'المتأخر حسب النوع';

  @override
  String get topOverdueServices => 'أهم الخدمات المتأخرة';

  @override
  String get topVehiclesByOverdue => 'أكثر المركبات تأخراً';

  @override
  String get nextDueByLeftValue => 'الاستحقاق التالي حسب القيمة المتبقية';

  @override
  String get upcomingCalendar => 'التقويم القادم';

  @override
  String get criticalMaintenanceAlerts => 'تنبيهات الصيانة الحرجة';

  @override
  String get noOverdueVehicles => 'لا توجد مركبات متأخرة';

  @override
  String get noUpcomingByLeft => 'لا توجد عناصر قادمة حسب المتبقي';

  @override
  String get noUpcomingDates => 'لا توجد تواريخ قادمة';

  @override
  String get noCriticalMaintenanceAlerts => 'لا توجد تنبيهات صيانة حرجة';

  @override
  String get fuelPrices => 'أسعار الوقود';

  @override
  String get petrol => 'بنزين';

  @override
  String get diesel => 'ديزل';

  @override
  String get lastUpdated => 'آخر تحديث';

  @override
  String get offlineOver24Hours => 'غير متصل لأكثر من 24 ساعة';

  @override
  String get noVehiclesOffline24h =>
      'لا توجد مركبات غير متصلة لأكثر من 24 ساعة';

  @override
  String get expenseAnalytics => 'تحليلات المصروفات';

  @override
  String get expenseTrend => 'اتجاه المصروفات';

  @override
  String get topExpenseTypes => 'أهم أنواع المصروفات';

  @override
  String get topVehiclesByExpense => 'أعلى المركبات حسب المصروفات';

  @override
  String get recentExpenseActivity => 'النشاط الأخير للمصروفات';

  @override
  String get noTypeData => 'لا توجد بيانات للأنواع';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get lastMonth => 'الشهر الماضي';

  @override
  String get changeLabel => 'التغيير';

  @override
  String get totalRange => 'الإجمالي (المدى)';

  @override
  String get avgPerTxn => 'المتوسط / معاملة';

  @override
  String get avgPerDay => 'المتوسط / يوم';

  @override
  String get noTrendData => 'لا توجد بيانات اتجاه';

  @override
  String get performanceAnalytics => 'تحليلات الأداء';

  @override
  String get vehicles => 'المركبات';

  @override
  String get scoredFromAlerts => 'تم التقييم من التنبيهات';

  @override
  String get mappedFromAssignment => 'تم الربط من التعيين الحالي';

  @override
  String get topVehicles => 'أفضل المركبات';

  @override
  String get topDrivers => 'أفضل السائقين';

  @override
  String get allVehiclePerformance => 'أداء كل المركبات';

  @override
  String get allDriverPerformance => 'أداء كل السائقين';

  @override
  String get noAlertsForDateRange =>
      'لم يتم العثور على تنبيهات idle/overspeed للفترة المحددة.';

  @override
  String get alertsCount => 'عدد التنبيهات';

  @override
  String get totalWord => 'الإجمالي';

  @override
  String totalLabel(Object count) {
    return 'الإجمالي: $count';
  }

  @override
  String get distanceTravelled => 'المسافة المقطوعة';

  @override
  String get totalDistance => 'إجمالي المسافة';

  @override
  String get averageDistance => 'متوسط المسافة';

  @override
  String get topSpeedingVehicles => 'أعلى المركبات سرعة';

  @override
  String get vehicleFallback => 'مركبة';

  @override
  String get noMaintenanceItems => 'لا توجد عناصر صيانة';

  @override
  String maintenanceNumber(Object index) {
    return 'الصيانة #$index';
  }

  @override
  String get vehicle => 'المركبة';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get typeLabel => 'النوع';

  @override
  String get unit => 'الوحدة';

  @override
  String get interval => 'الفاصل';

  @override
  String get lastService => 'آخر صيانة';

  @override
  String get current => 'الحالي';

  @override
  String get percent => 'النسبة';

  @override
  String get leftLabel => 'المتبقي';

  @override
  String get status => 'الحالة';

  @override
  String get expiresDate => 'تاريخ الانتهاء';

  @override
  String get remindDate => 'تاريخ التذكير';

  @override
  String get daysTotalElapsed => 'الأيام (الإجمالي/المنقضي)';

  @override
  String get daysLeft => 'الأيام المتبقية';

  @override
  String get description => 'الوصف';

  @override
  String get unknownVehicle => 'مركبة غير معروفة';

  @override
  String daysShort(Object days) {
    return '$days أيام';
  }

  @override
  String daysOverdue(Object days) {
    return '$days أيام متأخرة';
  }

  @override
  String get none => 'لا يوجد';

  @override
  String get scopeAllVehicles => 'النطاق: كل المركبات';

  @override
  String totalServices(Object count) {
    return 'إجمالي الخدمات: $count';
  }

  @override
  String get reportMaintenanceAnalytics => 'تقرير تحليلات الصيانة';

  @override
  String get reportPerformanceAnalytics => 'تقرير تحليلات الأداء';

  @override
  String get reportOffline24h => 'تقرير غير المتصل لأكثر من 24 ساعة';

  @override
  String generatedAt(Object value) {
    return 'تم الإنشاء: $value';
  }

  @override
  String totalVehiclesReport(Object count) {
    return 'إجمالي المركبات: $count';
  }

  @override
  String offlineSinceDuration(Object vehicle, Object since, Object duration) {
    return '$vehicle | غير متصل منذ $since | المدة: $duration';
  }

  @override
  String offlineOver24HoursWithCount(Object count) {
    return 'غير متصل لأكثر من 24 ساعة ($count)';
  }

  @override
  String get noRecentActivity => 'لا يوجد نشاط حديث';

  @override
  String get liveTab => 'مباشر';

  @override
  String get analyticsTab => 'التحليلات';

  @override
  String get reportTab => 'التقرير';

  @override
  String get historyTab => 'السجل';

  @override
  String get alertsTabLong => 'التنبيهات';

  @override
  String get infoTab => 'المعلومات';

  @override
  String get vehicleOffline => 'المركبة غير متصلة';

  @override
  String vehicleOfflineSince(Object time) {
    return 'المركبة غير متصلة منذ $time.';
  }

  @override
  String get unknownTime => 'وقت غير معروف';

  @override
  String get vehiclePlanExpired => 'انتهت خطة المركبة';

  @override
  String get vehiclePlanExpiredMessage =>
      'انتهت صلاحية هذه المركبة. يرجى تجديد خطتك والتواصل مع مزود الخدمة.';

  @override
  String get vehicleLocationUnavailable => 'موقع المركبة غير متاح.';

  @override
  String get unableOpenDirections => 'تعذر فتح اتجاهات الخريطة.';

  @override
  String get noLiveData => 'لا توجد بيانات مباشرة';

  @override
  String get noVehicleDataAvailable => 'لا توجد بيانات متاحة لهذه المركبة.';

  @override
  String get unableLoadTracking => 'تعذر تحميل التتبع';

  @override
  String get locationUnavailable => 'الموقع غير متاح';

  @override
  String get liveLocationUnavailableVehicle =>
      'الموقع المباشر غير متاح لهذه المركبة.';

  @override
  String get yourLocation => 'موقعك';

  @override
  String get vehicleSensors => 'حساسات المركبة';

  @override
  String sensorItemsCount(Object count) {
    return '$count عناصر';
  }

  @override
  String get noSensorsAvailable => 'لا توجد حساسات متاحة';

  @override
  String get driverAssignment => 'تعيين السائق';

  @override
  String get alertAssign => 'تعيين التنبيه';

  @override
  String get maintenance => 'الصيانة';

  @override
  String get expenses => 'المصروفات';

  @override
  String get trackManageExpenses => 'تتبع وإدارة المصروفات';

  @override
  String get reminders => 'التذكيرات';

  @override
  String get complainVehicle => 'تقديم شكوى بشأن هذه المركبة';

  @override
  String get supportChatVehicle => 'افتح محادثة الدعم مع هذه المركبة المحددة';

  @override
  String get assign => 'تعيين';

  @override
  String get add => 'إضافة';

  @override
  String get complain => 'شكوى';

  @override
  String get seeDriver => 'عرض السائق';

  @override
  String get noAlertAssigned => 'لا يوجد تنبيه معين';

  @override
  String get noUpcomingMaintenance => 'لا توجد صيانة قادمة';

  @override
  String get viewAllExpenses => 'عرض جميع المصروفات';

  @override
  String get noActiveReminders => 'لا توجد تذكيرات نشطة';

  @override
  String talkToSupportVehicle(Object vehicle) {
    return 'تحدث إلى الدعم بشأن $vehicle';
  }

  @override
  String get singleVehicleNoAlertsFound => 'لم يتم العثور على تنبيهات';

  @override
  String get singleVehicleNoAlertsCategory => 'لا توجد تنبيهات للفئة المحددة';

  @override
  String get singleVehicleNoAlertsSearch => 'لا توجد تنبيهات تطابق بحثك';

  @override
  String get singleVehicleNoAlertsVehicle =>
      'لا توجد تنبيهات متاحة لهذه المركبة';

  @override
  String get showAllAlerts => 'إظهار كل التنبيهات';

  @override
  String get oopsSomethingWrong => 'عذرًا! حدث خطأ ما';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String deleteAlertsConfirmCount(Object count) {
    return 'هل أنت متأكد أنك تريد حذف $count تنبيه(ات)؟';
  }

  @override
  String get failedDeleteAlerts => 'فشل حذف التنبيهات';

  @override
  String get close => 'إغلاق';

  @override
  String get alertsCategory => 'فئات التنبيهات';

  @override
  String get overSpeed => 'تجاوز السرعة';

  @override
  String get idleDuration => 'مدة التوقف';

  @override
  String get ignitionDuration => 'مدة التشغيل';

  @override
  String get moveStart => 'بدء الحركة';

  @override
  String get offlineDuration => 'مدة عدم الاتصال';

  @override
  String get overParking => 'تجاوز الوقوف';

  @override
  String get times => 'مرات';

  @override
  String get loadingAlerts => 'جار تحميل التنبيهات...';

  @override
  String get vehicleInfo => 'معلومات المركبة';

  @override
  String get averagePerLiter => 'المتوسط لكل لتر';

  @override
  String get engineType => 'نوع المحرك';

  @override
  String get vehicleType => 'نوع المركبة';

  @override
  String get updateVehicleInfo => 'تحديث معلومات المركبة';

  @override
  String get exampleAveragePerLiter => 'مثال: 11.00';

  @override
  String get selectEngineType => 'اختر نوع المحرك';

  @override
  String get selectVehicleType => 'اختر نوع المركبة';

  @override
  String get pleaseEnterValidAveragePerLiter => 'يرجى إدخال متوسط صالح لكل لتر';

  @override
  String get save => 'حفظ';

  @override
  String get serviceAddedSuccessfully => 'تمت إضافة الخدمة بنجاح';

  @override
  String get expenseAddedSuccessfully => 'تمت إضافة المصروف بنجاح';

  @override
  String get singleActiveReminder => 'تذكير نشط واحد';

  @override
  String multipleActiveReminders(Object count) {
    return '$count تذكيرات نشطة';
  }

  @override
  String get noPastReminders => 'لا توجد تذكيرات سابقة';

  @override
  String get singlePastReminder => 'تذكير سابق واحد';

  @override
  String multiplePastReminders(Object count) {
    return '$count تذكيرات سابقة';
  }

  @override
  String get oldReminders => 'التذكيرات القديمة';

  @override
  String get noOldReminders => 'لا توجد تذكيرات قديمة';

  @override
  String totalCurrencyRs(Object amount) {
    return 'الإجمالي: Rs $amount';
  }

  @override
  String fromValue(Object value) {
    return 'من: $value';
  }

  @override
  String toValue(Object value) {
    return 'إلى: $value';
  }

  @override
  String get clearDateFilter => 'مسح فلتر التاريخ';

  @override
  String get noExpensesRecorded => 'لا توجد مصروفات مسجلة';

  @override
  String get noServicesRecorded => 'لا توجد خدمات مسجلة';

  @override
  String get deleteExpense => 'حذف المصروف';

  @override
  String get deleteExpenseConfirmation =>
      'هل أنت متأكد أنك تريد حذف هذا المصروف؟';

  @override
  String get deleteService => 'حذف الخدمة';

  @override
  String get deleteServiceConfirmation =>
      'هل أنت متأكد أنك تريد حذف هذه الخدمة؟';

  @override
  String get noName => 'بلا اسم';

  @override
  String nameValue(Object value) {
    return 'الاسم: $value';
  }

  @override
  String supplierValue(Object value) {
    return 'المورّد: $value';
  }

  @override
  String amountCurrencyRs(Object amount) {
    return 'المبلغ: Rs $amount';
  }

  @override
  String expenseQtyUnitRow(Object date, Object qty, Object unit) {
    return '$date  •  الكمية: $qty  •  الوحدة: Rs $unit';
  }

  @override
  String serviceNumber(Object id) {
    return 'الخدمة #$id';
  }

  @override
  String typeValue(Object value) {
    return 'النوع: $value';
  }

  @override
  String intervalLastRow(Object interval, Object last) {
    return 'الفترة: $interval  •  الأخير: $last';
  }

  @override
  String expiresRemindRow(Object expires, Object remind) {
    return 'ينتهي: $expires  •  التذكير: $remind';
  }

  @override
  String currentOdometerEngineHoursRow(Object odometer, Object hours) {
    return 'عداد المسافة الحالي: $odometer  •  ساعات المحرك: $hours';
  }

  @override
  String get daily => 'يومي';

  @override
  String get weekly => 'أسبوعي';

  @override
  String get monthly => 'شهري';

  @override
  String get yearly => 'سنوي';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get last3Days => 'آخر 3 أيام';

  @override
  String get last7Days => 'آخر 7 أيام';

  @override
  String get custom => 'مخصص';

  @override
  String get done => 'تم';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get selectTime => 'اختر الوقت';

  @override
  String get fromDateCannotBeLaterThanToDate =>
      'لا يمكن أن يكون تاريخ البدء بعد تاريخ الانتهاء';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get loadingAnalytics => 'جار تحميل التحليلات...';

  @override
  String get vehicleAnalytics => 'تحليلات المركبة';

  @override
  String get dateTimeRange => 'نطاق التاريخ والوقت';

  @override
  String get startDateTime => 'تاريخ ووقت البدء';

  @override
  String get endDateTime => 'تاريخ ووقت الانتهاء';

  @override
  String get chartsGroupedByDate => 'الرسوم البيانية مجمعة حسب التاريخ';

  @override
  String get chartsGroupedByHour => 'الرسوم البيانية مجمعة حسب الساعة';

  @override
  String get maximumSpeed => 'السرعة القصوى';

  @override
  String get driveTime => 'وقت القيادة';

  @override
  String get stopTime => 'وقت التوقف';

  @override
  String get fuelUsed => 'الوقود المستخدم';

  @override
  String get amountSpent => 'المبلغ المنفق';

  @override
  String get maxSpeedPerDay => 'أقصى سرعة لكل يوم (km/h)';

  @override
  String get speedKmh => 'السرعة (km/h)';

  @override
  String get distancePerDay => 'المسافة لكل يوم (km)';

  @override
  String get distanceKm => 'المسافة (km)';

  @override
  String get fuelUsedLiters => 'الوقود المستخدم (لتر)';

  @override
  String get stopDurationMinutes => 'مدة التوقف (دقائق)';

  @override
  String get engineHoursPerDay => 'ساعات المحرك لكل يوم';

  @override
  String get engineHoursCumulative => 'ساعات المحرك (تراكمي)';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get noDataAvailable => 'لا توجد بيانات متاحة';

  @override
  String get liveTracking => 'التتبع المباشر';

  @override
  String updatedAt(Object value) {
    return 'آخر تحديث : $value';
  }

  @override
  String get traffic => 'حركة المرور';

  @override
  String vehicleLocationShare(Object url) {
    return 'موقع المركبة: $url';
  }

  @override
  String get moving => 'تتحرك';

  @override
  String get callToDriver => 'اتصال بالسائق';

  @override
  String get immobilizer => 'مانع التشغيل';

  @override
  String get last30Days => 'آخر 30 يومًا';

  @override
  String get pleaseSelectDateRangeFirst => 'يرجى تحديد نطاق التاريخ أولاً';

  @override
  String get fromTime => 'من الوقت';

  @override
  String get toTime => 'إلى الوقت';

  @override
  String get applyRange => 'تطبيق النطاق';

  @override
  String get fleetInsightTitle => 'رؤية الأسطول AI';

  @override
  String get fleetStatusStable => 'مستقر';

  @override
  String get fleetStatusNeedsAttention => 'يحتاج متابعة';

  @override
  String get fleetStatusCritical => 'حرج';

  @override
  String get fleetInsightIntroPositive1 => 'حركة الأسطول مستقرة اليوم.';

  @override
  String get fleetInsightIntroPositive2 => 'العمليات تبدو متوازنة حالياً.';

  @override
  String get fleetInsightIntroPositive3 => 'الاتجاه العام صحي عبر الأسطول.';

  @override
  String get fleetInsightIntroWarning1 =>
      'الأسطول يحتاج انتباهاً في جانب واحد.';

  @override
  String get fleetInsightIntroWarning2 => 'بعض الإشارات تنحرف عن الهدف.';

  @override
  String get fleetInsightIntroWarning3 =>
      'الصورة الحالية تُظهر ضغطاً تشغيلياً متوسطاً.';

  @override
  String get fleetInsightIntroCritical1 => 'يوصى بإجراء فوري لصحة الأسطول.';

  @override
  String get fleetInsightIntroCritical2 =>
      'المؤشرات الحالية تدل على مخاطر تشغيلية مرتفعة.';

  @override
  String get fleetInsightIntroCritical3 =>
      'مطلوب متابعة عاجلة على المؤشرات الحرجة.';

  @override
  String get fleetInsightAvailabilityTitle => 'توفر المركبات يحتاج متابعة.';

  @override
  String fleetInsightAvailabilityDetail(
      Object offlineNow, Object totalVehicles, Object offline24h) {
    return '$offlineNow/$totalVehicles مركبات غير متصلة الآن، منها $offline24h غير متصلة لأكثر من 24 ساعة.';
  }

  @override
  String get fleetInsightSafetyTitle =>
      'سلوك السرعة الزائدة يرفع مستوى المخاطر.';

  @override
  String fleetInsightSafetyVehicleDetail(Object vehicleName, Object count) {
    return 'سجلت $vehicleName عدد $count من تنبيهات السرعة الزائدة، وهو الأعلى في الأسطول.';
  }

  @override
  String fleetInsightSafetyOverallDetail(Object overspeed, Object totalAlerts) {
    return 'تم رصد $overspeed تنبيه سرعة زائدة من أصل $totalAlerts تنبيهات إجمالية.';
  }

  @override
  String get fleetInsightMaintenanceTitle => 'تراكم الصيانة يؤثر على الجاهزية.';

  @override
  String fleetInsightMaintenanceDetail(Object dueCount) {
    return '$dueCount عنصر صيانة مستحق أو متأخر حالياً.';
  }

  @override
  String get fleetInsightTasksTitle => 'قائمة المهام تحتاج موازنة.';

  @override
  String fleetInsightTasksDetail(Object taskBacklog, Object agingCount) {
    return 'هناك $taskBacklog مهام مفتوحة، منها $agingCount أقدم من يومين.';
  }

  @override
  String get fleetInsightPerformanceTitle =>
      'درجة الأداء هي محور التحسين الحالي.';

  @override
  String fleetInsightPerformanceDetail(Object score) {
    return 'متوسط أداء المركبات هو $score/100 للفترة المحددة.';
  }

  @override
  String get fleetInsightPerformanceLoading =>
      'تحليلات الأداء ما زالت قيد التحميل من البيانات الحديثة.';

  @override
  String get fleetInsightExpenseTitle => 'اتجاه المصروفات تحت المراقبة حالياً.';

  @override
  String fleetInsightExpenseDetail(Object amount, Object change) {
    return 'مصروفات هذا الشهر Rs $amount مع تغير شهري قدره $change%.';
  }

  @override
  String get fleetInsightDistanceTitle => 'اتجاه المسافة يبدو نشطاً اليوم.';

  @override
  String fleetInsightDistanceLeaderDetail(
      Object vehicleName, Object distanceKm) {
    return 'قطعت $vehicleName مسافة $distanceKm كم اليوم، وهي الأعلى في الأسطول.';
  }

  @override
  String fleetInsightDistanceTotalDetail(Object distanceKm) {
    return 'قطع الأسطول إجمالاً $distanceKm كم اليوم.';
  }

  @override
  String fleetInsightDistanceSpeedDetail(
      Object vehicleName, Object topSpeed, Object distanceKm) {
    return 'سجلت $vehicleName سرعة قصوى $topSpeed كم/س، بينما إجمالي مسافة الأسطول $distanceKm كم.';
  }

  @override
  String fleetInsightDistanceAvgDetail(Object totalKm, Object avgKm) {
    return 'ملخص حركة الأسطول: $totalKm كم إجمالي ومتوسط $avgKm كم.';
  }

  @override
  String get fleetInsightMovementLoading => 'تحليلات الحركة قيد التحميل.';

  @override
  String fleetInsightMovementSummary(Object totalKm, Object avgKm) {
    return 'تحرك الأسطول $totalKm كم اليوم (متوسط $avgKm كم/مركبة).';
  }

  @override
  String fleetInsightHealthChip(Object score) {
    return 'الصحة $score/100';
  }

  @override
  String fleetInsightOnlineChip(Object count) {
    return 'متصل $count';
  }

  @override
  String fleetInsightOfflineChip(Object count) {
    return 'غير متصل $count';
  }

  @override
  String fleetInsightOverspeedChip(Object count) {
    return 'سرعة زائدة $count';
  }

  @override
  String fleetInsightMaintenanceChip(Object count) {
    return 'صيانة مستحقة $count';
  }

  @override
  String fleetInsightOpenTasksChip(Object count) {
    return 'مهام مفتوحة $count';
  }

  @override
  String fleetInsightPerformanceChip(Object score) {
    return 'أداء $score/100';
  }

  @override
  String fleetInsightExpenseChip(Object change) {
    return 'المصروفات شهرياً $change%';
  }
}
