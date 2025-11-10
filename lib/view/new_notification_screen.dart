import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/utils/top_curve_bezier.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/widgets/search_textfield.dart';

class NewNotificationScreen extends StatelessWidget {
  NewNotificationScreen({super.key});

  final List<Map<String, dynamic>> dummyAlerts = [
    {
      "id": 1,
      "deviceName": "Car A",
      "message": "Overspeed detected at 120km/h",
      "time": DateTime.now().subtract(const Duration(minutes: 10)),
    },
    {
      "id": 2,
      "deviceName": "Car B",
      "message": "Entered Geofence Area",
      "time": DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      "id": 3,
      "deviceName": "Car C",
      "message": "Idle for 25 minutes",
      "time": DateTime.now().subtract(const Duration(hours: 2)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor:Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient:isDark?LinearGradient(colors: [theme.cardColor,theme.cardColor]): AppColors.mainGradient
        ),
        child: SizedBox(
          height: 100.h,
          width: 100.w,
          child: Column(
            children: [
              verticalSpace(height: 6.h),

              /// Search bar area (fixed top)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: SearchAndFilterBar(
                  alertTypes: ["All", "Overspeed", "Idle", "Offline"],
                  vehicles: ["Car A", "Car B", "Truck 1"],
                  onVehicleChanged: (val) => debugPrint("Vehicle: $val"),
                  onAlertTypeChanged: (val) => debugPrint("Alert Type: $val"),
                  onSearchPressed: () => debugPrint("Search clicked!"),
                ),
              ),

              verticalSpace(height: 2.h),

              /// Curved background and list
              Expanded(
                child: ClipPath(
                  clipper: TopCurveClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? LinearGradient(
                        colors: [
                          theme.scaffoldBackgroundColor,
                          theme.scaffoldBackgroundColor,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                          : LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.grey.shade100,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        verticalSpace(height: 3.h),

                        /// Header Title
                        Text(
                          "Notifications",
                          style: AppStyles.boldTextStyle(context).copyWith(
                            color: onSurface,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        verticalSpace(height: 2.h),

                        /// Notification List
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            physics: const BouncingScrollPhysics(),
                            itemCount: dummyAlerts.length,
                            itemBuilder: (context, index) {
                              final alert = dummyAlerts[index];
                              return AnimatedContainer(
                                duration: Duration(seconds: 5),

                                margin: EdgeInsets.only(bottom: 1.5.h),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.black.withOpacity(0.4)
                                          : Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: isDark
                                        ? Colors.redAccent.withOpacity(0.15)
                                        : Colors.redAccent.withOpacity(0.1),
                                    child: const Icon(
                                      Icons.notifications_active_outlined,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                  title: Text(
                                    alert["deviceName"],
                                    style: AppStyles.regularTextStyle(context)
                                        .copyWith(
                                      color: onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        alert["message"],
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 15.sp,
                                        ),
                                      ),
                                      verticalSpace(height: 0.3.h),
                                      Text(
                                        alert["time"].toString(),
                                        style: AppStyles.lightTextStyle(context)
                                            .copyWith(
                                          color: onSurface.withOpacity(0.6),
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: onSurface.withOpacity(0.6),
                                    size: 18,
                                  ),
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Tapped ${alert["message"]}",
                                          style: AppStyles.lightTextStyle(context)
                                              .copyWith(
                                              color:
                                              isDark ? Colors.white : null),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


