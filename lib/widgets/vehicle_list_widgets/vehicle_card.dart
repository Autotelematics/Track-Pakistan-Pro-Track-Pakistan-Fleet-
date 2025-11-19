import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_device_list_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/vehicle_sensors_row.dart';

class VehicleCard extends StatelessWidget {
  final Item vehicle;
  final ThemeData theme;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.px),
        color: theme.cardColor,
        boxShadow: const [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              spreadRadius: 0,
              offset: Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 2.w),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                horizontalSpace(width: 0.5.w),
                SizedBox(
                  width: 16.3.w,
                  height: 8.4.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      vehicle.path.toString().isNotEmpty
                          ? '${AppUrl.baseImgURL}${vehicle.path.toString()}'
                          : 'https://via.placeholder.com/80',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.directions_car,
                        size: 40,
                        color: Colors.grey,
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.amberAccent,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                horizontalSpace(width: 2.w),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset("assets/images/caricon.png",
                              height: 2.6.h),
                          horizontalSpace(width: 1.w),
                          Text(
                              vehicle.name.toString().length > 12
                                  ? "${vehicle.name.toString().substring(0, 12)}..."
                                  : vehicle.name.toString(),
                              style: AppStyles.vehicleTitle(context)),
                        ],
                      ),
                      verticalSpace(height: 1.h),
                      _buildInfoText(
                          context, "Speed : ", "${vehicle.speed ?? 0} km/h"),
                      verticalSpace(height: 1.h),
                      _buildStatusText(context),
                      verticalSpace(height: 1.h),
                      _buildInfoText(
                          context, "Update : ", vehicle.time ?? 'N/A'),
                      verticalSpace(height: 1.h),

                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  alignment: Alignment.center,
                  height: 3.h,
                  width: 17.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: statusColor,
                    boxShadow: [
                      BoxShadow(
                          color: statusColor.withOpacity(0.13),
                          blurRadius: 6,
                          offset: Offset(0, 3))
                    ],
                  ),
                  child: Text(
                    _getStatusLabel(),
                    style:
                        AppStyles.statusChip(context).copyWith(fontSize: 14.sp),
                  ),
                ),
                verticalSpace(height: 1.h),

              ],
            ),
            VehicleStatusRow(vehicle: vehicle), // Item pass
            verticalSpace(height: 1.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Text(
                vehicle.addr ?? '',
                style: AppStyles.address(context),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (vehicle.online) {
      case 'online':
        return AppColors.green;
      case 'ack':
        return AppColors.red;
      case 'engine':
        return Colors.orange;
      case 'black':
        return Colors.orange;
      case 'offline':
        if (vehicle.time?.toLowerCase() == 'not connected') return Colors.grey;
        if (vehicle.time?.toLowerCase() == 'expired') return Colors.purple;
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel() {
    switch (vehicle.online) {
      case 'online':
        return 'Running';
      case 'ack':
        return 'Stopped';
      case 'engine':
        return 'Idle';
      case 'black':
        return 'Parked';
      case 'offline':
        if (vehicle.time?.toLowerCase() == 'not connected') return 'No Data';
        if (vehicle.time?.toLowerCase() == 'expired') return 'Expired';
        return 'Offline';
      default:
        return 'Unknown';
    }
  }

  Widget _buildInfoText(BuildContext context, String label, String value) =>
      RichText(
        text: TextSpan(
          children: [
            TextSpan(text: label, style: AppStyles.infoLabel(context)),
            TextSpan(text: value, style: AppStyles.infoValue(context)),
          ],
        ),
      );

  Widget _buildStatusText(BuildContext context) => RichText(
        text: TextSpan(
          children: [
            TextSpan(text: "Status : ", style: AppStyles.infoLabel(context)),
            TextSpan(
                text: _getStatusLabel(),
                style: AppStyles.status(_getStatusLabel(), context)),
            TextSpan(
                text: "  ${_formatStopDuration()}",
                style: AppStyles.statusDuration(context)),
          ],
        ),
      );

  String _formatStopDuration() {
    final duration = vehicle.stopDuration ?? "0";
    return duration.contains("h") ? duration : "$duration sec";
  }
}
