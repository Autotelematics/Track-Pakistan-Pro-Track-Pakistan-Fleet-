import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/alert_settings_provider.dart';
import 'package:trackerapp/utils/top_curve_bezier.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class AlertSettingsScreen extends StatelessWidget {
  const AlertSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(colors: [theme.cardColor, theme.cardColor])
              : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.purple,
              AppColors.blueCyanWithOpacity,
            ],
          ),
        ),
        child: Column(
          children: [
            verticalSpace(height: 7.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color:isDark? onSurface:AppColors.white,),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Flexible(child: Container()),
                  Text(
                    "Alert Settings",
                    style: AppStyles.boldTextStyle(context).copyWith(
                      color:isDark? onSurface:AppColors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  horizontalSpace(width: 10.w),
                  Flexible(child: Container()),

                ],
              ),
            ),

            verticalSpace(height: 4.h),

            /// MAIN BODY
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
                  padding: EdgeInsets.symmetric(horizontal: 5.w,vertical: 2.h),
                  child: Consumer<AlertSettingsProvider>(
                    builder: (context, provider, child) {
                      return ListView(
                        padding: EdgeInsets.only(top: 3.h),
                        children: [
                          _tile(context, "Excess Parking", provider.excessParking, () => provider.toggle("excessParking")),
                          _tile(context, "Offline Duration", provider.offlineDuration, () => provider.toggle("offlineDuration")),
                          _tile(context, "Ignition ON", provider.ignitionOn, () => provider.toggle("ignitionOn")),
                          _tile(context, "Ignition OFF", provider.ignitionOff, () => provider.toggle("ignitionOff")),
                          _tile(context, "Fence Exit", provider.fenceExit, () => provider.toggle("fenceExit")),
                          _tile(context, "Overspeed", provider.overspeed, () => provider.toggle("overspeed")),

                          if (provider.overspeed) ...[
                            SizedBox(height: 1.h),
                            Text(
                              "Speed Limit: ${provider.overspeedLimit.toInt()} km/h",
                              style: AppStyles.regularTextStyle(context)
                                  .copyWith(color: onSurface),
                            ),
                            Slider(
                              value: provider.overspeedLimit,
                              min: 0,
                              max: 200,
                              onChanged: provider.updateOverspeed,
                            ),
                            SizedBox(height: 2.h),
                          ],

                          _tile(context, "Stop Duration", provider.stopDuration, () => provider.toggle("stopDuration")),
                          _tile(context, "Power Disconnected", provider.powerDisconnected, () => provider.toggle("powerDisconnected")),
                          _tile(context, "Idle Duration", provider.idleDuration, () => provider.toggle("idleDuration")),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, String title, bool value, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return AnimatedContainer(
      duration: Duration(seconds: 9),
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.cardColor,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: AppStyles.regularTextStyle(context)
              .copyWith(color: onSurface),
        ),
        trailing: Switch(
          value: value,
          activeColor: theme.primaryColor,
          onChanged: (_) => onTap(),
        ),
      ),
    );
  }
}
