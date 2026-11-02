import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/l10n/app_localizations.dart';
import 'package:trackerapp/providers/alerts_provider.dart';
import 'package:trackerapp/providers/contact_us_provider.dart';
import 'package:trackerapp/providers/dashboard_layout_provider.dart';
import 'package:trackerapp/providers/device_command_provider.dart';
import 'package:trackerapp/providers/driver_provider.dart';
import 'package:trackerapp/providers/get_device_group_provider.dart';
import 'package:trackerapp/providers/get_device_reports_provider.dart';
import 'package:trackerapp/providers/get_devices_status_provider.dart';
import 'package:trackerapp/providers/get_geofence_provider.dart';
import 'package:trackerapp/providers/language_provider.dart';
import 'package:trackerapp/providers/maintenance_provider.dart';
import 'package:trackerapp/providers/performance_provider.dart';
import 'package:trackerapp/providers/reminder_provider.dart';
import 'package:trackerapp/providers/settings_provider.dart';
import 'package:trackerapp/providers/task_provider.dart';
import 'package:trackerapp/providers/update_device_data_provider.dart';
import 'package:trackerapp/providers/vehicle_expense_provider.dart';
import 'package:trackerapp/providers/vehicle_tracking_provider.dart';
import 'package:trackerapp/utils/alert_tts_service.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/utils/local_notification_service.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';
import 'package:trackerapp/view/splashscreen.dart';

import 'data/repositories/fcm_token_repository.dart';
import 'data/repositories/vehicle_repository.dart';
import 'providers/alert_settings_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/get_device_history_provider.dart';
import 'providers/motion_bottom_bar_provider.dart';
import 'providers/single_vehicle_analytics_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/vehicle_list_provider.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<FirebaseApp?> _ensureFirebaseInitialized() async {
  if (Firebase.apps.isNotEmpty) {
    return Firebase.app();
  }
  try {
    if (Platform.isIOS) {
      return await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyA0p80FOcP-h7i9ZecRnOHNtuXa_Oe37lQ',
          appId: '1:564804113447:ios:3bebe36214982df2292a02',
          messagingSenderId: '564804113447',
          projectId: 'worldautotel-8b93c',
          storageBucket: 'worldautotel-8b93c.firebasestorage.app',
          iosBundleId: 'com.autotelfleet.trackerapp',
        ),
      );
    } else {
      return await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("Firebase.initializeApp() warning: $e");
    return null;
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await MySharedPreferences.init();
  await MySharedPreferences.reload();
  if (!MySharedPreferences.getBool(isLoggedInKey)) {
    return;
  }
  await LocalNotificationService.instance.init(requestPermissions: false);
  try {
    await _ensureFirebaseInitialized();
  } catch (_) {}
  final hasVisibleNotification =
      (message.notification?.title ?? '')
          .trim()
          .isNotEmpty ||
          (message.notification?.body ?? '')
              .trim()
              .isNotEmpty;
  final hasUsableData = message.data.entries.any(
        (entry) =>
    entry.key
        .trim()
        .isNotEmpty && entry.value
        .toString()
        .trim()
        .isNotEmpty,
  );
  if (!hasVisibleNotification && !hasUsableData) {
    return;
  }
  // If message.notification != null, Android OS / FCM SDK displays native notification automatically.
  // Only call showRemoteMessageNotification if message.notification == null (data-only payload) to prevent duplicate background notifications.
  if (Platform.isAndroid && message.notification == null) {
    await LocalNotificationService.instance.showRemoteMessageNotification(
      message,
    );
  }
  if (Platform.isAndroid) {
    await AlertTtsService.instance.speakFromRemoteMessage(
      message,
      isBackground: true,
      delay: const Duration(milliseconds: 1200),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MySharedPreferences.init();
  LocalNotificationService.instance.setNavigatorKey(rootNavigatorKey);
  await LocalNotificationService.instance.init();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Firebase Initialization (Safe fallback)
  try {
    await _ensureFirebaseInitialized();
    final fcmTokenRepository = FcmTokenRepository();
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
    );
    if (Platform.isIOS) {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: false, // Let LocalNotificationService handle foreground popup on iOS to avoid double banner
        badge: true,
        sound: true,
      );
    }

    try {
      await fcmTokenRepository.syncCurrentDeviceToken(force: true);
    } catch (e) {
      debugPrint("FCM token sync failed at startup: $e");
    }

    messaging.onTokenRefresh.listen((token) async {
      debugPrint("FCM token refreshed: $token");
      await fcmTokenRepository.rememberLatestToken(token);
      try {
        await fcmTokenRepository.syncToken(token);
      } catch (e) {
        debugPrint("FCM token refresh sync failed: $e");
      }
    });

    await AlertTtsService.instance.init();
    FirebaseMessaging.onMessage.listen((message) async {
      await MySharedPreferences.reload();
      if (!MySharedPreferences.getBool(isLoggedInKey)) {
        return;
      }
      await LocalNotificationService.instance.showRemoteMessageNotification(
        message,
      );
      if (Platform.isAndroid) {
        await AlertTtsService.instance.speakFromRemoteMessage(
          message,
          isBackground: false,
          delay: const Duration(milliseconds: 700),
        );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      if (Platform.isAndroid) {
        await AlertTtsService.instance.speakFromRemoteMessage(
          message,
          isBackground: false,
          delay: Duration.zero,
        );
      }
      LocalNotificationService.instance.registerRemoteMessageTap(message);
      await LocalNotificationService.instance.processPendingNotificationTap();
    });
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      if (Platform.isAndroid) {
        await AlertTtsService.instance.speakFromRemoteMessage(
          initialMessage,
          isBackground: false,
          delay: Duration.zero,
        );
      }
      LocalNotificationService.instance.registerRemoteMessageTap(initialMessage);
    }
  } catch (e) {
    debugPrint("Firebase setup bypassed/failed: $e");
  }

  // Load Theme
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();
  final reminderProvider = ReminderProvider();
  await reminderProvider.initialize();
  final languageProvider = LanguageProvider();
  await languageProvider.loadSavedLocale();

  runApp(
    MyApp(
      themeProvider: themeProvider,
      reminderProvider: reminderProvider,
      languageProvider: languageProvider,
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final ReminderProvider? reminderProvider;
  final LanguageProvider languageProvider;

  const MyApp({
    super.key,
    required this.themeProvider,
    this.reminderProvider,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: languageProvider),
        ChangeNotifierProvider(create: (_) => MotionBottomBarProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => DashboardLayoutProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(
            create: (_) => GetDevicesListProvider(VehicleRepository())),
        ChangeNotifierProvider(create: (_) => GetDeviceGroupProvider()),
        ChangeNotifierProvider(create: (_) => DeviceHistoryProvider()),
        ChangeNotifierProvider(create: (_) => SingleVehicleAnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => AlertSettingsProvider()),
        ChangeNotifierProvider(create: (_) => VehicleTrackingProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => MaintenanceProvider()),
        ChangeNotifierProvider(create: (_) => VehicleExpenseProvider()),
        ChangeNotifierProvider(create: (_) => ContactProvider()),
        ChangeNotifierProvider(create: (_) => AlertsProvider()),
        ChangeNotifierProvider(create: (_) => ReportTypeProvider()),
        ChangeNotifierProvider(create: (_) => VehicleMapProvider()),
        ChangeNotifierProvider(create: (_) => GeofenceProvider()),
        ChangeNotifierProvider(create: (_) => DriverProvider()),
        ChangeNotifierProvider(create: (_) => PerformanceProvider()),
        ChangeNotifierProvider(create: (_) => UpdateDeviceDataProvider()),
        ChangeNotifierProvider(create: (_) => GetDeviceCommandsProvider()),
        reminderProvider != null
            ? ChangeNotifierProvider.value(value: reminderProvider!)
            : ChangeNotifierProvider(
          create: (_) {
            final provider = ReminderProvider();
            provider.initialize();
            return provider;
          },
        ),
      ],
      child: ResponsiveSizer(
        builder: (context, orientation, screenType) {
          return Consumer2<ThemeProvider, LanguageProvider>(
            builder: (context, themeProvider, languageProvider, _) {
              return MaterialApp(
                navigatorKey: rootNavigatorKey,
                scaffoldMessengerKey: rootScaffoldMessengerKey,
                debugShowCheckedModeBanner: false,
                onGenerateTitle: (context) => context.l10n.appTitle,
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                supportedLocales: LanguageProvider.supportedLocales,
                locale: languageProvider.locale,
                theme: _buildLightTheme(),
                darkTheme: _buildDarkTheme(),
                themeMode: themeProvider.themeMode,
                home: SplashScreen(),
                builder: (context, child) =>
                    _ReminderTapListener(
                        child: child ?? const SizedBox.shrink()),
              );
            },
          );
        },
      ),
    );
  }

  // Light Theme
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.scaffoldBg,
      primaryColor: AppColors.black,
      cardColor: AppColors.white,
      colorScheme: ColorScheme.light(
        primary: AppColors.black,
        onPrimary: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.textBlack,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.black),
        titleTextStyle: TextStyle(
          color: AppColors.black,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: AppColors.textBlack),
      ),
    );
  }

  // Dark Theme
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.black,
      primaryColor: AppColors.white,
      cardColor: AppColors.darkCard,
      colorScheme: ColorScheme.dark(
        primary: AppColors.white,
        onPrimary: AppColors.black,
        surface: AppColors.darkCard,
        onSurface: AppColors.darkOnSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: AppColors.white),
      ),
    );
  }
}

class _ReminderTapListener extends StatefulWidget {
  final Widget child;

  const _ReminderTapListener({required this.child});

  @override
  State<_ReminderTapListener> createState() => _ReminderTapListenerState();
}

class _ReminderTapListenerState extends State<_ReminderTapListener>
    with WidgetsBindingObserver {
  final FcmTokenRepository _fcmTokenRepository = FcmTokenRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncFcmOnLifecycleEntry();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(
          LocalNotificationService.instance.processPendingNotificationTap(),
        );
      });
      _syncFcmOnLifecycleEntry();
    }
  }

  Future<void> _syncFcmOnLifecycleEntry() async {
    if (!MySharedPreferences.getBool(isLoggedInKey)) return;
    try {
      await _fcmTokenRepository.syncCurrentDeviceToken(force: true);
    } catch (e) {
      debugPrint("FCM token sync failed on lifecycle entry: $e");
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
