import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/app/theme/popups.dart';
import 'package:trackerapp/data/models/get_device_list_model.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class SingleVehicleInfoScreen extends StatelessWidget {
  final List<Sensor> sensors;
  final int deviceId;
  const SingleVehicleInfoScreen(
      {super.key, required this.sensors, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          children: [
            _SensorsCard(
              sensors: sensors,
            ),
            verticalSpace(height: 1.6.h),
            _InfoCard(
              index: 0,
              icon: Icons.person_outline,
              iconBg: const Color(0xffEAF1FF),
              iconColor: const Color(0xff3B82F6),
              title: "Driver Assignment",
              actionText: "Assign",
              bodyText: "See driver",
              deviceId: deviceId,
            ),
            verticalSpace(height: 1.6.h),
            _InfoCard(
              index: 1,
              icon: Icons.assignment_turned_in,
              iconBg: const Color(0xffEAF1FF),
              iconColor: const Color(0xff3B82F6),
              title: "Alert Assign",
              actionText: "Assign",
              bodyText: "No Alert assigned",
              deviceId: 0,
            ),
            verticalSpace(height: 1.6.h),
            _InfoCard(
              index: 2,
              icon: Icons.build_outlined,
              iconBg: const Color(0xffFFF3E8),
              iconColor: const Color(0xffF97316),
              title: "Maintenance",
              actionText: "Add",
              bodyText: "No upcoming maintenance",
              deviceId: 0,
            ),
            verticalSpace(height: 1.6.h),
            _InfoCard(
              index: 3,
              icon: Icons.attach_money,
              iconBg: const Color(0xffE9F9F1),
              iconColor: const Color(0xff10B981),
              title: "Expenses",
              subtitle: "Total: Rs 0",
              actionText: "Add",
              bodyText: "No expenses recorded",
              deviceId: 0,
            ),
            verticalSpace(height: 1.6.h),
            _InfoCard(
              index: 4,
              icon: Icons.location_on_outlined,
              iconBg: const Color(0xffF1EDFF),
              iconColor: const Color(0xff8B5CF6),
              title: "Geofences",
              actionText: "Assign",
              bodyText: "No geofences assigned",
              hintText: "Create geofences first to assign them",
              deviceId: 0,
            ),
            verticalSpace(height: 1.6.h),
            _InfoCard(
              index: 5,
              icon: Icons.notifications_none_outlined,
              iconBg: const Color(0xfffff1f2),
              iconColor: const Color(0xffe4395e),
              title: "Reminders",
              actionText: "Add",
              bodyText: "No active reminders",
              deviceId: 0,
            ),
          ],
        ),
      ),
    );
  }
}

class _SensorsCard extends StatelessWidget {
  final List<Sensor> sensors;

  const _SensorsCard({
    required this.sensors,
  });

  static const Map<String, IconData> _sensorIcons = {
    "IGNITION": Icons.flash_on,
    "GPS": Icons.gps_fixed,
    "charging": Icons.battery_charging_full,
    "External Volts": Icons.bolt,
    "Satellites": Icons.satellite_alt,
    "Engine hours": Icons.av_timer,
    "Odometer": Icons.speed,
    "Network": Icons.signal_cellular_4_bar,
    "Immobiliser": Icons.lock_outline,
    "Result": Icons.info_outline,
    "SIM": Icons.sim_card,
  };

  static const IconData _fallbackIcon = Icons.sensors;

  Color _getValueColor(String? value) {
    if (value == "On") return AppColors.green;
    if (value == "Off") return AppColors.red;
    return Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: EdgeInsets.symmetric(horizontal: 3.w),
        childrenPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          side: BorderSide.none,
        ),
        collapsedShape: const RoundedRectangleBorder(
          side: BorderSide.none,
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(7.px),
              decoration: BoxDecoration(
                color: ConstantColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.px),
              ),
              child: Icon(
                Icons.sensors,
                color: ConstantColor.primaryColor,
                size: 3.5.h,
              ),
            ),

            horizontalSpace(width: 3.w),
            Text(
              "Vehicle Sensors",
              style: AppStyles.semiboldTextStyle(context)
                  .copyWith(fontSize: 17.sp),
            ),
            // horizontalSpace(width: 2.w),
            // Text(
            //   "(${sensors.length} items)",
            //   style: TextStyle(
            //     fontSize: 14.sp,
            //     color: Colors.grey[600],
            //   ),
            // ),
          ],
        ),
        trailing: Icon(
          Icons.expand_more,
          size: 3.h,
        ),
        children: [
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sensors.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey.shade300,
            ),
            itemBuilder: (context, index) {
              final sensor = sensors[index];
              final String label = sensor.name ?? sensor.type ?? "Unknown";
              final String value =
                  sensor.value ?? sensor.val?.toString() ?? "-";
              final IconData sensorIcon = _sensorIcons[label] ?? _fallbackIcon;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            sensorIcon,
                            size: 22,
                            color: AppColors.blueCyan,
                          ),
                          horizontalSpace(width: 4.w),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    label == "Result"
                        ? Expanded(
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: _getValueColor(value),
                              ),
                            ),
                          )
                        : Text(
                            value,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: _getValueColor(value),
                            ),
                          ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final int index;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String actionText;
  final String bodyText;
  final String? hintText;
  final int deviceId;

  const _InfoCard({
    required this.index,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.actionText,
    required this.bodyText,
    this.hintText,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(1.6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.px),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12.px),
                ),
                child: Icon(icon, color: iconColor, size: 2.2.h),
              ),
              horizontalSpace(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppStyles.semiboldTextStyle(context)
                          .copyWith(fontSize: 17.sp),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: AppStyles.regularTextStyle(context),
                        ),
                      ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  if (index == 0) {
                    showAssignDriverPopup(context, deviceId.toString());
                  } else if (index == 1) {
                    showAlertSettingsPopup(context);
                  } else if (index == 2) {
                    showAddMaintenancePopup(context);
                  } else if (index == 3) {
                    showAddExpensePopup(context);
                  } else if (index == 4) {
                    showGeofenceSettingsPopup(context);
                  } else if (index == 5) {
                    showAddReminderPopup(context);
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      index == 0
                          ? Icon(Icons.person_outline, size: 2.h)
                          : Icon(Icons.add, size: 2.h),
                      horizontalSpace(width: 1.w),
                      Text(
                        actionText,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (!(index == 4 || index == 1)) verticalSpace(height: 1.4.h),
          if (!(index == 4 || index == 1))
            InkWell(
              onTap: () {
                if (index == 0) {
                  showDriverDetailPopup(
                    context,
                   deviceId: deviceId.toString()
                  );
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color:index==0?AppColors.green: const Color(0xffF6F8FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      bodyText,
                      style:AppStyles.regularTextStyle(context).copyWith(
                        color: index==0?AppColors.white:AppColors.textBlack
                      ),
                    ),
                    if (hintText != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        hintText!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
