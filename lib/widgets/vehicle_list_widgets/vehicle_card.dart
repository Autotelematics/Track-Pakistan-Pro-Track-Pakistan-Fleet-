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

  String _getColorPrefix() {
    final onlineStatus = vehicle.online?.toLowerCase();
    final timeLower = vehicle.time?.toLowerCase();

    if (onlineStatus == 'online') return 'Green';
    if (onlineStatus == 'ack') return 'Red';
    if (onlineStatus == 'engine') return 'Yellow';
    if (onlineStatus == 'black') return 'Black';

    // Offline cases
    if (onlineStatus == 'offline') {
      if (timeLower == 'not connected' || timeLower == 'expired') {
        return 'Black';
      }
      return 'Blue';
    }

    return 'Blue';
  }

  String? _getLocalAssetPath() {
    final rawType = vehicle.vehicleType;
    if (rawType == null || rawType.trim().isEmpty) return null;

    final normalized = rawType.trim().toLowerCase();

    const Map<String, String> typeMap = {
      'ambulance': 'Ambulance',
      'bicycle': 'Bicycle',
      'boat': 'Boat',
      'bus': 'Bus',
      'car': 'Car',
      'motorbike': 'Motorbike',
      'motorcycle': 'Motorbike',
      'suv': 'SUV',
      'truck': 'Truck',
      'truck trailer': 'Truck Trailer',
      'truck_trailer': 'Truck Trailer',
      'trailer': 'Truck Trailer',
    };

    final vehicleName = typeMap[normalized];
    if (vehicleName == null) return null;

    final color = _getColorPrefix();
    return 'assets/images/vehicle/$color $vehicleName.png';
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
            TextSpan(
                text: label,
                style: AppStyles.infoLabel(context).copyWith(fontSize: 16.sp)),
            TextSpan(
                text: value,
                style: AppStyles.infoValue(context).copyWith(fontSize: 15.sp)),
          ],
        ),
      );

  Widget _buildStatusText(BuildContext context, String status) => Row(
    children: [
      Text(
        "Status : ",
        style: AppStyles.infoLabel(context).copyWith(fontSize: 16.sp),
      ),
      Text(
        _getStatusLabel(),
        style: AppStyles.statusDuration(context)
            .copyWith(fontSize: 15.sp, color: _getStatusColor()),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final String? localAsset = _getLocalAssetPath();

    // Vehicle Image Widget
    Widget vehicleImage;
    if (localAsset != null) {
      vehicleImage = Transform.scale(
        scale: 1.2,
        child: Image.asset(
          localAsset,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.directions_car,
            size: 40,
            color: Colors.grey,
          ),
        ),
      );
    } else {
      final String networkUrl = vehicle.path?.isNotEmpty == true
          ? '${AppUrl.baseImgURL}${vehicle.path}'
          : 'https://via.placeholder.com/80';
      vehicleImage = Image.network(
        networkUrl,
        width: 60,
        height: 90,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.directions_car,
          size: 40,
          color: Colors.grey,
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.amberAccent,
            ),
          );
        },
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.px),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.4),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: statusColor.withOpacity(0.7), width: 1),
      ),
      child: Column(
        children: [
          // Vehicle Name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: .2.h),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.px),
                        topRight: Radius.circular(12.px)),
                    color: statusColor.withOpacity(0.8),
                  ),
                  child: Text(
                    vehicle.name.toString().length > 30
                        ? "${vehicle.name.toString().substring(0, 30)}..."
                        : vehicle.name.toString(),
                    style: AppStyles.statusChip(context).copyWith(fontSize: 16.sp),
                  ),
                ),
              ),
            ],
          ),
          // Vehicle Image + Info
          Padding(
            padding: EdgeInsets.only(left: 6.w, right: 0.w, top: 0.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  height: 12.h,
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: vehicleImage,
                  ),
                ),

                horizontalSpace(width: 8.w),
                // Info Column
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      verticalSpace(height: .8.h),
                      _buildInfoText(
                          context, "Speed : ", "${vehicle.speed ?? 0} km/h"),
                      verticalSpace(height: 1.5.h),
                      _buildStatusText(context, vehicle.online.toString()),
                      verticalSpace(height: 1.5.h),
                      _buildInfoText(
                          context, "Update : ", vehicle.time ?? 'N/A'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          verticalSpace(height: 1.h),
          VehicleStatusRow(vehicle: vehicle),
          Padding(
            padding: EdgeInsets.only(left: 2.w, right: 2.w, bottom: 1.5.h, top: 1.h),
            child: Text(
              vehicle.addr ?? 'No Address Founded',
              style: AppStyles.address(context),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
