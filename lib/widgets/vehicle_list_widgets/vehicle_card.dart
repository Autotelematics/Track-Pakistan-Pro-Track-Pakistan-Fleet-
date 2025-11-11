import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/vehicle_data.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/vehicle_sensors_row.dart';
class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final ThemeData theme;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.statusColor(vehicle.status);

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
            offset: Offset(0, 3),
          ),
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
                  width: 26.w,
                  height: 12.h,
                  child: Transform.scale(
                    scale: 1.1,
                    child: CachedNetworkImage(
                      imageUrl: vehicle.image,
                      fit: BoxFit.contain,
                      placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                      const Icon(Icons.error),
                    ),
                  ),
                ),
                horizontalSpace(width: 4.w),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/caricon.png",
                            height: 2.6.h,
                          ),
                          horizontalSpace(width: 1.w),
                          Text(
                            vehicle.title,
                            style: AppStyles.vehicleTitle(context),
                          ),
                        ],
                      ),
                      verticalSpace(height: 1.h),
                      _buildInfoText(context, "Speed : ", "${vehicle.speed} km/h"),
                      verticalSpace(height: 1.h),
                      _buildStatusText(context, vehicle.status),
                      verticalSpace(height: 1.h),
                      _buildInfoText(context, "Update : ", vehicle.update),
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
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.13),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    color: statusColor,
                  ),
                  child: Text(
                    vehicle.status,
                    style: AppStyles.statusChip(context).copyWith(
                      fontSize: 14.sp
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Text(
                vehicle.address,
                style: AppStyles.address(context),
                textAlign: TextAlign.center,
              ),
            ),
            verticalSpace(height: 1.h),
            VehicleStatusRow()
          ],
        ),
      ),
    );
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

  Widget _buildStatusText(BuildContext context, String status) => RichText(
    text: TextSpan(
      children: [
        TextSpan(text: "Status : ", style: AppStyles.infoLabel(context)),
        TextSpan(text: status, style: AppStyles.status(status, context)),
        TextSpan(
          text: " 5h 34min 12s",
          style: AppStyles.statusDuration(context),
        ),
      ],
    ),
  );



}