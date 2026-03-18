import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/admin_status_model.dart';

class AdminUserStatusCountCard extends StatefulWidget {
  final AdminUsersStatus status;
  final VoidCallback? onViewUsers;

  const AdminUserStatusCountCard({
    super.key,
    required this.status,
    this.onViewUsers,
  });

  @override
  State<AdminUserStatusCountCard> createState() =>
      _AdminUserStatusCountCardState();
}

class _AdminUserStatusCountCardState extends State<AdminUserStatusCountCard>
    with TickerProviderStateMixin {
  AnimationController? _entryController;
  Animation<double> _chartScale = const AlwaysStoppedAnimation<double>(1.0);
  Animation<double> _chartOpacity = const AlwaysStoppedAnimation<double>(1.0);

  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _chartScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _entryController!, curve: Curves.easeOutBack),
    );
    _chartOpacity = CurvedAnimation(
      parent: _entryController!,
      curve: Curves.easeOut,
    );
    _entryController!.forward();
  }

  @override
  void dispose() {
    _entryController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.1.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User Status',
                style: AppStyles.semiboldTextStyle(context).copyWith(
                  fontSize: 15.sp,
                ),
              ),
              if (widget.onViewUsers != null)
                TextButton(
                  onPressed: widget.onViewUsers,
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding:
                        EdgeInsets.symmetric(horizontal: 1.w, vertical: .2.h),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View Users',
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: .5.h),
          Text(
            'Total Users: ${widget.status.totalUsers}',
            style:
                AppStyles.regularTextStyle(context).copyWith(fontSize: 13.sp),
          ),
          SizedBox(height: 1.h),
          FadeTransition(
            opacity: _chartOpacity,
            child: ScaleTransition(
              scale: _chartScale,
              child: SizedBox(
                height: 22.h,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  primaryXAxis: CategoryAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: const AxisLine(width: 0),
                  ),
                  primaryYAxis: NumericAxis(
                    majorGridLines: MajorGridLines(
                      width: .4,
                      color: theme.colorScheme.onSurface.withValues(alpha: .2),
                    ),
                    axisLine: const AxisLine(width: 0),
                    majorTickLines: const MajorTickLines(size: 0),
                  ),
                  series: <ColumnSeries<_UserBarData, String>>[
                    ColumnSeries<_UserBarData, String>(
                      dataSource: [
                        _UserBarData(
                          label: 'Active',
                          value: widget.status.activeUsers.toDouble(),
                          color: _selectedIndex == -1 || _selectedIndex == 0
                              ? AppColors.green
                              : AppColors.green.withValues(alpha: .4),
                        ),
                        _UserBarData(
                          label: 'Inactive',
                          value: widget.status.inactiveUsers.toDouble(),
                          color: _selectedIndex == -1 || _selectedIndex == 1
                              ? AppColors.red
                              : AppColors.red.withValues(alpha: .4),
                        ),
                      ],
                      xValueMapper: (d, _) => d.label,
                      yValueMapper: (d, _) => d.value,
                      pointColorMapper: (d, _) => d.color,
                      width: 0.45,
                      borderRadius: BorderRadius.circular(8),
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        textStyle: AppStyles.lightTextStyle(context).copyWith(
                          fontSize: 12.sp,
                        ),
                      ),
                      onPointTap: (details) {
                        final idx = details.pointIndex ?? -1;
                        if (idx < 0) return;
                        setState(() {
                          _selectedIndex = _selectedIndex == idx ? -1 : idx;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserBarData {
  final String label;
  final double value;
  final Color color;

  _UserBarData({
    required this.label,
    required this.value,
    required this.color,
  });
}
