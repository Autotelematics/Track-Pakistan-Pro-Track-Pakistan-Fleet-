import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_device_list_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/vehicle_list_scale.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/vehicle_sensors_row.dart';

class VehicleCard extends StatelessWidget {
  final Item vehicle;
  final ThemeData theme;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.theme,
  });

  bool _isEngineKilled() {
    final blocked = vehicle.param?.blocked?.trim().toLowerCase();
    if (blocked != null && blocked.isNotEmpty) {
      return blocked == 'true';
    }

    final out1 = vehicle.param?.out1?.trim().toLowerCase();
    return out1 == 'true';
  }

  String _getColorPrefix() {
    final onlineStatus = vehicle.online?.toLowerCase();
    final timeLower = vehicle.time?.toLowerCase();

    if (onlineStatus == 'online') return 'Green';
    if (onlineStatus == 'ack') return 'Red';
    if (onlineStatus == 'engine') return 'Yellow';
    if (onlineStatus == 'black') return 'Black';

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
    final statusKey = _getStatusKey();
    switch (statusKey) {
      case 'running':
        return AppColors.green;
      case 'stopped':
        return AppColors.red;
      case 'idle':
        return AppColors.yellow;
      case 'offline':
        return AppColors.blueCyan;
      case 'nodata':
        return AppColors.grey;
      case 'expired':
        return AppColors.brown;
      case 'parked':
        return AppColors.brown;
      default:
        return AppColors.grey;
    }
  }

  String _getStatusKey() {
    switch (vehicle.online) {
      case 'online':
        return 'running';
      case 'ack':
        return 'stopped';
      case 'engine':
        return 'idle';
      case 'black':
        return 'parked';
      case 'offline':
        if (vehicle.time?.toLowerCase() == 'not connected') return 'nodata';
        if (vehicle.time?.toLowerCase() == 'expired') return 'expired';
        return 'offline';
      default:
        return 'unknown';
    }
  }

  Widget _infoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Widget? valueChild,
    Color? valueColor,
    TextStyle? valueStyle,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final textScale = vehicleListTextScale(context);
    final iconScale = vehicleListIconScale(context);
    return Row(
      children: [
        Container(
          width: 6.2.w,
          height: 6.2.w,
          decoration: BoxDecoration(
            color: (valueColor ?? onSurface).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: (13 * iconScale).sp,
            color: valueColor ?? onSurface,
          ),
        ),
        horizontalSpace(width: 1.8.w),
        Text(
          '$label: ',
          style: AppStyles.infoLabel(context).copyWith(
            fontSize: (11.8 * textScale).sp,
            color: onSurface.withValues(alpha: .72),
          ),
        ),
        Expanded(
          child: valueChild ??
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: valueStyle ??
                    AppStyles.infoValue(context).copyWith(
                      fontSize: (11.8 * textScale).sp,
                      color: valueColor ?? onSurface,
                    ),
              ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusKey = _getStatusKey();
    final statusLabel = _localizedStatus(context, statusKey);
    final isRunning = statusKey == 'running';
    final isBlocked = _isEngineKilled();
    final String? localAsset = _getLocalAssetPath();
    final textScale = vehicleListTextScale(context);
    final iconScale = vehicleListIconScale(context);

    Widget vehicleImage;
    if (localAsset != null) {
      vehicleImage = Transform.scale(
        scale: 1.05,
        child: Image.asset(
          localAsset,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.directions_car,
            size: 42,
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
          size: 42,
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
      margin: EdgeInsets.only(top: .45.h, bottom: .45.h, right: 1.2.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.px),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
        border:
            Border.all(color: statusColor.withValues(alpha: 0.28), width: .9),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 62.w,
              height: 3.9.h,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14.px),
                  bottomRight: Radius.circular(10.px),
                ),
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(3.2.w, 1.0.h, 3.2.w, .65.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  vehicle.name.toString().length > 34
                                      ? '${vehicle.name.toString().substring(0, 34)}...'
                                      : vehicle.name.toString(),
                                  style:
                                      AppStyles.vehicleTitle(context).copyWith(
                                    fontSize: (15.2 * textScale).sp,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          verticalSpace(height: .95.h),
                          _infoTile(
                            context,
                            icon: Icons.speed_rounded,
                            label: context.l10n.speed,
                            value: '${vehicle.speed ?? 0} km/h',
                            valueChild: Shimmer.fromColors(
                              enabled: isRunning,
                              baseColor: statusColor,
                              highlightColor:
                                  statusColor.withValues(alpha: .55),
                              period: const Duration(milliseconds: 1300),
                              child: Text(
                                '${vehicle.speed ?? 0} km/h',
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.semiboldTextStyle(context)
                                    .copyWith(
                                  fontSize: (14.2 * textScale).sp,
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: .3,
                                  fontFamily: 'monospace',
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ),
                            valueStyle:
                                AppStyles.semiboldTextStyle(context).copyWith(
                              fontSize: (14.2 * textScale).sp,
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .3,
                              fontFamily: 'monospace',
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                          verticalSpace(height: .75.h),
                          _infoTile(
                            context,
                            icon: Icons.access_time_rounded,
                            label: context.l10n.update,
                            value:
                                vehicle.time ?? context.l10n.notAvailableShort,
                          ),
                          verticalSpace(height: .75.h),
                          SizedBox(
                            width: 60.w,
                            child: VehicleStatusRow(
                              vehicle: vehicle,
                              horizontalPadding: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    horizontalSpace(width: 1.8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.2.w, vertical: .35.h),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: statusColor.withValues(alpha: .35),
                            ),
                          ),
                          child: Text(
                            statusLabel,
                            style:
                                AppStyles.semiboldTextStyle(context).copyWith(
                              fontSize: (11.4 * textScale).sp,
                              color: statusColor,
                            ),
                          ),
                        ),
                        verticalSpace(height: .5.h),
                        SizedBox(
                          width: 25.w,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                opacity: isBlocked ? 0.40 : 1,
                                child: Transform.scale(
                                  scale: 1.4,
                                  child: SizedBox(
                                      height: 26.w,
                                      child: vehicleImage),
                                ),
                              ),
                              if (isBlocked)
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/lock.svg',
                                      width: 20.w,
                                      height: 20.w,
                                      colorFilter: const ColorFilter.mode(
                                        Color.fromARGB(255, 255, 86, 86),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    SizedBox(height: .25.h),
                                    Text(
                                      context.l10n.engineKilled,
                                      style:
                                      AppStyles.semiboldTextStyle(context)
                                          .copyWith(
                                        fontSize: (10.8 * textScale).sp,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: .65),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              verticalSpace(height: .0.h),
              Divider(
                height: .0,
                thickness: .6,
                color: theme.colorScheme.outline.withValues(alpha: .18),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 3.2.w,
                  right: 3.2.w,
                  bottom: 1.0.h,
                  top: .85.h,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: (15 * iconScale).sp,
                      color: theme.colorScheme.onSurface.withValues(alpha: .52),
                    ),
                    horizontalSpace(width: 1.3.w),
                    Expanded(
                      child: Text(
                        vehicle.addr ?? context.l10n.noAddressFound,
                        style: AppStyles.address(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _localizedStatus(BuildContext context, String statusKey) {
    final l10n = context.l10n;
    switch (statusKey) {
      case 'running':
        return l10n.vehicleStatusRunning;
      case 'stopped':
        return l10n.vehicleStatusStopped;
      case 'idle':
        return l10n.vehicleStatusIdle;
      case 'offline':
        return l10n.vehicleStatusOffline;
      case 'nodata':
        return l10n.vehicleStatusNoData;
      case 'expired':
        return l10n.vehicleStatusExpired;
      case 'parked':
        return l10n.vehicleStatusParked;
      default:
        return l10n.vehicleStatusUnknown;
    }
  }
}
