import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/dashboard_data.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class AlertGrid extends StatelessWidget {
  final DashboardData data;

  const AlertGrid({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    return Column(
      children: [
        _alertFilterRow(context),
        verticalSpace(height: .6.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.alerts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.8,
            ),
            itemBuilder: (context, index) => Container(
              padding: EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 3.w),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12.px),
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
                          style: AppStyles.regularTextStyle(context)
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
                            style: AppStyles.regularTextStyle(context)
                                .copyWith(fontSize: 15.sp),
                          ),
                          TextSpan(
                            text: data.alerts[index].unit,
                            style: AppStyles.regularTextStyle(context)
                                .copyWith(fontSize: 14.sp),
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
      padding: EdgeInsets.symmetric(horizontal: 9.w),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Alerts Count",
            style:AppStyles.semiboldTextStyle(context)
          ),

        ],
      ),
    );
  }
}