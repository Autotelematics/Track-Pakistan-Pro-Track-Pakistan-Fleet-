import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/data/models/get_device_list_model.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';

class VehicleStatusRow extends StatelessWidget {
  final Item vehicle;

  const VehicleStatusRow({super.key, required this.vehicle});

  Widget _buildStatusIcon({required IconData icon, required Color color, required String value}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(.8.h),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.12), blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: Icon(icon, color: color, size: 16.sp),
        ),
        horizontalSpace(width: 1.w),
        Text(value, style: TextStyle(fontSize: 14.sp, color: color, fontWeight: FontWeight.w400)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sensors = vehicle.sensors ?? [];
    bool immobilizer = false;
    String rssi = "N/A", ignition = "N/A", charging = "N/A", battery = "N/A";

    for (var s in sensors) {
      final name = s.name?.toLowerCase() ?? '';
      final value = s.value?.toString().toLowerCase() ?? '';
      if (name.contains('immobilizer')) immobilizer = value == 'on';
      if (name == 'ignition') ignition = value == 'on' ? 'On' : 'Off';
      if (name == 'charging') charging = value == 'on' ? 'On' : 'Off';
      if (s.type == 'battery') battery = s.value?.toString() ?? 'N/A';
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatusIcon(icon: Icons.lock, color: immobilizer ? Colors.red : Colors.green, value: immobilizer ? 'On' : 'Off'),
          _buildStatusIcon(icon: Icons.signal_cellular_alt, color: Colors.orange, value: rssi),
          _buildStatusIcon(icon: Icons.key, color: ignition == 'On' ? Colors.green : Colors.red, value: ignition),
          _buildStatusIcon(icon: Icons.battery_charging_full, color: charging == 'On' ? Colors.green : Colors.red, value: charging),
          _buildStatusIcon(icon: Icons.satellite_alt_sharp, color: Colors.green, value: battery),
        ],
      ),
    );
  }
}