import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/providers/dashboard_provider.dart';
import 'package:trackerapp/providers/motion_bottom_bar_provider.dart';
import 'package:trackerapp/providers/single_vehicle_analytics_provider.dart';
import 'package:trackerapp/providers/theme_provider.dart';
import 'package:trackerapp/providers/vehicle_list_provider.dart';
import 'package:trackerapp/app/routes/routes.dart';
import 'package:trackerapp/app/routes/routes_name.dart';
// @pragma('vm:entry-point')
// Future<void> backGroundHandler(RemoteMessage event) async {
//   await Firebase.initializeApp();
//   if (event.notification != null) {
//     final sp = await SharedPreferences.getInstance();
//     if (sp.getBool('playAlertSounds') ?? false) {
//       PlaySounds.playAnnoucment(event);
//     }
//     LocalNotificationServices.showNotifiationForground(event);
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  // LocalNotificationServices.initilize();
  // FirebaseMessaging.onBackgroundMessage(backGroundHandler);

  // Load theme before runApp
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
        ChangeNotifierProvider(create:(_)=> MotionBottomBarProvider()),
        ChangeNotifierProvider(create:(_)=> DashboardProvider()),
        ChangeNotifierProvider(create:(_)=> VehicleListProvider()),
        ChangeNotifierProvider(create:(_)=> SingleVehicleAnalyticsProvider()),
      ],
      child: ResponsiveSizer(builder: (context, orientation, screenType) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,

              // Light Theme → White UI
              theme: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: AppColors.scaffoldBg,
                primaryColor: AppColors.black,
                cardColor: Colors.white,
                colorScheme: ColorScheme.light(
                  surface: Colors.white,
                  onSurface: AppColors.textBlack,
                  primary: AppColors.black,
                  onPrimary: Colors.white,
                ),
                appBarTheme: AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.black,
                  iconTheme: IconThemeData(color: AppColors.black),
                  titleTextStyle: TextStyle(
                    color: AppColors.black,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                textTheme: const TextTheme(
                  bodyMedium: TextStyle(color: Colors.black),
                ),
              ),

              // Dark Theme → Black UI
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: AppColors.black,
                primaryColor: AppColors.white,
                cardColor: Colors.grey[900]!,
                colorScheme: ColorScheme.dark(
                  surface: Colors.grey[900]!,
                  onSurface: Colors.white,
                  primary: AppColors.white,
                  onPrimary: Colors.black,
                ),
                appBarTheme: AppBarTheme(
                  backgroundColor: AppColors.black,
                  foregroundColor: AppColors.white,
                  iconTheme: IconThemeData(color: AppColors.white),
                  titleTextStyle: TextStyle(
                    color: AppColors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                textTheme: const TextTheme(
                  bodyMedium: TextStyle(color: Colors.white),
                ),
              ),

              themeMode: themeProvider.themeMode,

              initialRoute: RoutesName.splashSceen,
              onGenerateRoute: Routes.generateRoute,

              // Example Home Scaffold (Remove when splash screen works)
              home: Scaffold(
                appBar: AppBar(
                  title: const Text("Black & White Theme"),
                  actions: [
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return IconButton(
                          icon: Icon(
                            themeProvider.themeMode == ThemeMode.light
                                ? Icons.dark_mode
                                : Icons.light_mode,
                          ),
                          onPressed: () => themeProvider.toggleTheme(),
                        );
                      },
                    )
                  ],
                ),
                body: Center(
                  child: Text(
                    "Hello Tracker App!",
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}