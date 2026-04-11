// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Autotel Fleet';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get urdu => 'Urdu';

  @override
  String get arabic => 'Arabic';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get myAccount => 'My Account';

  @override
  String get support => 'Support';

  @override
  String get driverOptions => 'Driver Options';

  @override
  String get manageDriversSubtitle => 'Add, update, or remove drivers';

  @override
  String get addNewDriver => 'Add New Driver';

  @override
  String get createNewDriver => 'Create a new driver';

  @override
  String get editDriverLabel => 'Edit Driver';

  @override
  String get updateDriverInfo => 'Update driver info';

  @override
  String get deleteDriverLabel => 'Delete Driver';

  @override
  String get permanentDeleteDriver => 'Permanent delete driver';

  @override
  String get addDriverLabel => 'Add Driver';

  @override
  String get assignDriverLabel => 'Assign Driver';

  @override
  String get driverNameLabel => 'Driver Name';

  @override
  String get enterDriverName => 'Enter driver name';

  @override
  String get rfidLabel => 'RFID';

  @override
  String get enterDriverRfid => 'Enter driver RFID';

  @override
  String get selectDriverLabel => 'Select Driver';

  @override
  String get searchAndSelectDriver => 'Search and select driver';

  @override
  String get pleaseSelectDriver => 'Please select a driver';

  @override
  String get driverNameRequired => 'Driver name is required';

  @override
  String get pleaseEnterValidEmail => 'Please enter your valid email';

  @override
  String get selectDrivers => 'Select Drivers';

  @override
  String get useCheckboxToSelectDrivers =>
      'Use the checkbox to select multiple drivers';

  @override
  String get searchDriverName => 'Search driver name';

  @override
  String get noDriversFound => 'No drivers found';

  @override
  String driversSelectedCount(Object count) {
    return '$count driver(s) selected';
  }

  @override
  String get noDriverLabel => 'No Driver';

  @override
  String get pleaseSelectAtLeastOneDriver =>
      'Please select at least one driver';

  @override
  String get password => 'Password';

  @override
  String get drivers => 'Drivers';

  @override
  String get addExpenseLabel => 'Add Expense';

  @override
  String get editExpenseLabel => 'Edit Expense';

  @override
  String get selectExpenseType => 'Select expense type';

  @override
  String get expenseNameHint => 'Expense name';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get unitCostLabel => 'Unit cost';

  @override
  String get supplierLabel => 'Supplier';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get enterValidQuantity => 'Enter valid quantity';

  @override
  String get enterValidUnitCost => 'Enter valid unit cost';

  @override
  String get optionalSupplier => 'Optional supplier';

  @override
  String get optionalNotes => 'Optional notes';

  @override
  String get alertSetting => 'Alert Setting';

  @override
  String get playAlertsAnnouncement => 'Play Alerts Announcement';

  @override
  String get appearance => 'Appearance';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changePasswordSubtitle =>
      'Enter old and new password to change it';

  @override
  String get change => 'Change';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get loginEmail => 'Login Email';

  @override
  String get phoneNumberLabel => 'Phone No.';

  @override
  String get deviceLimit => 'Device Limit';

  @override
  String get accountExpiry => 'Account Expiry';

  @override
  String get unlimited => 'Unlimited';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageUpdated => 'Language updated';

  @override
  String get companySupport => 'Company Support';

  @override
  String get contactCompanyDetails => 'Contact & company details';

  @override
  String get liveChat => 'Live Chat';

  @override
  String get wereHereToHelp => 'We’re here to help';

  @override
  String get callLabel => 'Call';

  @override
  String get messageLabel => 'Message';

  @override
  String get emailLabel => 'Email';

  @override
  String get websiteLabel => 'Website';

  @override
  String get whatsAppLabel => 'WhatsApp';

  @override
  String get facebookLabel => 'Facebook';

  @override
  String get instagramLabel => 'Instagram';

  @override
  String get loadingDriverDetails => 'Loading driver details...';

  @override
  String get driverContactProfileDetails =>
      'Driver contact and profile details';

  @override
  String get noDriverAssigned => 'No driver assigned';

  @override
  String get assignDriverToVehicleToViewContactActions =>
      'Assign a driver to this vehicle to\nview contact actions';

  @override
  String get noPhoneNumber => 'No phone number';

  @override
  String get noEmail => 'No email';

  @override
  String get noDescriptionAvailable => 'No description available';

  @override
  String get noContactInformationAvailable =>
      'No contact information available';

  @override
  String get officeAddress => 'Office Address';

  @override
  String get exploreLabel => 'Explore';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get legalPoliciesAndUserAgreement =>
      'Legal policies and user agreement';

  @override
  String get privacyPolicyLabel => 'Privacy Policy';

  @override
  String get howWeProtectYourData => 'How we protect your data';

  @override
  String get companyNews => 'Company News';

  @override
  String get latestUpdatesAndAnnouncements =>
      'Latest updates and announcements';

  @override
  String get galleryPermissionRequired => 'Gallery Permission Required';

  @override
  String galleryPermissionMessage(Object platform) {
    return 'Please allow Photos access from $platform for this app, then try again.';
  }

  @override
  String get ok => 'OK';

  @override
  String hiUser(Object email) {
    return 'Hi, $email';
  }

  @override
  String get hi => 'Hi';

  @override
  String get statusTab => 'Status';

  @override
  String get mapTab => 'Map';

  @override
  String get dashboardTab => 'Dashboard';

  @override
  String get alertsTab => 'Alerts';

  @override
  String get settingsTab => 'Settings';

  @override
  String get managementTab => 'Management';

  @override
  String get backToAdmin => 'Back to Admin';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get notificationsTooltip => 'Notifications';

  @override
  String get customizeDashboard => 'Customize Dashboard';

  @override
  String get edit => 'Edit';

  @override
  String get reset => 'Reset';

  @override
  String get notificationFilters => 'Notification Filters';

  @override
  String get searchByVehicleAndType => 'Search By Vehicle And Type';

  @override
  String get searchByDateRange => 'Search By Date Range';

  @override
  String get vehicleLabel => 'Vehicle';

  @override
  String get dashboardCustomizeHint =>
      'Drag to reorder cards. Toggle switch to hide/show cards.';

  @override
  String get noDashboardCardsSelected =>
      'No dashboard cards selected. Tap Customize to enable cards.';

  @override
  String errorLabel(Object error) {
    return 'Error: $error';
  }

  @override
  String get retry => 'Retry';

  @override
  String get searchVehicle => 'Search vehicle';

  @override
  String get allGroups => 'All Groups';

  @override
  String get allVehicles => 'All Vehicles';

  @override
  String get viewAllVehicles => 'View All Vehicles';

  @override
  String get vehicleStatusAll => 'All';

  @override
  String get vehicleStatusRunning => 'Running';

  @override
  String get vehicleStatusStopped => 'Stopped';

  @override
  String get vehicleStatusIdle => 'Idle';

  @override
  String get vehicleStatusOffline => 'Offline';

  @override
  String get vehicleStatusNoData => 'No Data';

  @override
  String get vehicleStatusExpired => 'Expired';

  @override
  String get vehicleStatusParked => 'Parked';

  @override
  String get vehicleStatusUnknown => 'Unknown';

  @override
  String get noVehiclesAvailable => 'No vehicles available.';

  @override
  String get noAddressFound => 'No Address Found';

  @override
  String get noVehiclesInSelectedGroup =>
      'No vehicles available in the selected group.';

  @override
  String noVehiclesCurrentStatus(Object status) {
    return 'No vehicles are currently $status.';
  }

  @override
  String get speed => 'Speed';

  @override
  String get update => 'Update';

  @override
  String get notAvailableShort => 'N/A';

  @override
  String get engineKilled => 'Engine Killed';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get fromDate => 'From Date';

  @override
  String get toDate => 'To Date';

  @override
  String get deleteAlerts => 'Delete Alerts';

  @override
  String deleteAlertsConfirmation(Object count) {
    return 'Delete $count alert(s)?';
  }

  @override
  String get searchNotification => 'Search Notification';

  @override
  String get noAlertsMatchSearch => 'No alerts match your search';

  @override
  String get noAlertsFound => 'No alerts found';

  @override
  String get locationUnavailableForAlert =>
      'Location is not available for this alert';

  @override
  String get alertsDeletedSuccessfully => 'Alerts deleted successfully';

  @override
  String get noTime => 'No time';

  @override
  String get localReminders => 'Local Reminders';

  @override
  String get activeReminders => 'Active reminders';

  @override
  String get pastReminders => 'Past reminders';

  @override
  String itemsCount(Object count) {
    return '$count Items';
  }

  @override
  String get deleteReminder => 'Delete Reminder';

  @override
  String get deleteReminderConfirmation =>
      'Are you sure you want to delete this reminder?';

  @override
  String get reminderDeleted => 'Reminder deleted';

  @override
  String get noRemindersFound => 'No reminders found';

  @override
  String get noDescription => 'No description';

  @override
  String get addReminderLabel => 'Add Reminder';

  @override
  String get editReminderLabel => 'Edit Reminder';

  @override
  String get selectType => 'Select type';

  @override
  String get titleLabel => 'Title';

  @override
  String get reminderTitleHint => 'Reminder title';

  @override
  String get dueDateLabel => 'Due Date';

  @override
  String get dueTimeLabel => 'Due Time';

  @override
  String get dateIgnoredForDailyRepeat => 'Date is ignored for daily repeat';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get reminderTitleRequired => 'Reminder title is required';

  @override
  String get pleaseSelectDueDate => 'Please select due date';

  @override
  String get pleaseSelectDueTime => 'Please select due time';

  @override
  String get reminderSavedSuccessfully => 'Reminder saved successfully';

  @override
  String get reminderUpdatedSuccessfully => 'Reminder updated successfully';

  @override
  String get oilChange => 'Oil Change';

  @override
  String get tireRotation => 'Tire Rotation';

  @override
  String get brakeInspection => 'Brake Inspection';

  @override
  String get airFilterReplacement => 'Air Filter Replacement';

  @override
  String get sparkPlugsReplacement => 'Spark Plugs Replacement';

  @override
  String get batteryCheck => 'Battery Check';

  @override
  String get charging => 'Charging';

  @override
  String get insuranceRenewal => 'Insurance Renewal';

  @override
  String get registrationRenewal => 'Registration Renewal';

  @override
  String get emissionTest => 'Emission Test';

  @override
  String get generalService => 'General Service';

  @override
  String get coolantFlush => 'Coolant Flush';

  @override
  String get repeatOneTime => 'One-time';

  @override
  String get repeatRecurring => 'Recurring';

  @override
  String get tasksAnalytics => 'Tasks Analytics';

  @override
  String get seeMore => 'See more';

  @override
  String get noTasksAvailable => 'No tasks available';

  @override
  String get allTasks => 'All Tasks';

  @override
  String get addTask => 'Add Task';

  @override
  String get noTasksFound => 'No tasks found';

  @override
  String get searchTasksByTitleOrVehicle => 'Search by title or vehicle';

  @override
  String showingTasksCount(Object count) {
    return 'Showing $count tasks';
  }

  @override
  String showingTasksCountOfTotal(Object count, Object total) {
    return 'Showing $count of $total tasks';
  }

  @override
  String get loadMore => 'Load More';

  @override
  String get latestTasks => 'Latest Tasks';

  @override
  String get taskFunnel => 'Task Funnel';

  @override
  String get taskNew => 'New';

  @override
  String get taskInProgress => 'In Progress';

  @override
  String get taskCompleted => 'Completed';

  @override
  String get taskFailed => 'Failed';

  @override
  String get hasStops => 'Has Stops';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get routePlayback => 'Route Playback';

  @override
  String get deleteTask => 'Delete Task';

  @override
  String get deleteTaskConfirmation =>
      'Are you sure you want to delete this task?';

  @override
  String get assignTask => 'Assign Task';

  @override
  String recreateTaskForVehicle(Object vehicleName) {
    return 'Are you sure you want to recreate this task for \"$vehicleName\"?';
  }

  @override
  String get selectVehicleToRecreateTask =>
      'Select a vehicle to recreate this task.';

  @override
  String get pickup => 'Pickup';

  @override
  String get reachedAt => 'Reached at';

  @override
  String get leftAt => 'Left at';

  @override
  String taskStop(Object index) {
    return 'Stop $index';
  }

  @override
  String get delivery => 'Delivery';

  @override
  String get completionRate => 'Completion Rate';

  @override
  String get failureRate => 'Failure Rate';

  @override
  String tasksCountSummary(Object count, Object total) {
    return '$count of $total tasks';
  }

  @override
  String get unstartedTaskAging => 'Unstarted Task Aging';

  @override
  String get inProgressAging => 'In Progress Aging';

  @override
  String get tasksNotCompletedWithin10Days =>
      'Tasks not completed within 10 days';

  @override
  String vehicleTasksTitle(Object vehicleName) {
    return '$vehicleName Tasks';
  }

  @override
  String get successRate => 'Success Rate';

  @override
  String get avgCompletion => 'Avg Completion';

  @override
  String get createdToDeliveryLeft => 'Created to delivery left';

  @override
  String get pickupResponse => 'Pickup Response';

  @override
  String get createdToPickupReached => 'Created to pickup reached';

  @override
  String get pickupDwell => 'Pickup Dwell';

  @override
  String get pickupLeftMinusReached => 'Pickup left minus reached';

  @override
  String get stopDwell => 'Stop Dwell';

  @override
  String get averageAcrossAllStops => 'Average across all stops';

  @override
  String get deliveryDwell => 'Delivery Dwell';

  @override
  String get deliveryLeftMinusReached => 'Delivery left minus reached';

  @override
  String get stopComplexityTrend => 'Stop Complexity Trend';

  @override
  String get directJobs => 'Direct Jobs';

  @override
  String get noStops => 'No stops';

  @override
  String get multiStopJobs => 'Multi-stop Jobs';

  @override
  String get oneOrMoreStops => 'One or more stops';

  @override
  String get recentFailedTasks => 'Recent Failed Tasks';

  @override
  String get noRecentFailedTasksForVehicle =>
      'No recent failed tasks for this vehicle';

  @override
  String taskNumber(Object id) {
    return 'Task #$id';
  }

  @override
  String get vehicleWorkloadDistribution => 'Vehicle Workload Distribution';

  @override
  String get noVehicleWorkloadData => 'No vehicle workload data available';

  @override
  String get share => 'Share';

  @override
  String get export => 'Export';

  @override
  String get refresh => 'Refresh';

  @override
  String get maintenanceReminder => 'Maintenance Reminder';

  @override
  String get allMaintenance => 'All Maintenance';

  @override
  String get dueMaintenance => 'Due Maintenance';

  @override
  String get overdueMaintenance => 'Overdue Maintenance';

  @override
  String get overdue => 'Overdue';

  @override
  String get maintenanceAnalytics => 'Maintenance Analytics';

  @override
  String get healthScore => 'Health Score';

  @override
  String healthyStateSummary(Object ok, Object total) {
    return '$ok of $total in healthy state';
  }

  @override
  String get dueSoon => 'Due Soon';

  @override
  String overdueCountLabel(Object count) {
    return 'Overdue: $count';
  }

  @override
  String get dueSoonWindows => 'Due Soon Windows';

  @override
  String dueInNextDays(Object days) {
    return 'Due in Next $days Days';
  }

  @override
  String get overdueByType => 'Overdue by Type';

  @override
  String get topOverdueServices => 'Top Overdue Services';

  @override
  String get topVehiclesByOverdue => 'Top Vehicles by Overdue';

  @override
  String get nextDueByLeftValue => 'Next Due by Left Value';

  @override
  String get upcomingCalendar => 'Upcoming Calendar';

  @override
  String get criticalMaintenanceAlerts => 'Critical Maintenance Alerts';

  @override
  String get noOverdueVehicles => 'No overdue vehicles';

  @override
  String get noUpcomingByLeft => 'No upcoming by left';

  @override
  String get noUpcomingDates => 'No upcoming dates';

  @override
  String get noCriticalMaintenanceAlerts => 'No critical maintenance alerts';

  @override
  String get fuelPrices => 'Fuel Prices';

  @override
  String get petrol => 'Petrol';

  @override
  String get diesel => 'Diesel';

  @override
  String get lastUpdated => 'Last Updated';

  @override
  String get offlineOver24Hours => 'Offline Over 24 Hours';

  @override
  String get noVehiclesOffline24h =>
      'No vehicles offline for more than 24 hours';

  @override
  String get expenseAnalytics => 'Expense Analytics';

  @override
  String get expenseTrend => 'Expense Trend';

  @override
  String get topExpenseTypes => 'Top Expense Types';

  @override
  String get topVehiclesByExpense => 'Top Vehicles by Expense';

  @override
  String get recentExpenseActivity => 'Recent Expense Activity';

  @override
  String get noTypeData => 'No type data';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get changeLabel => 'Change';

  @override
  String get totalRange => 'Total (Range)';

  @override
  String get avgPerTxn => 'Avg / Txn';

  @override
  String get avgPerDay => 'Avg / Day';

  @override
  String get noTrendData => 'No trend data';

  @override
  String get performanceAnalytics => 'Performance Analytics';

  @override
  String get vehicles => 'Vehicles';

  @override
  String get scoredFromAlerts => 'Scored from alerts';

  @override
  String get mappedFromAssignment => 'Mapped from current assignment';

  @override
  String get topVehicles => 'Top Vehicles';

  @override
  String get topDrivers => 'Top Drivers';

  @override
  String get allVehiclePerformance => 'All Vehicle Performance';

  @override
  String get allDriverPerformance => 'All Driver Performance';

  @override
  String get noAlertsForDateRange =>
      'No idle/overspeed alerts found for selected date range.';

  @override
  String get alertsCount => 'Alerts Count';

  @override
  String get totalWord => 'Total';

  @override
  String totalLabel(Object count) {
    return 'Total: $count';
  }

  @override
  String get distanceTravelled => 'Distance Travelled';

  @override
  String get totalDistance => 'Total Distance';

  @override
  String get averageDistance => 'Average Distance';

  @override
  String get topSpeedingVehicles => 'Top Speeding Vehicles';

  @override
  String get vehicleFallback => 'Vehicle';

  @override
  String get noMaintenanceItems => 'No maintenance items';

  @override
  String maintenanceNumber(Object index) {
    return 'Maintenance #$index';
  }

  @override
  String get vehicle => 'Vehicle';

  @override
  String get nameLabel => 'Name';

  @override
  String get typeLabel => 'Type';

  @override
  String get unit => 'Unit';

  @override
  String get interval => 'Interval';

  @override
  String get lastService => 'Last Service';

  @override
  String get current => 'Current';

  @override
  String get percent => 'Percent';

  @override
  String get leftLabel => 'Left';

  @override
  String get status => 'Status';

  @override
  String get expiresDate => 'Expires Date';

  @override
  String get remindDate => 'Remind Date';

  @override
  String get daysTotalElapsed => 'Days (Total/Elapsed)';

  @override
  String get daysLeft => 'Days Left';

  @override
  String get description => 'Description';

  @override
  String get unknownVehicle => 'Unknown Vehicle';

  @override
  String daysShort(Object days) {
    return '$days days';
  }

  @override
  String daysOverdue(Object days) {
    return '$days days overdue';
  }

  @override
  String get none => 'None';

  @override
  String get scopeAllVehicles => 'Scope: All Vehicles';

  @override
  String totalServices(Object count) {
    return 'Total Services: $count';
  }

  @override
  String get reportMaintenanceAnalytics => 'Maintenance Analytics Report';

  @override
  String get reportPerformanceAnalytics => 'Performance Analytics Report';

  @override
  String get reportOffline24h => 'Offline Over 24 Hours Report';

  @override
  String generatedAt(Object value) {
    return 'Generated: $value';
  }

  @override
  String totalVehiclesReport(Object count) {
    return 'Total Vehicles: $count';
  }

  @override
  String offlineSinceDuration(Object vehicle, Object since, Object duration) {
    return '$vehicle | Offline since $since | Duration: $duration';
  }

  @override
  String offlineOver24HoursWithCount(Object count) {
    return 'Offline Over 24 Hours ($count)';
  }

  @override
  String get noRecentActivity => 'No recent activity';

  @override
  String get liveTab => 'Live';

  @override
  String get analyticsTab => 'Analytics';

  @override
  String get reportTab => 'Report';

  @override
  String get formatLabel => 'Format';

  @override
  String get speedLimitKmh => 'Speed Limit (km/h)';

  @override
  String get ignitionOffDurationMin => 'Ignition Off Duration (min)';

  @override
  String get stopsMinutes => 'Stops (minutes)';

  @override
  String get geofenceIdsCommaSeparated => 'Geofence IDs (comma separated)';

  @override
  String get showAddresses => 'Show Addresses';

  @override
  String get zonesInstead => 'Zones Instead';

  @override
  String get noGeofencesFound => 'No geofences found';

  @override
  String get reloadGeofences => 'Reload Geofences';

  @override
  String geofencesSelectedCount(Object count) {
    return '$count geofence(s) selected';
  }

  @override
  String reportFieldsLabel(Object fields) {
    return 'Fields: $fields';
  }

  @override
  String get generateLabel => 'Generate';

  @override
  String get pleaseSelectBothDates => 'Please select both dates';

  @override
  String get noReportsAvailable => 'No reports available';

  @override
  String get reportTypesLabel => 'Report Types';

  @override
  String get showLess => 'Show Less';

  @override
  String get moreReports => 'More Reports';

  @override
  String get dailyTravelReport => 'Daily Travel Report';

  @override
  String get travelSummaryWithPlaybackImage =>
      'Travel Summary with Playback Image';

  @override
  String get travelSummary => 'Travel Summary';

  @override
  String get stopsMoveSummary => 'Stops Move Summary';

  @override
  String get eventsReport => 'Events';

  @override
  String get alertsReport => 'Alerts Report';

  @override
  String get tripReport => 'Trip Report';

  @override
  String get playbackLabel => 'Playback';

  @override
  String tripsCountLabel(Object count) {
    return 'Trips ($count)';
  }

  @override
  String parkedCountLabel(Object count) {
    return 'Parked ($count)';
  }

  @override
  String alertsCountLabel(Object count) {
    return 'Alerts ($count)';
  }

  @override
  String get noTripsFound => 'No trips found';

  @override
  String get noParkedIntervals => 'No parked intervals';

  @override
  String get noHistoryAlertsFound => 'No alerts found';

  @override
  String get playingRouteHighlightedGreen =>
      'Playing - route highlighted green';

  @override
  String get pausedLabel => 'Paused';

  @override
  String get totalTrips => 'Total Trips';

  @override
  String get moveTime => 'Move Time';

  @override
  String get fuelLtr => 'Fuel (LTR)';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String get topSpeed => 'Top Speed';

  @override
  String rsAmount(Object amount) {
    return 'Rs. $amount';
  }

  @override
  String get taskPlayback => 'Task Playback';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get currentVehicleLocationHistoryHint =>
      'This is Current Location of the Vehicle. To see History choose Filter or give date range';

  @override
  String get loadingHistory => 'Loading history...';

  @override
  String get currentLiveLocation => 'Current Live Location';

  @override
  String get historyTab => 'History';

  @override
  String get alertsTabLong => 'Alerts';

  @override
  String get infoTab => 'Info';

  @override
  String get vehicleOffline => 'Vehicle Offline';

  @override
  String vehicleOfflineSince(Object time) {
    return 'Vehicle is offline since $time.';
  }

  @override
  String get unknownTime => 'unknown time';

  @override
  String get vehiclePlanExpired => 'Vehicle Plan Expired';

  @override
  String get vehiclePlanExpiredMessage =>
      'This vehicle is expired. Please renew your plan and contact your service provider.';

  @override
  String get vehicleLocationUnavailable => 'Vehicle location is unavailable.';

  @override
  String get unableOpenDirections => 'Unable to open map directions.';

  @override
  String get noLiveData => 'No live data';

  @override
  String get noVehicleDataAvailable => 'This vehicle has no data available.';

  @override
  String get unableLoadTracking => 'Unable to load tracking';

  @override
  String get locationUnavailable => 'Location unavailable';

  @override
  String get liveLocationUnavailableVehicle =>
      'Live location is not available for this vehicle.';

  @override
  String get yourLocation => 'Your Location';

  @override
  String get vehicleSensors => 'Vehicle Sensors';

  @override
  String sensorItemsCount(Object count) {
    return '$count items';
  }

  @override
  String get noSensorsAvailable => 'No sensors available';

  @override
  String get driverAssignment => 'Driver Assignment';

  @override
  String get alertAssign => 'Alert Assign';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get addServiceLabel => 'Add Service';

  @override
  String get enterServiceName => 'Enter service name';

  @override
  String get expirationByLabel => 'Expiration by';

  @override
  String get selectExpirationType => 'Select expiration type';

  @override
  String get enterInterval => 'Enter interval';

  @override
  String get enterLastValueDate => 'Enter last value/date';

  @override
  String get triggerEventWhenLeftLabel => 'Trigger event when left';

  @override
  String get triggerEventWhenLeftHint => 'e.g. 1000 km';

  @override
  String get renewAfterExpirationLabel => 'Renew after expiration';

  @override
  String get odometerLabel => 'Odometer';

  @override
  String get engineHoursLabel => 'Engine hours';

  @override
  String get notificationEmailHint => 'notification@email.com';

  @override
  String get dateLabel => 'Date';

  @override
  String get searchVehicleByName => 'Search vehicle by name';

  @override
  String get noVehiclesFoundForSearch => 'No vehicle found';

  @override
  String get defaultMapStyle => 'Default';

  @override
  String get satelliteMapStyle => 'Satellite';

  @override
  String get loadingDevices => 'Loading devices...';

  @override
  String get noDevicesFound => 'No devices found.';

  @override
  String get noVehiclesFound => 'No vehicles found.';

  @override
  String noVehiclesFoundForStatus(Object status) {
    return 'No $status vehicles found.';
  }

  @override
  String updatedSecondsAgo(Object seconds) {
    return 'Updated • ${seconds}s ago';
  }

  @override
  String speedKmhValue(Object speed) {
    return 'Speed: $speed km/h';
  }

  @override
  String updateValue(Object value) {
    return 'Update: $value';
  }

  @override
  String get openDetails => 'Open details';

  @override
  String get expenses => 'Expenses';

  @override
  String get trackManageExpenses => 'Track and manage expenses';

  @override
  String get reminders => 'Reminders';

  @override
  String get complainVehicle => 'Complain About this Vehicle';

  @override
  String get supportChatVehicle =>
      'Open support chat with this vehicle selected';

  @override
  String get assign => 'Assign';

  @override
  String get add => 'Add';

  @override
  String get complain => 'Complain';

  @override
  String get seeDriver => 'See driver';

  @override
  String get noAlertAssigned => 'No Alert assigned';

  @override
  String get noUpcomingMaintenance => 'No upcoming maintenance';

  @override
  String get viewAllExpenses => 'View all expenses';

  @override
  String get noActiveReminders => 'No active reminders';

  @override
  String talkToSupportVehicle(Object vehicle) {
    return 'Talk to support about $vehicle';
  }

  @override
  String get singleVehicleNoAlertsFound => 'No Alerts Found';

  @override
  String get singleVehicleNoAlertsCategory => 'No alerts for selected category';

  @override
  String get singleVehicleNoAlertsSearch => 'No alerts match your search';

  @override
  String get singleVehicleNoAlertsVehicle =>
      'No alerts available for this vehicle';

  @override
  String get showAllAlerts => 'Show All Alerts';

  @override
  String get oopsSomethingWrong => 'Oops! Something went wrong';

  @override
  String get tryAgain => 'Try Again';

  @override
  String deleteAlertsConfirmCount(Object count) {
    return 'Are you sure you want to delete $count alert(s)?';
  }

  @override
  String get failedDeleteAlerts => 'Failed to delete alerts';

  @override
  String get close => 'Close';

  @override
  String get alertsCategory => 'Alerts Category';

  @override
  String get overSpeed => 'Over Speed';

  @override
  String get idleDuration => 'Idle Duration';

  @override
  String get ignitionDuration => 'Ignition duration';

  @override
  String get moveStart => 'Move Start';

  @override
  String get offlineDuration => 'Offline duration';

  @override
  String get overParking => 'Over Parking';

  @override
  String get times => 'Times';

  @override
  String get loadingAlerts => 'Loading alerts...';

  @override
  String get vehicleInfo => 'Vehicle Info';

  @override
  String get averagePerLiter => 'Average Per Liter';

  @override
  String get engineType => 'Engine Type';

  @override
  String get vehicleType => 'Vehicle Type';

  @override
  String get updateVehicleInfo => 'Update Vehicle Info';

  @override
  String get exampleAveragePerLiter => 'e.g. 11.00';

  @override
  String get selectEngineType => 'Select engine type';

  @override
  String get selectVehicleType => 'Select vehicle type';

  @override
  String get pleaseEnterValidAveragePerLiter =>
      'Please enter a valid Average Per Liter';

  @override
  String get save => 'Save';

  @override
  String get serviceAddedSuccessfully => 'Service added successfully';

  @override
  String get expenseAddedSuccessfully => 'Expense added successfully';

  @override
  String get singleActiveReminder => '1 active reminder';

  @override
  String multipleActiveReminders(Object count) {
    return '$count active reminders';
  }

  @override
  String get noPastReminders => 'No past reminders';

  @override
  String get singlePastReminder => '1 past reminder';

  @override
  String multiplePastReminders(Object count) {
    return '$count past reminders';
  }

  @override
  String get oldReminders => 'Old Reminders';

  @override
  String get noOldReminders => 'No old reminders';

  @override
  String totalCurrencyRs(Object amount) {
    return 'Total: Rs $amount';
  }

  @override
  String fromValue(Object value) {
    return 'From: $value';
  }

  @override
  String toValue(Object value) {
    return 'To: $value';
  }

  @override
  String get clearDateFilter => 'Clear date filter';

  @override
  String get noExpensesRecorded => 'No expenses recorded';

  @override
  String get noServicesRecorded => 'No services recorded';

  @override
  String get deleteExpense => 'Delete Expense';

  @override
  String get deleteExpenseConfirmation =>
      'Are you sure you want to delete this expense?';

  @override
  String get deleteService => 'Delete Service';

  @override
  String get deleteServiceConfirmation =>
      'Are you sure you want to delete this service?';

  @override
  String get noName => 'No name';

  @override
  String nameValue(Object value) {
    return 'Name: $value';
  }

  @override
  String supplierValue(Object value) {
    return 'Supplier: $value';
  }

  @override
  String amountCurrencyRs(Object amount) {
    return 'Amount: Rs $amount';
  }

  @override
  String expenseQtyUnitRow(Object date, Object qty, Object unit) {
    return '$date  •  Qty: $qty  •  Unit: Rs $unit';
  }

  @override
  String serviceNumber(Object id) {
    return 'Service #$id';
  }

  @override
  String typeValue(Object value) {
    return 'Type: $value';
  }

  @override
  String intervalLastRow(Object interval, Object last) {
    return 'Interval: $interval  •  Last: $last';
  }

  @override
  String expiresRemindRow(Object expires, Object remind) {
    return 'Expires: $expires  •  Remind: $remind';
  }

  @override
  String currentOdometerEngineHoursRow(Object odometer, Object hours) {
    return 'Current Odometer: $odometer  •  Engine Hours: $hours';
  }

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get last3Days => 'Last 3 Days';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get custom => 'Custom';

  @override
  String get done => 'Done';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectTime => 'Select Time';

  @override
  String get fromDateCannotBeLaterThanToDate =>
      'From date cannot be later than To date';

  @override
  String get overview => 'Overview';

  @override
  String get loadingAnalytics => 'Loading analytics...';

  @override
  String get vehicleAnalytics => 'Vehicle Analytics';

  @override
  String get dateTimeRange => 'Date & Time Range';

  @override
  String get startDateTime => 'Start Date & Time';

  @override
  String get endDateTime => 'End Date & Time';

  @override
  String get chartsGroupedByDate => 'Charts grouped by date';

  @override
  String get chartsGroupedByHour => 'Charts grouped by hour';

  @override
  String get maximumSpeed => 'Maximum Speed';

  @override
  String get driveTime => 'Drive Time';

  @override
  String get stopTime => 'Stop Time';

  @override
  String get fuelUsed => 'Fuel Used';

  @override
  String get amountSpent => 'Amount Spent';

  @override
  String get maxSpeedPerDay => 'Max Speed per Day (km/h)';

  @override
  String get speedKmh => 'Speed (km/h)';

  @override
  String get distancePerDay => 'Distance per Day (km)';

  @override
  String get distanceKm => 'Distance (km)';

  @override
  String get fuelUsedLiters => 'Fuel Used (Liters)';

  @override
  String get stopDurationMinutes => 'Stop Duration (Minutes)';

  @override
  String get engineHoursPerDay => 'Engine Hours per Day';

  @override
  String get engineHoursCumulative => 'Engine Hours (Cumulative)';

  @override
  String get noData => 'No data';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get liveTracking => 'Live Tracking';

  @override
  String updatedAt(Object value) {
    return 'Updated at : $value';
  }

  @override
  String get traffic => 'Traffic';

  @override
  String vehicleLocationShare(Object url) {
    return 'Vehicle Location: $url';
  }

  @override
  String get moving => 'Moving';

  @override
  String get callToDriver => 'Call To Driver';

  @override
  String get immobilizer => 'IMMOBILIZER';

  @override
  String get last30Days => 'Last 30 Days';

  @override
  String get pleaseSelectDateRangeFirst => 'Please select date range first';

  @override
  String get fromTime => 'From Time';

  @override
  String get toTime => 'To Time';

  @override
  String get applyRange => 'Apply Range';

  @override
  String get fleetInsightTitle => 'Fleet Insight AI';

  @override
  String get fleetStatusStable => 'Stable';

  @override
  String get fleetStatusNeedsAttention => 'Needs Attention';

  @override
  String get fleetStatusCritical => 'Critical';

  @override
  String get fleetInsightIntroPositive1 => 'Fleet is moving steadily today.';

  @override
  String get fleetInsightIntroPositive2 => 'Operations look stable right now.';

  @override
  String get fleetInsightIntroPositive3 =>
      'Current trend is healthy across your fleet.';

  @override
  String get fleetInsightIntroWarning1 =>
      'Fleet needs some attention in one area.';

  @override
  String get fleetInsightIntroWarning2 =>
      'A few signals are drifting from target.';

  @override
  String get fleetInsightIntroWarning3 =>
      'Current snapshot shows moderate operational pressure.';

  @override
  String get fleetInsightIntroCritical1 =>
      'Immediate action is recommended for fleet health.';

  @override
  String get fleetInsightIntroCritical2 =>
      'Current indicators suggest high operational risk.';

  @override
  String get fleetInsightIntroCritical3 =>
      'Priority follow-up is needed on critical metrics.';

  @override
  String get fleetInsightAvailabilityTitle => 'Availability needs attention.';

  @override
  String fleetInsightAvailabilityDetail(
      Object offlineNow, Object totalVehicles, Object offline24h) {
    return '$offlineNow/$totalVehicles vehicles are offline right now, including $offline24h offline for more than 24 hours.';
  }

  @override
  String get fleetInsightSafetyTitle => 'Overspeed behavior is driving risk.';

  @override
  String fleetInsightSafetyVehicleDetail(Object vehicleName, Object count) {
    return '$vehicleName recorded $count overspeed alerts, the highest in fleet.';
  }

  @override
  String fleetInsightSafetyOverallDetail(Object overspeed, Object totalAlerts) {
    return '$overspeed overspeed alerts were observed from $totalAlerts total alerts.';
  }

  @override
  String get fleetInsightMaintenanceTitle =>
      'Maintenance backlog is affecting readiness.';

  @override
  String fleetInsightMaintenanceDetail(Object dueCount) {
    return '$dueCount maintenance item(s) are currently due or expired.';
  }

  @override
  String get fleetInsightTasksTitle => 'Task queue needs balancing.';

  @override
  String fleetInsightTasksDetail(Object taskBacklog, Object agingCount) {
    return '$taskBacklog tasks are open, with $agingCount older than 2 days.';
  }

  @override
  String get fleetInsightPerformanceTitle =>
      'Performance score is the key optimization area.';

  @override
  String fleetInsightPerformanceDetail(Object score) {
    return 'Average vehicle performance is $score/100 for the selected period.';
  }

  @override
  String get fleetInsightPerformanceLoading =>
      'Performance analytics are still loading from recent data.';

  @override
  String get fleetInsightExpenseTitle =>
      'Expense trend is an active watch area.';

  @override
  String fleetInsightExpenseDetail(Object amount, Object change) {
    return 'This month expense is Rs $amount with a $change% month-over-month change.';
  }

  @override
  String get fleetInsightDistanceTitle => 'Distance trend looks active today.';

  @override
  String fleetInsightDistanceLeaderDetail(
      Object vehicleName, Object distanceKm) {
    return '$vehicleName covered $distanceKm km, highest in fleet today.';
  }

  @override
  String fleetInsightDistanceTotalDetail(Object distanceKm) {
    return 'Fleet covered $distanceKm km in total today.';
  }

  @override
  String fleetInsightDistanceSpeedDetail(
      Object vehicleName, Object topSpeed, Object distanceKm) {
    return '$vehicleName reached $topSpeed km/h top speed, while fleet total distance is $distanceKm km.';
  }

  @override
  String fleetInsightDistanceAvgDetail(Object totalKm, Object avgKm) {
    return 'Fleet movement summary: $totalKm km total and $avgKm km average.';
  }

  @override
  String get fleetInsightMovementLoading => 'Movement analytics are loading.';

  @override
  String fleetInsightMovementSummary(Object totalKm, Object avgKm) {
    return 'Fleet moved $totalKm km today (avg $avgKm km/vehicle).';
  }

  @override
  String fleetInsightHealthChip(Object score) {
    return 'Health $score/100';
  }

  @override
  String fleetInsightOnlineChip(Object count) {
    return 'Online $count';
  }

  @override
  String fleetInsightOfflineChip(Object count) {
    return 'Offline $count';
  }

  @override
  String fleetInsightOverspeedChip(Object count) {
    return 'Overspeed $count';
  }

  @override
  String fleetInsightMaintenanceChip(Object count) {
    return 'Due maintenance $count';
  }

  @override
  String fleetInsightOpenTasksChip(Object count) {
    return 'Open tasks $count';
  }

  @override
  String fleetInsightPerformanceChip(Object score) {
    return 'Perf $score/100';
  }

  @override
  String fleetInsightExpenseChip(Object change) {
    return 'Expense MoM $change%';
  }
}
