import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ur')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Autotel Fleet'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @urdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get urdu;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @driverOptions.
  ///
  /// In en, this message translates to:
  /// **'Driver Options'**
  String get driverOptions;

  /// No description provided for @manageDriversSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add, update, or remove drivers'**
  String get manageDriversSubtitle;

  /// No description provided for @addNewDriver.
  ///
  /// In en, this message translates to:
  /// **'Add New Driver'**
  String get addNewDriver;

  /// No description provided for @createNewDriver.
  ///
  /// In en, this message translates to:
  /// **'Create a new driver'**
  String get createNewDriver;

  /// No description provided for @editDriverLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit Driver'**
  String get editDriverLabel;

  /// No description provided for @updateDriverInfo.
  ///
  /// In en, this message translates to:
  /// **'Update driver info'**
  String get updateDriverInfo;

  /// No description provided for @deleteDriverLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete Driver'**
  String get deleteDriverLabel;

  /// No description provided for @permanentDeleteDriver.
  ///
  /// In en, this message translates to:
  /// **'Permanent delete driver'**
  String get permanentDeleteDriver;

  /// No description provided for @addDriverLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Driver'**
  String get addDriverLabel;

  /// No description provided for @assignDriverLabel.
  ///
  /// In en, this message translates to:
  /// **'Assign Driver'**
  String get assignDriverLabel;

  /// No description provided for @driverNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver Name'**
  String get driverNameLabel;

  /// No description provided for @enterDriverName.
  ///
  /// In en, this message translates to:
  /// **'Enter driver name'**
  String get enterDriverName;

  /// No description provided for @rfidLabel.
  ///
  /// In en, this message translates to:
  /// **'RFID'**
  String get rfidLabel;

  /// No description provided for @enterDriverRfid.
  ///
  /// In en, this message translates to:
  /// **'Enter driver RFID'**
  String get enterDriverRfid;

  /// No description provided for @selectDriverLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Driver'**
  String get selectDriverLabel;

  /// No description provided for @searchAndSelectDriver.
  ///
  /// In en, this message translates to:
  /// **'Search and select driver'**
  String get searchAndSelectDriver;

  /// No description provided for @pleaseSelectDriver.
  ///
  /// In en, this message translates to:
  /// **'Please select a driver'**
  String get pleaseSelectDriver;

  /// No description provided for @driverNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Driver name is required'**
  String get driverNameRequired;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @selectDrivers.
  ///
  /// In en, this message translates to:
  /// **'Select Drivers'**
  String get selectDrivers;

  /// No description provided for @useCheckboxToSelectDrivers.
  ///
  /// In en, this message translates to:
  /// **'Use the checkbox to select multiple drivers'**
  String get useCheckboxToSelectDrivers;

  /// No description provided for @searchDriverName.
  ///
  /// In en, this message translates to:
  /// **'Search driver name'**
  String get searchDriverName;

  /// No description provided for @noDriversFound.
  ///
  /// In en, this message translates to:
  /// **'No drivers found'**
  String get noDriversFound;

  /// No description provided for @driversSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} driver(s) selected'**
  String driversSelectedCount(Object count);

  /// No description provided for @noDriverLabel.
  ///
  /// In en, this message translates to:
  /// **'No Driver'**
  String get noDriverLabel;

  /// No description provided for @pleaseSelectAtLeastOneDriver.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one driver'**
  String get pleaseSelectAtLeastOneDriver;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @drivers.
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get drivers;

  /// No description provided for @addExpenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpenseLabel;

  /// No description provided for @editExpenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpenseLabel;

  /// No description provided for @selectExpenseType.
  ///
  /// In en, this message translates to:
  /// **'Select expense type'**
  String get selectExpenseType;

  /// No description provided for @expenseNameHint.
  ///
  /// In en, this message translates to:
  /// **'Expense name'**
  String get expenseNameHint;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @unitCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit cost'**
  String get unitCostLabel;

  /// No description provided for @supplierLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplierLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @enterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter valid quantity'**
  String get enterValidQuantity;

  /// No description provided for @enterValidUnitCost.
  ///
  /// In en, this message translates to:
  /// **'Enter valid unit cost'**
  String get enterValidUnitCost;

  /// No description provided for @optionalSupplier.
  ///
  /// In en, this message translates to:
  /// **'Optional supplier'**
  String get optionalSupplier;

  /// No description provided for @optionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Optional notes'**
  String get optionalNotes;

  /// No description provided for @alertSetting.
  ///
  /// In en, this message translates to:
  /// **'Alert Setting'**
  String get alertSetting;

  /// No description provided for @playAlertsAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Play Alerts Announcement'**
  String get playAlertsAnnouncement;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter old and new password to change it'**
  String get changePasswordSubtitle;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Login Email'**
  String get loginEmail;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone No.'**
  String get phoneNumberLabel;

  /// No description provided for @deviceLimit.
  ///
  /// In en, this message translates to:
  /// **'Device Limit'**
  String get deviceLimit;

  /// No description provided for @accountExpiry.
  ///
  /// In en, this message translates to:
  /// **'Account Expiry'**
  String get accountExpiry;

  /// No description provided for @unlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get languageUpdated;

  /// No description provided for @companySupport.
  ///
  /// In en, this message translates to:
  /// **'Company Support'**
  String get companySupport;

  /// No description provided for @contactCompanyDetails.
  ///
  /// In en, this message translates to:
  /// **'Contact & company details'**
  String get contactCompanyDetails;

  /// No description provided for @liveChat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get liveChat;

  /// No description provided for @wereHereToHelp.
  ///
  /// In en, this message translates to:
  /// **'We’re here to help'**
  String get wereHereToHelp;

  /// No description provided for @callLabel.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callLabel;

  /// No description provided for @messageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @websiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get websiteLabel;

  /// No description provided for @whatsAppLabel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsAppLabel;

  /// No description provided for @facebookLabel.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebookLabel;

  /// No description provided for @instagramLabel.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagramLabel;

  /// No description provided for @loadingDriverDetails.
  ///
  /// In en, this message translates to:
  /// **'Loading driver details...'**
  String get loadingDriverDetails;

  /// No description provided for @driverContactProfileDetails.
  ///
  /// In en, this message translates to:
  /// **'Driver contact and profile details'**
  String get driverContactProfileDetails;

  /// No description provided for @noDriverAssigned.
  ///
  /// In en, this message translates to:
  /// **'No driver assigned'**
  String get noDriverAssigned;

  /// No description provided for @assignDriverToVehicleToViewContactActions.
  ///
  /// In en, this message translates to:
  /// **'Assign a driver to this vehicle to\nview contact actions'**
  String get assignDriverToVehicleToViewContactActions;

  /// No description provided for @noPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'No phone number'**
  String get noPhoneNumber;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get noDescriptionAvailable;

  /// No description provided for @noContactInformationAvailable.
  ///
  /// In en, this message translates to:
  /// **'No contact information available'**
  String get noContactInformationAvailable;

  /// No description provided for @officeAddress.
  ///
  /// In en, this message translates to:
  /// **'Office Address'**
  String get officeAddress;

  /// No description provided for @exploreLabel.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreLabel;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @legalPoliciesAndUserAgreement.
  ///
  /// In en, this message translates to:
  /// **'Legal policies and user agreement'**
  String get legalPoliciesAndUserAgreement;

  /// No description provided for @privacyPolicyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyLabel;

  /// No description provided for @howWeProtectYourData.
  ///
  /// In en, this message translates to:
  /// **'How we protect your data'**
  String get howWeProtectYourData;

  /// No description provided for @companyNews.
  ///
  /// In en, this message translates to:
  /// **'Company News'**
  String get companyNews;

  /// No description provided for @latestUpdatesAndAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Latest updates and announcements'**
  String get latestUpdatesAndAnnouncements;

  /// No description provided for @galleryPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Gallery Permission Required'**
  String get galleryPermissionRequired;

  /// No description provided for @galleryPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Please allow Photos access from {platform} for this app, then try again.'**
  String galleryPermissionMessage(Object platform);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @hiUser.
  ///
  /// In en, this message translates to:
  /// **'Hi, {email}'**
  String hiUser(Object email);

  /// No description provided for @hi.
  ///
  /// In en, this message translates to:
  /// **'Hi'**
  String get hi;

  /// No description provided for @statusTab.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusTab;

  /// No description provided for @mapTab.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTab;

  /// No description provided for @dashboardTab.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTab;

  /// No description provided for @alertsTab.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @managementTab.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get managementTab;

  /// No description provided for @backToAdmin.
  ///
  /// In en, this message translates to:
  /// **'Back to Admin'**
  String get backToAdmin;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @notificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTooltip;

  /// No description provided for @customizeDashboard.
  ///
  /// In en, this message translates to:
  /// **'Customize Dashboard'**
  String get customizeDashboard;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @notificationFilters.
  ///
  /// In en, this message translates to:
  /// **'Notification Filters'**
  String get notificationFilters;

  /// No description provided for @searchByVehicleAndType.
  ///
  /// In en, this message translates to:
  /// **'Search By Vehicle And Type'**
  String get searchByVehicleAndType;

  /// No description provided for @searchByDateRange.
  ///
  /// In en, this message translates to:
  /// **'Search By Date Range'**
  String get searchByDateRange;

  /// No description provided for @vehicleLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicleLabel;

  /// No description provided for @dashboardCustomizeHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder cards. Toggle switch to hide/show cards.'**
  String get dashboardCustomizeHint;

  /// No description provided for @noDashboardCardsSelected.
  ///
  /// In en, this message translates to:
  /// **'No dashboard cards selected. Tap Customize to enable cards.'**
  String get noDashboardCardsSelected;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorLabel(Object error);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @searchVehicle.
  ///
  /// In en, this message translates to:
  /// **'Search vehicle'**
  String get searchVehicle;

  /// No description provided for @allGroups.
  ///
  /// In en, this message translates to:
  /// **'All Groups'**
  String get allGroups;

  /// No description provided for @allVehicles.
  ///
  /// In en, this message translates to:
  /// **'All Vehicles'**
  String get allVehicles;

  /// No description provided for @viewAllVehicles.
  ///
  /// In en, this message translates to:
  /// **'View All Vehicles'**
  String get viewAllVehicles;

  /// No description provided for @vehicleStatusAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get vehicleStatusAll;

  /// No description provided for @vehicleStatusRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get vehicleStatusRunning;

  /// No description provided for @vehicleStatusStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get vehicleStatusStopped;

  /// No description provided for @vehicleStatusIdle.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get vehicleStatusIdle;

  /// No description provided for @vehicleStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get vehicleStatusOffline;

  /// No description provided for @vehicleStatusNoData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get vehicleStatusNoData;

  /// No description provided for @vehicleStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get vehicleStatusExpired;

  /// No description provided for @vehicleStatusParked.
  ///
  /// In en, this message translates to:
  /// **'Parked'**
  String get vehicleStatusParked;

  /// No description provided for @vehicleStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get vehicleStatusUnknown;

  /// No description provided for @noVehiclesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No vehicles available.'**
  String get noVehiclesAvailable;

  /// No description provided for @noAddressFound.
  ///
  /// In en, this message translates to:
  /// **'No Address Found'**
  String get noAddressFound;

  /// No description provided for @noVehiclesInSelectedGroup.
  ///
  /// In en, this message translates to:
  /// **'No vehicles available in the selected group.'**
  String get noVehiclesInSelectedGroup;

  /// No description provided for @noVehiclesCurrentStatus.
  ///
  /// In en, this message translates to:
  /// **'No vehicles are currently {status}.'**
  String noVehiclesCurrentStatus(Object status);

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @notAvailableShort.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailableShort;

  /// No description provided for @engineKilled.
  ///
  /// In en, this message translates to:
  /// **'Engine Killed'**
  String get engineKilled;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From Date'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To Date'**
  String get toDate;

  /// No description provided for @deleteAlerts.
  ///
  /// In en, this message translates to:
  /// **'Delete Alerts'**
  String get deleteAlerts;

  /// No description provided for @deleteAlertsConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} alert(s)?'**
  String deleteAlertsConfirmation(Object count);

  /// No description provided for @searchNotification.
  ///
  /// In en, this message translates to:
  /// **'Search Notification'**
  String get searchNotification;

  /// No description provided for @noAlertsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No alerts match your search'**
  String get noAlertsMatchSearch;

  /// No description provided for @noAlertsFound.
  ///
  /// In en, this message translates to:
  /// **'No alerts found'**
  String get noAlertsFound;

  /// No description provided for @locationUnavailableForAlert.
  ///
  /// In en, this message translates to:
  /// **'Location is not available for this alert'**
  String get locationUnavailableForAlert;

  /// No description provided for @alertsDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Alerts deleted successfully'**
  String get alertsDeletedSuccessfully;

  /// No description provided for @noTime.
  ///
  /// In en, this message translates to:
  /// **'No time'**
  String get noTime;

  /// No description provided for @localReminders.
  ///
  /// In en, this message translates to:
  /// **'Local Reminders'**
  String get localReminders;

  /// No description provided for @activeReminders.
  ///
  /// In en, this message translates to:
  /// **'Active reminders'**
  String get activeReminders;

  /// No description provided for @pastReminders.
  ///
  /// In en, this message translates to:
  /// **'Past reminders'**
  String get pastReminders;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Items'**
  String itemsCount(Object count);

  /// No description provided for @deleteReminder.
  ///
  /// In en, this message translates to:
  /// **'Delete Reminder'**
  String get deleteReminder;

  /// No description provided for @deleteReminderConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this reminder?'**
  String get deleteReminderConfirmation;

  /// No description provided for @reminderDeleted.
  ///
  /// In en, this message translates to:
  /// **'Reminder deleted'**
  String get reminderDeleted;

  /// No description provided for @noRemindersFound.
  ///
  /// In en, this message translates to:
  /// **'No reminders found'**
  String get noRemindersFound;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @addReminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminderLabel;

  /// No description provided for @editReminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit Reminder'**
  String get editReminderLabel;

  /// No description provided for @selectType.
  ///
  /// In en, this message translates to:
  /// **'Select type'**
  String get selectType;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @reminderTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Reminder title'**
  String get reminderTitleHint;

  /// No description provided for @dueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDateLabel;

  /// No description provided for @dueTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Due Time'**
  String get dueTimeLabel;

  /// No description provided for @dateIgnoredForDailyRepeat.
  ///
  /// In en, this message translates to:
  /// **'Date is ignored for daily repeat'**
  String get dateIgnoredForDailyRepeat;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @reminderTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Reminder title is required'**
  String get reminderTitleRequired;

  /// No description provided for @pleaseSelectDueDate.
  ///
  /// In en, this message translates to:
  /// **'Please select due date'**
  String get pleaseSelectDueDate;

  /// No description provided for @pleaseSelectDueTime.
  ///
  /// In en, this message translates to:
  /// **'Please select due time'**
  String get pleaseSelectDueTime;

  /// No description provided for @reminderSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Reminder saved successfully'**
  String get reminderSavedSuccessfully;

  /// No description provided for @reminderUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Reminder updated successfully'**
  String get reminderUpdatedSuccessfully;

  /// No description provided for @oilChange.
  ///
  /// In en, this message translates to:
  /// **'Oil Change'**
  String get oilChange;

  /// No description provided for @tireRotation.
  ///
  /// In en, this message translates to:
  /// **'Tire Rotation'**
  String get tireRotation;

  /// No description provided for @brakeInspection.
  ///
  /// In en, this message translates to:
  /// **'Brake Inspection'**
  String get brakeInspection;

  /// No description provided for @airFilterReplacement.
  ///
  /// In en, this message translates to:
  /// **'Air Filter Replacement'**
  String get airFilterReplacement;

  /// No description provided for @sparkPlugsReplacement.
  ///
  /// In en, this message translates to:
  /// **'Spark Plugs Replacement'**
  String get sparkPlugsReplacement;

  /// No description provided for @batteryCheck.
  ///
  /// In en, this message translates to:
  /// **'Battery Check'**
  String get batteryCheck;

  /// No description provided for @charging.
  ///
  /// In en, this message translates to:
  /// **'Charging'**
  String get charging;

  /// No description provided for @insuranceRenewal.
  ///
  /// In en, this message translates to:
  /// **'Insurance Renewal'**
  String get insuranceRenewal;

  /// No description provided for @registrationRenewal.
  ///
  /// In en, this message translates to:
  /// **'Registration Renewal'**
  String get registrationRenewal;

  /// No description provided for @emissionTest.
  ///
  /// In en, this message translates to:
  /// **'Emission Test'**
  String get emissionTest;

  /// No description provided for @generalService.
  ///
  /// In en, this message translates to:
  /// **'General Service'**
  String get generalService;

  /// No description provided for @coolantFlush.
  ///
  /// In en, this message translates to:
  /// **'Coolant Flush'**
  String get coolantFlush;

  /// No description provided for @repeatOneTime.
  ///
  /// In en, this message translates to:
  /// **'One-time'**
  String get repeatOneTime;

  /// No description provided for @repeatRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get repeatRecurring;

  /// No description provided for @tasksAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Tasks Analytics'**
  String get tasksAnalytics;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get seeMore;

  /// No description provided for @noTasksAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tasks available'**
  String get noTasksAvailable;

  /// No description provided for @allTasks.
  ///
  /// In en, this message translates to:
  /// **'All Tasks'**
  String get allTasks;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @noTasksFound.
  ///
  /// In en, this message translates to:
  /// **'No tasks found'**
  String get noTasksFound;

  /// No description provided for @searchTasksByTitleOrVehicle.
  ///
  /// In en, this message translates to:
  /// **'Search by title or vehicle'**
  String get searchTasksByTitleOrVehicle;

  /// No description provided for @showingTasksCount.
  ///
  /// In en, this message translates to:
  /// **'Showing {count} tasks'**
  String showingTasksCount(Object count);

  /// No description provided for @showingTasksCountOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Showing {count} of {total} tasks'**
  String showingTasksCountOfTotal(Object count, Object total);

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @latestTasks.
  ///
  /// In en, this message translates to:
  /// **'Latest Tasks'**
  String get latestTasks;

  /// No description provided for @taskFunnel.
  ///
  /// In en, this message translates to:
  /// **'Task Funnel'**
  String get taskFunnel;

  /// No description provided for @taskNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get taskNew;

  /// No description provided for @taskInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get taskInProgress;

  /// No description provided for @taskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get taskCompleted;

  /// No description provided for @taskFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get taskFailed;

  /// No description provided for @hasStops.
  ///
  /// In en, this message translates to:
  /// **'Has Stops'**
  String get hasStops;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @routePlayback.
  ///
  /// In en, this message translates to:
  /// **'Route Playback'**
  String get routePlayback;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get deleteTask;

  /// No description provided for @deleteTaskConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this task?'**
  String get deleteTaskConfirmation;

  /// No description provided for @assignTask.
  ///
  /// In en, this message translates to:
  /// **'Assign Task'**
  String get assignTask;

  /// No description provided for @recreateTaskForVehicle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to recreate this task for \"{vehicleName}\"?'**
  String recreateTaskForVehicle(Object vehicleName);

  /// No description provided for @selectVehicleToRecreateTask.
  ///
  /// In en, this message translates to:
  /// **'Select a vehicle to recreate this task.'**
  String get selectVehicleToRecreateTask;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// No description provided for @reachedAt.
  ///
  /// In en, this message translates to:
  /// **'Reached at'**
  String get reachedAt;

  /// No description provided for @leftAt.
  ///
  /// In en, this message translates to:
  /// **'Left at'**
  String get leftAt;

  /// No description provided for @taskStop.
  ///
  /// In en, this message translates to:
  /// **'Stop {index}'**
  String taskStop(Object index);

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @completionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get completionRate;

  /// No description provided for @failureRate.
  ///
  /// In en, this message translates to:
  /// **'Failure Rate'**
  String get failureRate;

  /// No description provided for @tasksCountSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} tasks'**
  String tasksCountSummary(Object count, Object total);

  /// No description provided for @unstartedTaskAging.
  ///
  /// In en, this message translates to:
  /// **'Unstarted Task Aging'**
  String get unstartedTaskAging;

  /// No description provided for @inProgressAging.
  ///
  /// In en, this message translates to:
  /// **'In Progress Aging'**
  String get inProgressAging;

  /// No description provided for @tasksNotCompletedWithin10Days.
  ///
  /// In en, this message translates to:
  /// **'Tasks not completed within 10 days'**
  String get tasksNotCompletedWithin10Days;

  /// No description provided for @vehicleTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'{vehicleName} Tasks'**
  String vehicleTasksTitle(Object vehicleName);

  /// No description provided for @successRate.
  ///
  /// In en, this message translates to:
  /// **'Success Rate'**
  String get successRate;

  /// No description provided for @avgCompletion.
  ///
  /// In en, this message translates to:
  /// **'Avg Completion'**
  String get avgCompletion;

  /// No description provided for @createdToDeliveryLeft.
  ///
  /// In en, this message translates to:
  /// **'Created to delivery left'**
  String get createdToDeliveryLeft;

  /// No description provided for @pickupResponse.
  ///
  /// In en, this message translates to:
  /// **'Pickup Response'**
  String get pickupResponse;

  /// No description provided for @createdToPickupReached.
  ///
  /// In en, this message translates to:
  /// **'Created to pickup reached'**
  String get createdToPickupReached;

  /// No description provided for @pickupDwell.
  ///
  /// In en, this message translates to:
  /// **'Pickup Dwell'**
  String get pickupDwell;

  /// No description provided for @pickupLeftMinusReached.
  ///
  /// In en, this message translates to:
  /// **'Pickup left minus reached'**
  String get pickupLeftMinusReached;

  /// No description provided for @stopDwell.
  ///
  /// In en, this message translates to:
  /// **'Stop Dwell'**
  String get stopDwell;

  /// No description provided for @averageAcrossAllStops.
  ///
  /// In en, this message translates to:
  /// **'Average across all stops'**
  String get averageAcrossAllStops;

  /// No description provided for @deliveryDwell.
  ///
  /// In en, this message translates to:
  /// **'Delivery Dwell'**
  String get deliveryDwell;

  /// No description provided for @deliveryLeftMinusReached.
  ///
  /// In en, this message translates to:
  /// **'Delivery left minus reached'**
  String get deliveryLeftMinusReached;

  /// No description provided for @stopComplexityTrend.
  ///
  /// In en, this message translates to:
  /// **'Stop Complexity Trend'**
  String get stopComplexityTrend;

  /// No description provided for @directJobs.
  ///
  /// In en, this message translates to:
  /// **'Direct Jobs'**
  String get directJobs;

  /// No description provided for @noStops.
  ///
  /// In en, this message translates to:
  /// **'No stops'**
  String get noStops;

  /// No description provided for @multiStopJobs.
  ///
  /// In en, this message translates to:
  /// **'Multi-stop Jobs'**
  String get multiStopJobs;

  /// No description provided for @oneOrMoreStops.
  ///
  /// In en, this message translates to:
  /// **'One or more stops'**
  String get oneOrMoreStops;

  /// No description provided for @recentFailedTasks.
  ///
  /// In en, this message translates to:
  /// **'Recent Failed Tasks'**
  String get recentFailedTasks;

  /// No description provided for @noRecentFailedTasksForVehicle.
  ///
  /// In en, this message translates to:
  /// **'No recent failed tasks for this vehicle'**
  String get noRecentFailedTasksForVehicle;

  /// No description provided for @taskNumber.
  ///
  /// In en, this message translates to:
  /// **'Task #{id}'**
  String taskNumber(Object id);

  /// No description provided for @vehicleWorkloadDistribution.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Workload Distribution'**
  String get vehicleWorkloadDistribution;

  /// No description provided for @noVehicleWorkloadData.
  ///
  /// In en, this message translates to:
  /// **'No vehicle workload data available'**
  String get noVehicleWorkloadData;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @maintenanceReminder.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Reminder'**
  String get maintenanceReminder;

  /// No description provided for @allMaintenance.
  ///
  /// In en, this message translates to:
  /// **'All Maintenance'**
  String get allMaintenance;

  /// No description provided for @dueMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Due Maintenance'**
  String get dueMaintenance;

  /// No description provided for @overdueMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Overdue Maintenance'**
  String get overdueMaintenance;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @maintenanceAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Analytics'**
  String get maintenanceAnalytics;

  /// No description provided for @healthScore.
  ///
  /// In en, this message translates to:
  /// **'Health Score'**
  String get healthScore;

  /// No description provided for @healthyStateSummary.
  ///
  /// In en, this message translates to:
  /// **'{ok} of {total} in healthy state'**
  String healthyStateSummary(Object ok, Object total);

  /// No description provided for @dueSoon.
  ///
  /// In en, this message translates to:
  /// **'Due Soon'**
  String get dueSoon;

  /// No description provided for @overdueCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Overdue: {count}'**
  String overdueCountLabel(Object count);

  /// No description provided for @dueSoonWindows.
  ///
  /// In en, this message translates to:
  /// **'Due Soon Windows'**
  String get dueSoonWindows;

  /// No description provided for @dueInNextDays.
  ///
  /// In en, this message translates to:
  /// **'Due in Next {days} Days'**
  String dueInNextDays(Object days);

  /// No description provided for @overdueByType.
  ///
  /// In en, this message translates to:
  /// **'Overdue by Type'**
  String get overdueByType;

  /// No description provided for @topOverdueServices.
  ///
  /// In en, this message translates to:
  /// **'Top Overdue Services'**
  String get topOverdueServices;

  /// No description provided for @topVehiclesByOverdue.
  ///
  /// In en, this message translates to:
  /// **'Top Vehicles by Overdue'**
  String get topVehiclesByOverdue;

  /// No description provided for @nextDueByLeftValue.
  ///
  /// In en, this message translates to:
  /// **'Next Due by Left Value'**
  String get nextDueByLeftValue;

  /// No description provided for @upcomingCalendar.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Calendar'**
  String get upcomingCalendar;

  /// No description provided for @criticalMaintenanceAlerts.
  ///
  /// In en, this message translates to:
  /// **'Critical Maintenance Alerts'**
  String get criticalMaintenanceAlerts;

  /// No description provided for @noOverdueVehicles.
  ///
  /// In en, this message translates to:
  /// **'No overdue vehicles'**
  String get noOverdueVehicles;

  /// No description provided for @noUpcomingByLeft.
  ///
  /// In en, this message translates to:
  /// **'No upcoming by left'**
  String get noUpcomingByLeft;

  /// No description provided for @noUpcomingDates.
  ///
  /// In en, this message translates to:
  /// **'No upcoming dates'**
  String get noUpcomingDates;

  /// No description provided for @noCriticalMaintenanceAlerts.
  ///
  /// In en, this message translates to:
  /// **'No critical maintenance alerts'**
  String get noCriticalMaintenanceAlerts;

  /// No description provided for @fuelPrices.
  ///
  /// In en, this message translates to:
  /// **'Fuel Prices'**
  String get fuelPrices;

  /// No description provided for @petrol.
  ///
  /// In en, this message translates to:
  /// **'Petrol'**
  String get petrol;

  /// No description provided for @diesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get diesel;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdated;

  /// No description provided for @offlineOver24Hours.
  ///
  /// In en, this message translates to:
  /// **'Offline Over 24 Hours'**
  String get offlineOver24Hours;

  /// No description provided for @noVehiclesOffline24h.
  ///
  /// In en, this message translates to:
  /// **'No vehicles offline for more than 24 hours'**
  String get noVehiclesOffline24h;

  /// No description provided for @expenseAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Expense Analytics'**
  String get expenseAnalytics;

  /// No description provided for @expenseTrend.
  ///
  /// In en, this message translates to:
  /// **'Expense Trend'**
  String get expenseTrend;

  /// No description provided for @topExpenseTypes.
  ///
  /// In en, this message translates to:
  /// **'Top Expense Types'**
  String get topExpenseTypes;

  /// No description provided for @topVehiclesByExpense.
  ///
  /// In en, this message translates to:
  /// **'Top Vehicles by Expense'**
  String get topVehiclesByExpense;

  /// No description provided for @recentExpenseActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Expense Activity'**
  String get recentExpenseActivity;

  /// No description provided for @noTypeData.
  ///
  /// In en, this message translates to:
  /// **'No type data'**
  String get noTypeData;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @changeLabel.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeLabel;

  /// No description provided for @totalRange.
  ///
  /// In en, this message translates to:
  /// **'Total (Range)'**
  String get totalRange;

  /// No description provided for @avgPerTxn.
  ///
  /// In en, this message translates to:
  /// **'Avg / Txn'**
  String get avgPerTxn;

  /// No description provided for @avgPerDay.
  ///
  /// In en, this message translates to:
  /// **'Avg / Day'**
  String get avgPerDay;

  /// No description provided for @noTrendData.
  ///
  /// In en, this message translates to:
  /// **'No trend data'**
  String get noTrendData;

  /// No description provided for @performanceAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Performance Analytics'**
  String get performanceAnalytics;

  /// No description provided for @vehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehicles;

  /// No description provided for @scoredFromAlerts.
  ///
  /// In en, this message translates to:
  /// **'Scored from alerts'**
  String get scoredFromAlerts;

  /// No description provided for @mappedFromAssignment.
  ///
  /// In en, this message translates to:
  /// **'Mapped from current assignment'**
  String get mappedFromAssignment;

  /// No description provided for @topVehicles.
  ///
  /// In en, this message translates to:
  /// **'Top Vehicles'**
  String get topVehicles;

  /// No description provided for @topDrivers.
  ///
  /// In en, this message translates to:
  /// **'Top Drivers'**
  String get topDrivers;

  /// No description provided for @allVehiclePerformance.
  ///
  /// In en, this message translates to:
  /// **'All Vehicle Performance'**
  String get allVehiclePerformance;

  /// No description provided for @allDriverPerformance.
  ///
  /// In en, this message translates to:
  /// **'All Driver Performance'**
  String get allDriverPerformance;

  /// No description provided for @noAlertsForDateRange.
  ///
  /// In en, this message translates to:
  /// **'No idle/overspeed alerts found for selected date range.'**
  String get noAlertsForDateRange;

  /// No description provided for @alertsCount.
  ///
  /// In en, this message translates to:
  /// **'Alerts Count'**
  String get alertsCount;

  /// No description provided for @totalWord.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalWord;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total: {count}'**
  String totalLabel(Object count);

  /// No description provided for @distanceTravelled.
  ///
  /// In en, this message translates to:
  /// **'Distance Travelled'**
  String get distanceTravelled;

  /// No description provided for @totalDistance.
  ///
  /// In en, this message translates to:
  /// **'Total Distance'**
  String get totalDistance;

  /// No description provided for @averageDistance.
  ///
  /// In en, this message translates to:
  /// **'Average Distance'**
  String get averageDistance;

  /// No description provided for @topSpeedingVehicles.
  ///
  /// In en, this message translates to:
  /// **'Top Speeding Vehicles'**
  String get topSpeedingVehicles;

  /// No description provided for @vehicleFallback.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicleFallback;

  /// No description provided for @noMaintenanceItems.
  ///
  /// In en, this message translates to:
  /// **'No maintenance items'**
  String get noMaintenanceItems;

  /// No description provided for @maintenanceNumber.
  ///
  /// In en, this message translates to:
  /// **'Maintenance #{index}'**
  String maintenanceNumber(Object index);

  /// No description provided for @vehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @interval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get interval;

  /// No description provided for @lastService.
  ///
  /// In en, this message translates to:
  /// **'Last Service'**
  String get lastService;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @percent.
  ///
  /// In en, this message translates to:
  /// **'Percent'**
  String get percent;

  /// No description provided for @leftLabel.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get leftLabel;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @expiresDate.
  ///
  /// In en, this message translates to:
  /// **'Expires Date'**
  String get expiresDate;

  /// No description provided for @remindDate.
  ///
  /// In en, this message translates to:
  /// **'Remind Date'**
  String get remindDate;

  /// No description provided for @daysTotalElapsed.
  ///
  /// In en, this message translates to:
  /// **'Days (Total/Elapsed)'**
  String get daysTotalElapsed;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'Days Left'**
  String get daysLeft;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @unknownVehicle.
  ///
  /// In en, this message translates to:
  /// **'Unknown Vehicle'**
  String get unknownVehicle;

  /// No description provided for @daysShort.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String daysShort(Object days);

  /// No description provided for @daysOverdue.
  ///
  /// In en, this message translates to:
  /// **'{days} days overdue'**
  String daysOverdue(Object days);

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @scopeAllVehicles.
  ///
  /// In en, this message translates to:
  /// **'Scope: All Vehicles'**
  String get scopeAllVehicles;

  /// No description provided for @totalServices.
  ///
  /// In en, this message translates to:
  /// **'Total Services: {count}'**
  String totalServices(Object count);

  /// No description provided for @reportMaintenanceAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Analytics Report'**
  String get reportMaintenanceAnalytics;

  /// No description provided for @reportPerformanceAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Performance Analytics Report'**
  String get reportPerformanceAnalytics;

  /// No description provided for @reportOffline24h.
  ///
  /// In en, this message translates to:
  /// **'Offline Over 24 Hours Report'**
  String get reportOffline24h;

  /// No description provided for @generatedAt.
  ///
  /// In en, this message translates to:
  /// **'Generated: {value}'**
  String generatedAt(Object value);

  /// No description provided for @totalVehiclesReport.
  ///
  /// In en, this message translates to:
  /// **'Total Vehicles: {count}'**
  String totalVehiclesReport(Object count);

  /// No description provided for @offlineSinceDuration.
  ///
  /// In en, this message translates to:
  /// **'{vehicle} | Offline since {since} | Duration: {duration}'**
  String offlineSinceDuration(Object vehicle, Object since, Object duration);

  /// No description provided for @offlineOver24HoursWithCount.
  ///
  /// In en, this message translates to:
  /// **'Offline Over 24 Hours ({count})'**
  String offlineOver24HoursWithCount(Object count);

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get noRecentActivity;

  /// No description provided for @liveTab.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get liveTab;

  /// No description provided for @analyticsTab.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTab;

  /// No description provided for @reportTab.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportTab;

  /// No description provided for @formatLabel.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get formatLabel;

  /// No description provided for @speedLimitKmh.
  ///
  /// In en, this message translates to:
  /// **'Speed Limit (km/h)'**
  String get speedLimitKmh;

  /// No description provided for @ignitionOffDurationMin.
  ///
  /// In en, this message translates to:
  /// **'Ignition Off Duration (min)'**
  String get ignitionOffDurationMin;

  /// No description provided for @stopsMinutes.
  ///
  /// In en, this message translates to:
  /// **'Stops (minutes)'**
  String get stopsMinutes;

  /// No description provided for @geofenceIdsCommaSeparated.
  ///
  /// In en, this message translates to:
  /// **'Geofence IDs (comma separated)'**
  String get geofenceIdsCommaSeparated;

  /// No description provided for @showAddresses.
  ///
  /// In en, this message translates to:
  /// **'Show Addresses'**
  String get showAddresses;

  /// No description provided for @zonesInstead.
  ///
  /// In en, this message translates to:
  /// **'Zones Instead'**
  String get zonesInstead;

  /// No description provided for @noGeofencesFound.
  ///
  /// In en, this message translates to:
  /// **'No geofences found'**
  String get noGeofencesFound;

  /// No description provided for @reloadGeofences.
  ///
  /// In en, this message translates to:
  /// **'Reload Geofences'**
  String get reloadGeofences;

  /// No description provided for @geofencesSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} geofence(s) selected'**
  String geofencesSelectedCount(Object count);

  /// No description provided for @reportFieldsLabel.
  ///
  /// In en, this message translates to:
  /// **'Fields: {fields}'**
  String reportFieldsLabel(Object fields);

  /// No description provided for @generateLabel.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generateLabel;

  /// No description provided for @pleaseSelectBothDates.
  ///
  /// In en, this message translates to:
  /// **'Please select both dates'**
  String get pleaseSelectBothDates;

  /// No description provided for @noReportsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No reports available'**
  String get noReportsAvailable;

  /// No description provided for @reportTypesLabel.
  ///
  /// In en, this message translates to:
  /// **'Report Types'**
  String get reportTypesLabel;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @moreReports.
  ///
  /// In en, this message translates to:
  /// **'More Reports'**
  String get moreReports;

  /// No description provided for @dailyTravelReport.
  ///
  /// In en, this message translates to:
  /// **'Daily Travel Report'**
  String get dailyTravelReport;

  /// No description provided for @travelSummaryWithPlaybackImage.
  ///
  /// In en, this message translates to:
  /// **'Travel Summary with Playback Image'**
  String get travelSummaryWithPlaybackImage;

  /// No description provided for @travelSummary.
  ///
  /// In en, this message translates to:
  /// **'Travel Summary'**
  String get travelSummary;

  /// No description provided for @stopsMoveSummary.
  ///
  /// In en, this message translates to:
  /// **'Stops Move Summary'**
  String get stopsMoveSummary;

  /// No description provided for @eventsReport.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventsReport;

  /// No description provided for @alertsReport.
  ///
  /// In en, this message translates to:
  /// **'Alerts Report'**
  String get alertsReport;

  /// No description provided for @tripReport.
  ///
  /// In en, this message translates to:
  /// **'Trip Report'**
  String get tripReport;

  /// No description provided for @playbackLabel.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get playbackLabel;

  /// No description provided for @tripsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Trips ({count})'**
  String tripsCountLabel(Object count);

  /// No description provided for @parkedCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Parked ({count})'**
  String parkedCountLabel(Object count);

  /// No description provided for @alertsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Alerts ({count})'**
  String alertsCountLabel(Object count);

  /// No description provided for @noTripsFound.
  ///
  /// In en, this message translates to:
  /// **'No trips found'**
  String get noTripsFound;

  /// No description provided for @noParkedIntervals.
  ///
  /// In en, this message translates to:
  /// **'No parked intervals'**
  String get noParkedIntervals;

  /// No description provided for @noHistoryAlertsFound.
  ///
  /// In en, this message translates to:
  /// **'No alerts found'**
  String get noHistoryAlertsFound;

  /// No description provided for @playingRouteHighlightedGreen.
  ///
  /// In en, this message translates to:
  /// **'Playing - route highlighted green'**
  String get playingRouteHighlightedGreen;

  /// No description provided for @pausedLabel.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pausedLabel;

  /// No description provided for @totalTrips.
  ///
  /// In en, this message translates to:
  /// **'Total Trips'**
  String get totalTrips;

  /// No description provided for @moveTime.
  ///
  /// In en, this message translates to:
  /// **'Move Time'**
  String get moveTime;

  /// No description provided for @fuelLtr.
  ///
  /// In en, this message translates to:
  /// **'Fuel (LTR)'**
  String get fuelLtr;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @topSpeed.
  ///
  /// In en, this message translates to:
  /// **'Top Speed'**
  String get topSpeed;

  /// No description provided for @rsAmount.
  ///
  /// In en, this message translates to:
  /// **'Rs. {amount}'**
  String rsAmount(Object amount);

  /// No description provided for @taskPlayback.
  ///
  /// In en, this message translates to:
  /// **'Task Playback'**
  String get taskPlayback;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @currentVehicleLocationHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'This is Current Location of the Vehicle. To see History choose Filter or give date range'**
  String get currentVehicleLocationHistoryHint;

  /// No description provided for @loadingHistory.
  ///
  /// In en, this message translates to:
  /// **'Loading history...'**
  String get loadingHistory;

  /// No description provided for @currentLiveLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Live Location'**
  String get currentLiveLocation;

  /// No description provided for @historyTab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTab;

  /// No description provided for @alertsTabLong.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsTabLong;

  /// No description provided for @infoTab.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get infoTab;

  /// No description provided for @vehicleOffline.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Offline'**
  String get vehicleOffline;

  /// No description provided for @vehicleOfflineSince.
  ///
  /// In en, this message translates to:
  /// **'Vehicle is offline since {time}.'**
  String vehicleOfflineSince(Object time);

  /// No description provided for @unknownTime.
  ///
  /// In en, this message translates to:
  /// **'unknown time'**
  String get unknownTime;

  /// No description provided for @vehiclePlanExpired.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Plan Expired'**
  String get vehiclePlanExpired;

  /// No description provided for @vehiclePlanExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'This vehicle is expired. Please renew your plan and contact your service provider.'**
  String get vehiclePlanExpiredMessage;

  /// No description provided for @vehicleLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Vehicle location is unavailable.'**
  String get vehicleLocationUnavailable;

  /// No description provided for @unableOpenDirections.
  ///
  /// In en, this message translates to:
  /// **'Unable to open map directions.'**
  String get unableOpenDirections;

  /// No description provided for @noLiveData.
  ///
  /// In en, this message translates to:
  /// **'No live data'**
  String get noLiveData;

  /// No description provided for @noVehicleDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'This vehicle has no data available.'**
  String get noVehicleDataAvailable;

  /// No description provided for @unableLoadTracking.
  ///
  /// In en, this message translates to:
  /// **'Unable to load tracking'**
  String get unableLoadTracking;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get locationUnavailable;

  /// No description provided for @liveLocationUnavailableVehicle.
  ///
  /// In en, this message translates to:
  /// **'Live location is not available for this vehicle.'**
  String get liveLocationUnavailableVehicle;

  /// No description provided for @yourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get yourLocation;

  /// No description provided for @vehicleSensors.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Sensors'**
  String get vehicleSensors;

  /// No description provided for @sensorItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String sensorItemsCount(Object count);

  /// No description provided for @noSensorsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No sensors available'**
  String get noSensorsAvailable;

  /// No description provided for @driverAssignment.
  ///
  /// In en, this message translates to:
  /// **'Driver Assignment'**
  String get driverAssignment;

  /// No description provided for @alertAssign.
  ///
  /// In en, this message translates to:
  /// **'Alert Assign'**
  String get alertAssign;

  /// No description provided for @maintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenance;

  /// No description provided for @addServiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Service'**
  String get addServiceLabel;

  /// No description provided for @enterServiceName.
  ///
  /// In en, this message translates to:
  /// **'Enter service name'**
  String get enterServiceName;

  /// No description provided for @expirationByLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiration by'**
  String get expirationByLabel;

  /// No description provided for @selectExpirationType.
  ///
  /// In en, this message translates to:
  /// **'Select expiration type'**
  String get selectExpirationType;

  /// No description provided for @enterInterval.
  ///
  /// In en, this message translates to:
  /// **'Enter interval'**
  String get enterInterval;

  /// No description provided for @enterLastValueDate.
  ///
  /// In en, this message translates to:
  /// **'Enter last value/date'**
  String get enterLastValueDate;

  /// No description provided for @triggerEventWhenLeftLabel.
  ///
  /// In en, this message translates to:
  /// **'Trigger event when left'**
  String get triggerEventWhenLeftLabel;

  /// No description provided for @triggerEventWhenLeftHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1000 km'**
  String get triggerEventWhenLeftHint;

  /// No description provided for @renewAfterExpirationLabel.
  ///
  /// In en, this message translates to:
  /// **'Renew after expiration'**
  String get renewAfterExpirationLabel;

  /// No description provided for @odometerLabel.
  ///
  /// In en, this message translates to:
  /// **'Odometer'**
  String get odometerLabel;

  /// No description provided for @engineHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Engine hours'**
  String get engineHoursLabel;

  /// No description provided for @notificationEmailHint.
  ///
  /// In en, this message translates to:
  /// **'notification@email.com'**
  String get notificationEmailHint;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @searchVehicleByName.
  ///
  /// In en, this message translates to:
  /// **'Search vehicle by name'**
  String get searchVehicleByName;

  /// No description provided for @noVehiclesFoundForSearch.
  ///
  /// In en, this message translates to:
  /// **'No vehicle found'**
  String get noVehiclesFoundForSearch;

  /// No description provided for @defaultMapStyle.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultMapStyle;

  /// No description provided for @satelliteMapStyle.
  ///
  /// In en, this message translates to:
  /// **'Satellite'**
  String get satelliteMapStyle;

  /// No description provided for @loadingDevices.
  ///
  /// In en, this message translates to:
  /// **'Loading devices...'**
  String get loadingDevices;

  /// No description provided for @noDevicesFound.
  ///
  /// In en, this message translates to:
  /// **'No devices found.'**
  String get noDevicesFound;

  /// No description provided for @noVehiclesFound.
  ///
  /// In en, this message translates to:
  /// **'No vehicles found.'**
  String get noVehiclesFound;

  /// No description provided for @noVehiclesFoundForStatus.
  ///
  /// In en, this message translates to:
  /// **'No {status} vehicles found.'**
  String noVehiclesFoundForStatus(Object status);

  /// No description provided for @updatedSecondsAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated • {seconds}s ago'**
  String updatedSecondsAgo(Object seconds);

  /// No description provided for @speedKmhValue.
  ///
  /// In en, this message translates to:
  /// **'Speed: {speed} km/h'**
  String speedKmhValue(Object speed);

  /// No description provided for @updateValue.
  ///
  /// In en, this message translates to:
  /// **'Update: {value}'**
  String updateValue(Object value);

  /// No description provided for @openDetails.
  ///
  /// In en, this message translates to:
  /// **'Open details'**
  String get openDetails;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @trackManageExpenses.
  ///
  /// In en, this message translates to:
  /// **'Track and manage expenses'**
  String get trackManageExpenses;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @complainVehicle.
  ///
  /// In en, this message translates to:
  /// **'Complain About this Vehicle'**
  String get complainVehicle;

  /// No description provided for @supportChatVehicle.
  ///
  /// In en, this message translates to:
  /// **'Open support chat with this vehicle selected'**
  String get supportChatVehicle;

  /// No description provided for @assign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @complain.
  ///
  /// In en, this message translates to:
  /// **'Complain'**
  String get complain;

  /// No description provided for @seeDriver.
  ///
  /// In en, this message translates to:
  /// **'See driver'**
  String get seeDriver;

  /// No description provided for @noAlertAssigned.
  ///
  /// In en, this message translates to:
  /// **'No Alert assigned'**
  String get noAlertAssigned;

  /// No description provided for @noUpcomingMaintenance.
  ///
  /// In en, this message translates to:
  /// **'No upcoming maintenance'**
  String get noUpcomingMaintenance;

  /// No description provided for @viewAllExpenses.
  ///
  /// In en, this message translates to:
  /// **'View all expenses'**
  String get viewAllExpenses;

  /// No description provided for @noActiveReminders.
  ///
  /// In en, this message translates to:
  /// **'No active reminders'**
  String get noActiveReminders;

  /// No description provided for @talkToSupportVehicle.
  ///
  /// In en, this message translates to:
  /// **'Talk to support about {vehicle}'**
  String talkToSupportVehicle(Object vehicle);

  /// No description provided for @singleVehicleNoAlertsFound.
  ///
  /// In en, this message translates to:
  /// **'No Alerts Found'**
  String get singleVehicleNoAlertsFound;

  /// No description provided for @singleVehicleNoAlertsCategory.
  ///
  /// In en, this message translates to:
  /// **'No alerts for selected category'**
  String get singleVehicleNoAlertsCategory;

  /// No description provided for @singleVehicleNoAlertsSearch.
  ///
  /// In en, this message translates to:
  /// **'No alerts match your search'**
  String get singleVehicleNoAlertsSearch;

  /// No description provided for @singleVehicleNoAlertsVehicle.
  ///
  /// In en, this message translates to:
  /// **'No alerts available for this vehicle'**
  String get singleVehicleNoAlertsVehicle;

  /// No description provided for @showAllAlerts.
  ///
  /// In en, this message translates to:
  /// **'Show All Alerts'**
  String get showAllAlerts;

  /// No description provided for @oopsSomethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get oopsSomethingWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @deleteAlertsConfirmCount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} alert(s)?'**
  String deleteAlertsConfirmCount(Object count);

  /// No description provided for @failedDeleteAlerts.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete alerts'**
  String get failedDeleteAlerts;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @alertsCategory.
  ///
  /// In en, this message translates to:
  /// **'Alerts Category'**
  String get alertsCategory;

  /// No description provided for @overSpeed.
  ///
  /// In en, this message translates to:
  /// **'Over Speed'**
  String get overSpeed;

  /// No description provided for @idleDuration.
  ///
  /// In en, this message translates to:
  /// **'Idle Duration'**
  String get idleDuration;

  /// No description provided for @ignitionDuration.
  ///
  /// In en, this message translates to:
  /// **'Ignition duration'**
  String get ignitionDuration;

  /// No description provided for @moveStart.
  ///
  /// In en, this message translates to:
  /// **'Move Start'**
  String get moveStart;

  /// No description provided for @offlineDuration.
  ///
  /// In en, this message translates to:
  /// **'Offline duration'**
  String get offlineDuration;

  /// No description provided for @overParking.
  ///
  /// In en, this message translates to:
  /// **'Over Parking'**
  String get overParking;

  /// No description provided for @times.
  ///
  /// In en, this message translates to:
  /// **'Times'**
  String get times;

  /// No description provided for @loadingAlerts.
  ///
  /// In en, this message translates to:
  /// **'Loading alerts...'**
  String get loadingAlerts;

  /// No description provided for @vehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Info'**
  String get vehicleInfo;

  /// No description provided for @averagePerLiter.
  ///
  /// In en, this message translates to:
  /// **'Average Per Liter'**
  String get averagePerLiter;

  /// No description provided for @engineType.
  ///
  /// In en, this message translates to:
  /// **'Engine Type'**
  String get engineType;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// No description provided for @updateVehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Update Vehicle Info'**
  String get updateVehicleInfo;

  /// No description provided for @exampleAveragePerLiter.
  ///
  /// In en, this message translates to:
  /// **'e.g. 11.00'**
  String get exampleAveragePerLiter;

  /// No description provided for @selectEngineType.
  ///
  /// In en, this message translates to:
  /// **'Select engine type'**
  String get selectEngineType;

  /// No description provided for @selectVehicleType.
  ///
  /// In en, this message translates to:
  /// **'Select vehicle type'**
  String get selectVehicleType;

  /// No description provided for @pleaseEnterValidAveragePerLiter.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid Average Per Liter'**
  String get pleaseEnterValidAveragePerLiter;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @serviceAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Service added successfully'**
  String get serviceAddedSuccessfully;

  /// No description provided for @expenseAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Expense added successfully'**
  String get expenseAddedSuccessfully;

  /// No description provided for @singleActiveReminder.
  ///
  /// In en, this message translates to:
  /// **'1 active reminder'**
  String get singleActiveReminder;

  /// No description provided for @multipleActiveReminders.
  ///
  /// In en, this message translates to:
  /// **'{count} active reminders'**
  String multipleActiveReminders(Object count);

  /// No description provided for @noPastReminders.
  ///
  /// In en, this message translates to:
  /// **'No past reminders'**
  String get noPastReminders;

  /// No description provided for @singlePastReminder.
  ///
  /// In en, this message translates to:
  /// **'1 past reminder'**
  String get singlePastReminder;

  /// No description provided for @multiplePastReminders.
  ///
  /// In en, this message translates to:
  /// **'{count} past reminders'**
  String multiplePastReminders(Object count);

  /// No description provided for @oldReminders.
  ///
  /// In en, this message translates to:
  /// **'Old Reminders'**
  String get oldReminders;

  /// No description provided for @noOldReminders.
  ///
  /// In en, this message translates to:
  /// **'No old reminders'**
  String get noOldReminders;

  /// No description provided for @totalCurrencyRs.
  ///
  /// In en, this message translates to:
  /// **'Total: Rs {amount}'**
  String totalCurrencyRs(Object amount);

  /// No description provided for @fromValue.
  ///
  /// In en, this message translates to:
  /// **'From: {value}'**
  String fromValue(Object value);

  /// No description provided for @toValue.
  ///
  /// In en, this message translates to:
  /// **'To: {value}'**
  String toValue(Object value);

  /// No description provided for @clearDateFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear date filter'**
  String get clearDateFilter;

  /// No description provided for @noExpensesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded'**
  String get noExpensesRecorded;

  /// No description provided for @noServicesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No services recorded'**
  String get noServicesRecorded;

  /// No description provided for @deleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get deleteExpense;

  /// No description provided for @deleteExpenseConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense?'**
  String get deleteExpenseConfirmation;

  /// No description provided for @deleteService.
  ///
  /// In en, this message translates to:
  /// **'Delete Service'**
  String get deleteService;

  /// No description provided for @deleteServiceConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this service?'**
  String get deleteServiceConfirmation;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No name'**
  String get noName;

  /// No description provided for @nameValue.
  ///
  /// In en, this message translates to:
  /// **'Name: {value}'**
  String nameValue(Object value);

  /// No description provided for @supplierValue.
  ///
  /// In en, this message translates to:
  /// **'Supplier: {value}'**
  String supplierValue(Object value);

  /// No description provided for @amountCurrencyRs.
  ///
  /// In en, this message translates to:
  /// **'Amount: Rs {amount}'**
  String amountCurrencyRs(Object amount);

  /// No description provided for @expenseQtyUnitRow.
  ///
  /// In en, this message translates to:
  /// **'{date}  •  Qty: {qty}  •  Unit: Rs {unit}'**
  String expenseQtyUnitRow(Object date, Object qty, Object unit);

  /// No description provided for @serviceNumber.
  ///
  /// In en, this message translates to:
  /// **'Service #{id}'**
  String serviceNumber(Object id);

  /// No description provided for @typeValue.
  ///
  /// In en, this message translates to:
  /// **'Type: {value}'**
  String typeValue(Object value);

  /// No description provided for @intervalLastRow.
  ///
  /// In en, this message translates to:
  /// **'Interval: {interval}  •  Last: {last}'**
  String intervalLastRow(Object interval, Object last);

  /// No description provided for @expiresRemindRow.
  ///
  /// In en, this message translates to:
  /// **'Expires: {expires}  •  Remind: {remind}'**
  String expiresRemindRow(Object expires, Object remind);

  /// No description provided for @currentOdometerEngineHoursRow.
  ///
  /// In en, this message translates to:
  /// **'Current Odometer: {odometer}  •  Engine Hours: {hours}'**
  String currentOdometerEngineHoursRow(Object odometer, Object hours);

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @last3Days.
  ///
  /// In en, this message translates to:
  /// **'Last 3 Days'**
  String get last3Days;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @fromDateCannotBeLaterThanToDate.
  ///
  /// In en, this message translates to:
  /// **'From date cannot be later than To date'**
  String get fromDateCannotBeLaterThanToDate;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @loadingAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Loading analytics...'**
  String get loadingAnalytics;

  /// No description provided for @vehicleAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Analytics'**
  String get vehicleAnalytics;

  /// No description provided for @dateTimeRange.
  ///
  /// In en, this message translates to:
  /// **'Date & Time Range'**
  String get dateTimeRange;

  /// No description provided for @startDateTime.
  ///
  /// In en, this message translates to:
  /// **'Start Date & Time'**
  String get startDateTime;

  /// No description provided for @endDateTime.
  ///
  /// In en, this message translates to:
  /// **'End Date & Time'**
  String get endDateTime;

  /// No description provided for @chartsGroupedByDate.
  ///
  /// In en, this message translates to:
  /// **'Charts grouped by date'**
  String get chartsGroupedByDate;

  /// No description provided for @chartsGroupedByHour.
  ///
  /// In en, this message translates to:
  /// **'Charts grouped by hour'**
  String get chartsGroupedByHour;

  /// No description provided for @maximumSpeed.
  ///
  /// In en, this message translates to:
  /// **'Maximum Speed'**
  String get maximumSpeed;

  /// No description provided for @driveTime.
  ///
  /// In en, this message translates to:
  /// **'Drive Time'**
  String get driveTime;

  /// No description provided for @stopTime.
  ///
  /// In en, this message translates to:
  /// **'Stop Time'**
  String get stopTime;

  /// No description provided for @fuelUsed.
  ///
  /// In en, this message translates to:
  /// **'Fuel Used'**
  String get fuelUsed;

  /// No description provided for @amountSpent.
  ///
  /// In en, this message translates to:
  /// **'Amount Spent'**
  String get amountSpent;

  /// No description provided for @maxSpeedPerDay.
  ///
  /// In en, this message translates to:
  /// **'Max Speed per Day (km/h)'**
  String get maxSpeedPerDay;

  /// No description provided for @speedKmh.
  ///
  /// In en, this message translates to:
  /// **'Speed (km/h)'**
  String get speedKmh;

  /// No description provided for @distancePerDay.
  ///
  /// In en, this message translates to:
  /// **'Distance per Day (km)'**
  String get distancePerDay;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'Distance (km)'**
  String get distanceKm;

  /// No description provided for @fuelUsedLiters.
  ///
  /// In en, this message translates to:
  /// **'Fuel Used (Liters)'**
  String get fuelUsedLiters;

  /// No description provided for @stopDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Stop Duration (Minutes)'**
  String get stopDurationMinutes;

  /// No description provided for @engineHoursPerDay.
  ///
  /// In en, this message translates to:
  /// **'Engine Hours per Day'**
  String get engineHoursPerDay;

  /// No description provided for @engineHoursCumulative.
  ///
  /// In en, this message translates to:
  /// **'Engine Hours (Cumulative)'**
  String get engineHoursCumulative;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @liveTracking.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get liveTracking;

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated at : {value}'**
  String updatedAt(Object value);

  /// No description provided for @traffic.
  ///
  /// In en, this message translates to:
  /// **'Traffic'**
  String get traffic;

  /// No description provided for @vehicleLocationShare.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Location: {url}'**
  String vehicleLocationShare(Object url);

  /// No description provided for @moving.
  ///
  /// In en, this message translates to:
  /// **'Moving'**
  String get moving;

  /// No description provided for @callToDriver.
  ///
  /// In en, this message translates to:
  /// **'Call To Driver'**
  String get callToDriver;

  /// No description provided for @immobilizer.
  ///
  /// In en, this message translates to:
  /// **'IMMOBILIZER'**
  String get immobilizer;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get last30Days;

  /// No description provided for @pleaseSelectDateRangeFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select date range first'**
  String get pleaseSelectDateRangeFirst;

  /// No description provided for @fromTime.
  ///
  /// In en, this message translates to:
  /// **'From Time'**
  String get fromTime;

  /// No description provided for @toTime.
  ///
  /// In en, this message translates to:
  /// **'To Time'**
  String get toTime;

  /// No description provided for @applyRange.
  ///
  /// In en, this message translates to:
  /// **'Apply Range'**
  String get applyRange;

  /// No description provided for @fleetInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'Fleet Insight AI'**
  String get fleetInsightTitle;

  /// No description provided for @fleetStatusStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get fleetStatusStable;

  /// No description provided for @fleetStatusNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get fleetStatusNeedsAttention;

  /// No description provided for @fleetStatusCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get fleetStatusCritical;

  /// No description provided for @fleetInsightIntroPositive1.
  ///
  /// In en, this message translates to:
  /// **'Fleet is moving steadily today.'**
  String get fleetInsightIntroPositive1;

  /// No description provided for @fleetInsightIntroPositive2.
  ///
  /// In en, this message translates to:
  /// **'Operations look stable right now.'**
  String get fleetInsightIntroPositive2;

  /// No description provided for @fleetInsightIntroPositive3.
  ///
  /// In en, this message translates to:
  /// **'Current trend is healthy across your fleet.'**
  String get fleetInsightIntroPositive3;

  /// No description provided for @fleetInsightIntroWarning1.
  ///
  /// In en, this message translates to:
  /// **'Fleet needs some attention in one area.'**
  String get fleetInsightIntroWarning1;

  /// No description provided for @fleetInsightIntroWarning2.
  ///
  /// In en, this message translates to:
  /// **'A few signals are drifting from target.'**
  String get fleetInsightIntroWarning2;

  /// No description provided for @fleetInsightIntroWarning3.
  ///
  /// In en, this message translates to:
  /// **'Current snapshot shows moderate operational pressure.'**
  String get fleetInsightIntroWarning3;

  /// No description provided for @fleetInsightIntroCritical1.
  ///
  /// In en, this message translates to:
  /// **'Immediate action is recommended for fleet health.'**
  String get fleetInsightIntroCritical1;

  /// No description provided for @fleetInsightIntroCritical2.
  ///
  /// In en, this message translates to:
  /// **'Current indicators suggest high operational risk.'**
  String get fleetInsightIntroCritical2;

  /// No description provided for @fleetInsightIntroCritical3.
  ///
  /// In en, this message translates to:
  /// **'Priority follow-up is needed on critical metrics.'**
  String get fleetInsightIntroCritical3;

  /// No description provided for @fleetInsightAvailabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Availability needs attention.'**
  String get fleetInsightAvailabilityTitle;

  /// No description provided for @fleetInsightAvailabilityDetail.
  ///
  /// In en, this message translates to:
  /// **'{offlineNow}/{totalVehicles} vehicles are offline right now, including {offline24h} offline for more than 24 hours.'**
  String fleetInsightAvailabilityDetail(
      Object offlineNow, Object totalVehicles, Object offline24h);

  /// No description provided for @fleetInsightSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Overspeed behavior is driving risk.'**
  String get fleetInsightSafetyTitle;

  /// No description provided for @fleetInsightSafetyVehicleDetail.
  ///
  /// In en, this message translates to:
  /// **'{vehicleName} recorded {count} overspeed alerts, the highest in fleet.'**
  String fleetInsightSafetyVehicleDetail(Object vehicleName, Object count);

  /// No description provided for @fleetInsightSafetyOverallDetail.
  ///
  /// In en, this message translates to:
  /// **'{overspeed} overspeed alerts were observed from {totalAlerts} total alerts.'**
  String fleetInsightSafetyOverallDetail(Object overspeed, Object totalAlerts);

  /// No description provided for @fleetInsightMaintenanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Maintenance backlog is affecting readiness.'**
  String get fleetInsightMaintenanceTitle;

  /// No description provided for @fleetInsightMaintenanceDetail.
  ///
  /// In en, this message translates to:
  /// **'{dueCount} maintenance item(s) are currently due or expired.'**
  String fleetInsightMaintenanceDetail(Object dueCount);

  /// No description provided for @fleetInsightTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Task queue needs balancing.'**
  String get fleetInsightTasksTitle;

  /// No description provided for @fleetInsightTasksDetail.
  ///
  /// In en, this message translates to:
  /// **'{taskBacklog} tasks are open, with {agingCount} older than 2 days.'**
  String fleetInsightTasksDetail(Object taskBacklog, Object agingCount);

  /// No description provided for @fleetInsightPerformanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Performance score is the key optimization area.'**
  String get fleetInsightPerformanceTitle;

  /// No description provided for @fleetInsightPerformanceDetail.
  ///
  /// In en, this message translates to:
  /// **'Average vehicle performance is {score}/100 for the selected period.'**
  String fleetInsightPerformanceDetail(Object score);

  /// No description provided for @fleetInsightPerformanceLoading.
  ///
  /// In en, this message translates to:
  /// **'Performance analytics are still loading from recent data.'**
  String get fleetInsightPerformanceLoading;

  /// No description provided for @fleetInsightExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense trend is an active watch area.'**
  String get fleetInsightExpenseTitle;

  /// No description provided for @fleetInsightExpenseDetail.
  ///
  /// In en, this message translates to:
  /// **'This month expense is Rs {amount} with a {change}% month-over-month change.'**
  String fleetInsightExpenseDetail(Object amount, Object change);

  /// No description provided for @fleetInsightDistanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Distance trend looks active today.'**
  String get fleetInsightDistanceTitle;

  /// No description provided for @fleetInsightDistanceLeaderDetail.
  ///
  /// In en, this message translates to:
  /// **'{vehicleName} covered {distanceKm} km, highest in fleet today.'**
  String fleetInsightDistanceLeaderDetail(
      Object vehicleName, Object distanceKm);

  /// No description provided for @fleetInsightDistanceTotalDetail.
  ///
  /// In en, this message translates to:
  /// **'Fleet covered {distanceKm} km in total today.'**
  String fleetInsightDistanceTotalDetail(Object distanceKm);

  /// No description provided for @fleetInsightDistanceSpeedDetail.
  ///
  /// In en, this message translates to:
  /// **'{vehicleName} reached {topSpeed} km/h top speed, while fleet total distance is {distanceKm} km.'**
  String fleetInsightDistanceSpeedDetail(
      Object vehicleName, Object topSpeed, Object distanceKm);

  /// No description provided for @fleetInsightDistanceAvgDetail.
  ///
  /// In en, this message translates to:
  /// **'Fleet movement summary: {totalKm} km total and {avgKm} km average.'**
  String fleetInsightDistanceAvgDetail(Object totalKm, Object avgKm);

  /// No description provided for @fleetInsightMovementLoading.
  ///
  /// In en, this message translates to:
  /// **'Movement analytics are loading.'**
  String get fleetInsightMovementLoading;

  /// No description provided for @fleetInsightMovementSummary.
  ///
  /// In en, this message translates to:
  /// **'Fleet moved {totalKm} km today (avg {avgKm} km/vehicle).'**
  String fleetInsightMovementSummary(Object totalKm, Object avgKm);

  /// No description provided for @fleetInsightHealthChip.
  ///
  /// In en, this message translates to:
  /// **'Health {score}/100'**
  String fleetInsightHealthChip(Object score);

  /// No description provided for @fleetInsightOnlineChip.
  ///
  /// In en, this message translates to:
  /// **'Online {count}'**
  String fleetInsightOnlineChip(Object count);

  /// No description provided for @fleetInsightOfflineChip.
  ///
  /// In en, this message translates to:
  /// **'Offline {count}'**
  String fleetInsightOfflineChip(Object count);

  /// No description provided for @fleetInsightOverspeedChip.
  ///
  /// In en, this message translates to:
  /// **'Overspeed {count}'**
  String fleetInsightOverspeedChip(Object count);

  /// No description provided for @fleetInsightMaintenanceChip.
  ///
  /// In en, this message translates to:
  /// **'Due maintenance {count}'**
  String fleetInsightMaintenanceChip(Object count);

  /// No description provided for @fleetInsightOpenTasksChip.
  ///
  /// In en, this message translates to:
  /// **'Open tasks {count}'**
  String fleetInsightOpenTasksChip(Object count);

  /// No description provided for @fleetInsightPerformanceChip.
  ///
  /// In en, this message translates to:
  /// **'Perf {score}/100'**
  String fleetInsightPerformanceChip(Object score);

  /// No description provided for @fleetInsightExpenseChip.
  ///
  /// In en, this message translates to:
  /// **'Expense MoM {change}%'**
  String fleetInsightExpenseChip(Object change);
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
      <String>['ar', 'en', 'ur'].contains(locale.languageCode);

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
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
