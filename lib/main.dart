// lib/main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/providers/contact_us_provider.dart';
import 'package:trackerapp/providers/maintenance_provider.dart';
import 'package:trackerapp/providers/settings_provider.dart';
import 'package:trackerapp/providers/vehicle_expense_provider.dart';
import 'package:trackerapp/providers/vehicle_tracking_provider.dart';
import 'package:trackerapp/utils/shared_preference.dart';
import 'package:trackerapp/view/splashscreen.dart';
import 'providers/alert_settings_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/motion_bottom_bar_provider.dart';
import 'providers/single_vehicle_analytics_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/vehicle_list_provider.dart';

/// GLOBAL snackBar key
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MySharedPreferences.init();

  // Firebase Initialization
  final firebaseOptions = FirebaseOptions(
    apiKey: Platform.isAndroid
        ? 'AIzaSyBd7u3Jl_979xmMn3-9NtTcPKqFce5smkY'
        : 'AIzaSyByXVejFx0oYq-U5I37HaBqoeq9dcaV-bk',
    appId: Platform.isAndroid
        ? '1:339329536042:android:c0331a53395f7ae5abb353'
        : '1:339329536042:ios:2931391744e01db0abb353',
    messagingSenderId: '339329536042',
    projectId: 'autotel-2f5a1',
  );

  await Firebase.initializeApp(options: firebaseOptions);
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: true,
  );

  // Load Theme
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  runApp(MyApp(themeProvider: themeProvider));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;

  const MyApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => MotionBottomBarProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => VehicleListProvider()),
        ChangeNotifierProvider(create: (_) => SingleVehicleAnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => AlertSettingsProvider()),
        ChangeNotifierProvider(create: (_) => VehicleTrackingProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => MaintenanceProvider()),
        ChangeNotifierProvider(create: (_) => VehicleExpenseProvider()),
        ChangeNotifierProvider(create: (_) => ContactProvider()),
      ],
      child: ResponsiveSizer(
        builder: (context, orientation, screenType) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return MaterialApp(
                scaffoldMessengerKey: rootScaffoldMessengerKey,
                debugShowCheckedModeBanner: false,
                theme: _buildLightTheme(),
                darkTheme: _buildDarkTheme(),
                themeMode: themeProvider.themeMode,
                home: SplashScreen(),
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
        iconTheme:  IconThemeData(color: AppColors.white),
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme:  TextTheme(
        bodyMedium: TextStyle(color: AppColors.white),
      ),
    );
  }
}
