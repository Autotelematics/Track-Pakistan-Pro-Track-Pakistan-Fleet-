import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/dashboard_data.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';

class AlertGrid extends StatelessWidget {
  final DashboardData data;

  const AlertGrid({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    return Column(
      children: [
        _alertFilterRow(context),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.alerts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (context, index) => Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: data.alerts[index].bgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: SvgPicture.asset(
                          data.alerts[index].svgPath,
                          height: 24,
                          width: 24,
                          color: Colors.white,
                        ),
                      ),
                      horizontalSpace(width: 1.h),
                      Expanded(
                        child: Text(
                          data.alerts[index].name,
                          style: AppStyles.boldTextStyle(context).copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 0.5.h),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${data.alerts[index].value}  ',
                            style: AppStyles.boldTextStyle(context)
                                .copyWith(fontSize: 17.sp),
                          ),
                          TextSpan(
                            text: data.alerts[index].unit,
                            style: AppStyles.regularTextStyle(context)
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _alertFilterRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Alerts Count",
            style: AppStyles.boldTextStyle(context)
                .copyWith(fontSize: 17.sp, fontWeight: FontWeight.w800),
          ),

        ],
      ),
    );
  }
}