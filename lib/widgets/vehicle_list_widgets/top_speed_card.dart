import 'dart:async';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_dashboard_history_model.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class TopSpeedCard extends StatefulWidget {
  final GetDashboardHistoryModel historyData;
  const TopSpeedCard({super.key, required this.historyData});
  @override
  State<TopSpeedCard> createState() => _TopSpeedCardState();
}
class _TopSpeedCardState extends State<TopSpeedCard> {
  late List<bool> _visibleBars;
  @override
  void initState() {
    super.initState();
    _visibleBars = List.generate(widget.historyData.summary.topSpeeds.length, (_) => false);
    _animateBars();
  }
  void _animateBars() {
    for (int i = 0; i < _visibleBars.length; i++) {
      Timer(Duration(milliseconds: i * 300), () {
        if (mounted) {
          setState(() => _visibleBars[i] = true);
        }
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final topSpeeds = widget.historyData.summary.topSpeeds;
    if (topSpeeds.isEmpty) return const SizedBox.shrink();
    const fixedMaxSpeed = 200;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 3.w),
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Top Speed Vehicles",
            style:AppStyles.semiboldTextStyle(context),
          ),
          verticalSpace(height: 1.8.h),
          Column(
            children: List.generate(
              topSpeeds.length.clamp(0, 5),
                  (i) => _speedBar(context, topSpeeds[i], i, fixedMaxSpeed),
            ),
          ),
        ],
      ),
    );
  }

  Widget _speedBar(BuildContext context, dynamic item, int index, int maxSpeed) {
    final gradientColors = [
      [Color(0xffA2D15B), Color(0xff5D6D27)],
      [Color(0xff4A90E2), Color(0xff003B73)],
      [Color(0xffE7C977), Color(0xff7A6323)],
    ];
    double percent = item.topSpeedKph / maxSpeed;
    percent = percent.clamp(0.10, 1.0);
    return Container(
      margin: EdgeInsets.only(bottom: 1.8.h),
      child: Stack(
        children: [
          Container(
            height: 4.h,
            decoration: BoxDecoration(
              color: ConstantColor.secondaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            height: 4.h,
            width: _visibleBars[index] ? 100.w * percent : 0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors[index % gradientColors.length],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Container(
              padding: EdgeInsets.only(left: 4.w,right: 1.w),
              child: Row(
                children: [
                  Expanded(flex: 2,
                    child: Text(
                      _shortName(item.deviceName ?? ""),
                      style: AppStyles.appTitleTextStyle.copyWith(fontSize: 15.sp,
                          color: AppColors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(flex: 1,
                    child: Text(
                      "${item.topSpeedKph} km/h",
                      style: AppStyles.appTitleTextStyle.copyWith(fontSize: 15.sp,
                        color: AppColors.white
                      ),
                    ),
                  ),
                ],
              )

            ),
          ),
        ],
      ),
    );
  }

  String _shortName(String name) =>
      name.length <= 14 ? name : "${name.substring(0, 14)}...";
}
