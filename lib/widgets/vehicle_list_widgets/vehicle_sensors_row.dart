import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';

class VehicleStatusRow extends StatelessWidget {
  const VehicleStatusRow({super.key});

  Widget _buildStatusIcon({
    required IconData icon,
    required Color color,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
       padding: EdgeInsets.all(.8.h),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:AppColors.white,
            boxShadow: [
              BoxShadow(
                color:Colors.grey.withOpacity(0.12),
                blurRadius: 10,
                spreadRadius:0,
                offset: const Offset(0, 4),
              ),
            ],
          ),

            child: Icon(icon, color: color, size: 16.sp)),horizontalSpace(width: 1.w),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 2.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatusIcon(
            icon: Icons.lock,
            color: Colors.red,
            value: 'On',
          ),
          _buildStatusIcon(
            icon: Icons.signal_cellular_alt,
            color: Colors.orange,
            value: 'Good',
          ),
          _buildStatusIcon(
            icon: Icons.key,
            color: Colors.green,
            value: 'On',
          ),
          _buildStatusIcon(
            icon: Icons.battery_charging_full,
            color: Colors.green,
            value: 'On',
          ),
          _buildStatusIcon(
            icon: Icons.satellite_alt_sharp,
            color: Colors.green,
            value: '12.8V',
          ),
        ],
      ),
    );
  }
}
