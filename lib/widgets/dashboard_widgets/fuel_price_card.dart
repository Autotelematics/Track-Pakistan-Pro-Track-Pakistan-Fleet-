import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_dashboard_model.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class FuelPriceCard extends StatelessWidget {
  final GetDashboardModel data;

  const FuelPriceCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            "Fuel Prices",
            style: AppStyles.semiboldTextStyle(context),
          ),
          verticalSpace(height: 2.h),

          // Petrol Row
          Row(
            children: [
              Icon(Icons.local_gas_station, color: Colors.green, size: 20.sp),
              horizontalSpace(width: 3.w),
              Expanded(
                child: Text(
                  "Petrol",
                  style: AppStyles.regularTextStyle(context).copyWith(fontSize: 15.sp),
                ),
              ),
              Text(
                "${data.petrolPrice.toStringAsFixed(2)} PKR",
                style: AppStyles.semiboldTextStyle(context).copyWith(fontSize: 15.sp),
              ),
            ],
          ),
          verticalSpace(height: 1.5.h),

          // Diesel Row
          Row(
            children: [
              Icon(Icons.local_gas_station, color: Colors.orange, size: 20.sp),
              horizontalSpace(width: 3.w),
              Expanded(
                child: Text(
                  "Diesel",
                  style: AppStyles.regularTextStyle(context).copyWith(fontSize: 15.sp),
                ),
              ),
              Text(
                "${data.dieselPrice.toStringAsFixed(2)} PKR",
                style: AppStyles.semiboldTextStyle(context).copyWith(fontSize: 15.sp),
              ),
            ],
          ),
          verticalSpace(height: 2.h),
          Divider(color: onSurface.withOpacity(0.2)),
          verticalSpace(height: 1.h),

          // Last Updated
          Row(
            children: [
              Icon(Icons.update, color: Colors.blue, size: 18.sp),
              horizontalSpace(width: 3.w),
              Text(
                "Last Updated: ${data.fuelPriceLastUpdated}",
                style: AppStyles.regularTextStyle(context).copyWith(fontSize: 13.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
