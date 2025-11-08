import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/vehicle_expense_provider.dart';
import 'package:trackerapp/utils/top_curve_bezier.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';


class VehicleExpenseScreen extends StatelessWidget {
  const VehicleExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return ChangeNotifierProvider(
      create: (_) => VehicleExpenseProvider(),
      child: Consumer<VehicleExpenseProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(colors: [theme.cardColor, theme.cardColor])
                    : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.purple, AppColors.blueCyanWithOpacity],
                ),
              ),
              child: Column(
                children: [
                  verticalSpace(height: 6.h),

                  // Top Bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: isDark ? onSurface : Colors.white),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Total Expense',
                              style: AppStyles.boldTextStyle(context).copyWith(
                                color: isDark ? onSurface : Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 48), // balance for back icon
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // White curved card area
                  Expanded(
                    child: ClipPath(
                      clipper: TopCurveClipper(),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: isDark
                              ? LinearGradient(colors: [theme.scaffoldBackgroundColor, theme.scaffoldBackgroundColor])
                              : LinearGradient(colors: [Colors.white, Colors.grey.shade100]),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Month selector row
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => provider.changeMonth(-1),
                                    icon: Icon(Icons.arrow_back_ios_new, size: 18),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => provider.pickDate(context),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(provider.monthLabel,
                                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                                          SizedBox(height: 4),
                                          Text('April 2022', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => provider.changeMonth(1),
                                    icon: Icon(Icons.arrow_forward_ios, size: 18),
                                  ),
                                ],
                              ),

                              verticalSpace(height: 2.h),

                              // small horizontal date chips (static look similar to screenshot)
                              SizedBox(
                                height: 7.h,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: List.generate(7, (i) {
                                    final day = 20 + i;
                                    final isSelected = day == 24;
                                    return Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                                      child: Column(
                                        children: [
                                          Text('M', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                                          SizedBox(height: 6),
                                          Container(
                                            width: 10.w,
                                            height: 4.h,
                                            decoration: BoxDecoration(
                                              color: isSelected ? AppColors.purple : Colors.transparent,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text('$day', style: TextStyle(color: isSelected ?AppColors.white:isDark?AppColors.white:AppColors.black)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),

                              verticalSpace(height: 3.h),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('You have Spend', style: AppStyles.lightTextStyle(context).copyWith(color: AppColors.textBlack)),
                                        verticalSpace(height: 6),
                                        Text('\$${provider.monthTotal.toStringAsFixed(0)}',
                                            style:AppStyles.boldTextStyle(context).copyWith(color: isDark?AppColors.white:AppColors.purple)),
                                        verticalSpace(height: 6),
                                        Text('this month.', style:  AppStyles.lightTextStyle(context).copyWith(color: AppColors.grey)),
                                      ],
                                    ),
                                  ),

                                  // small date label
                                  Column(
                                    children: [
                                      Text('Apr 01, 2022', style: TextStyle(color: Colors.grey.shade500, fontSize: 12.sp)),
                                    ],
                                  ),
                                ],
                              ),

                              verticalSpace(height: 1.h),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 7,
                                    child: Container(
                                      height: 2.h,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Stack(
                                        children: [
                                          FractionallySizedBox(
                                            widthFactor: 0.7578,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(colors: [AppColors.purple, AppColors.blueCyanWithOpacity]),
                                                borderRadius: BorderRadius.circular(10.px),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  horizontalSpace(width: 4.w),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('75.78%', style: AppStyles.regularTextStyle(context)),
                                        verticalSpace(height: .6.h),
                                        Text('24.22%', style: AppStyles.regularTextStyle(context).copyWith(fontSize: 15.sp)),
                                      ],
                                    ),
                                  )
                                ],
                              ),

                              verticalSpace(height: 3.h),

                              // Analytics header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Analytics', style: AppStyles.appTitleTextStyle.copyWith(
                                    fontSize: 17.sp
                                  )),
                                  Text('View All', style: AppStyles.appTitleTextStyle.copyWith(
                                      fontSize: 15.sp,
                                    color: AppColors.purple
                                  )
                                  ),
                                ],
                              ),

                              // Pie chart + legend
                              SizedBox(
                                height: 33.h,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 9,
                                      child: PieChart(
                                        PieChartData(
                                          sectionsSpace: 2,
                                          centerSpaceRadius: 30,
                                          sections: [
                                            PieChartSectionData(
                                              value: provider.shoppingPercent,
                                              color: Color(0xFFFF7043), // orange
                                              radius: 8.h,
                                              title: '${provider.shoppingPercent.toInt()}%',
                                              titleStyle: AppStyles.regularTextStyle(context).copyWith(color: AppColors.white),
                                            ),
                                            PieChartSectionData(
                                              value: provider.foodPercent,
                                              color: Color(0xFF1F2B4D), // dark navy
                                              radius: 8.h,
                                              title: '${provider.foodPercent.toInt()}%',
                                              titleStyle: AppStyles.regularTextStyle(context).copyWith(color: AppColors.white)
                                            ),
                                            PieChartSectionData(
                                              value: provider.healthPercent,
                                              color: AppColors.purple,
                                              radius: 8.h,
                                              title: '${provider.healthPercent.toInt()}%',
                                              titleStyle: AppStyles.regularTextStyle(context).copyWith(color: AppColors.white)
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    horizontalSpace(width: 3.w),

                                    // Legend
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          _legendItem('Shopping', '\$3,762', Color(0xFFFF7043),context),
                                          SizedBox(height: 2.h),
                                          _legendItem('Food And Drinks', '\$4,672', Color(0xFF1F2B4D),context),
                                          SizedBox(height: 2.h),
                                          _legendItem('Healthcare', '\$2,917', AppColors.purple,context),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),


                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _legendItem(String title, String amount, Color color,BuildContext context) {
    return Row(
      children: [
        Container(width: 4.w, height: 1.5.h, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        horizontalSpace(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppStyles.regularTextStyle(context)),
              verticalSpace(height: .4.h),
              Text(amount, style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        )
      ],
    );
  }
}
