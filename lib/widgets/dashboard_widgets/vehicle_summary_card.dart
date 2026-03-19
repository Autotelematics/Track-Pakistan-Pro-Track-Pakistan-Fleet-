import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_dashboard_model.dart';
import 'package:trackerapp/providers/dashboard_provider.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class VehicleSummaryCard extends StatefulWidget {
  final GetDashboardModel data1;

  const VehicleSummaryCard({super.key, required this.data1});

  @override
  State<VehicleSummaryCard> createState() => _VehicleSummaryCardState();
}

class _VehicleSummaryCardState extends State<VehicleSummaryCard>
    with TickerProviderStateMixin {
  AnimationController? _entryController;
  AnimationController? _introExplodeController;
  Animation<double> _chartScale = const AlwaysStoppedAnimation<double>(1.0);
  Animation<double> _chartOpacity = const AlwaysStoppedAnimation<double>(1.0);
  Animation<double> _introExplodeOffset =
      const AlwaysStoppedAnimation<double>(0.0);
  bool _introExplodeDone = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _chartScale = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _entryController!, curve: Curves.easeOutBack),
    );
    _chartOpacity = CurvedAnimation(
      parent: _entryController!,
      curve: Curves.easeOut,
    );
    _entryController!.forward();

    _introExplodeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 980),
    );
    _introExplodeOffset = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 14).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 58,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 14, end: 0).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        ),
        weight: 42,
      ),
    ]).animate(_introExplodeController!);
    _introExplodeController!.forward().whenComplete(() {
      if (!mounted) return;
      setState(() => _introExplodeDone = true);
    });
  }

  @override
  void dispose() {
    _entryController?.dispose();
    _introExplodeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 335;
        final chartSize = isCompact ? 17.h : 16.2.h;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 0.5.h, // smaller vertical padding
          ),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.6)
                    : Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              if (isDark)
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 16,
                ),
            ],
          ),
          child: isCompact
              ? Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: double.infinity,
                        child: _buildLegend(context),
                      ),
                    ),
                    verticalSpace(height: 1.2.h),
                    _buildPieChart(context, size: chartSize),
                  ],
                )
              : Row(
                  children: [
                    SizedBox(
                      width: 43.w,
                      child: _buildLegend(context),
                    ),
                    SizedBox(width: 1.w),
                    _buildPieChart(context, size: chartSize),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildLegend(BuildContext context) {
    final status = widget.data1.statusCounts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // verticalSpace(height: .0.h),
        _legendItem(AppColors.red, "Stopped", status.ack, 0, context),
        verticalSpace(height: 1.h),
        _legendItem(AppColors.green, "Running", status.online, 1, context),
        verticalSpace(height: 1.h),
        _legendItem(AppColors.yellow, "Idle", status.idle, 2, context),
        verticalSpace(height: 1.h),
        _legendItem(AppColors.blueCyan, "Offline", status.offline, 3, context),
      ],
    );
  }

  Widget _legendItem(
    Color color,
    String label,
    int count,
    int index,
    BuildContext context,
  ) {
    final provider = context.read<DashboardProvider>();

    return GestureDetector(
      onTap: () {
        provider.setSelectedStatusIndex(
          provider.selectedStatusIndex == index ? -1 : index,
        );
      },
      child: Row(
        children: [
          Container(
            height: 2.2.h,
            width: 2.2.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          horizontalSpace(width: 2.w),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "$label   ",
                    style: AppStyles.lightTextStyle(context).copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500, // lighter label
                    ),
                  ),
                  TextSpan(
                    text: "$count",
                    style: AppStyles.boldTextStyle(context).copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800, // stronger count
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, {required double size}) {
    final status = widget.data1.statusCounts;

    return FadeTransition(
      opacity: _chartOpacity,
      child: ScaleTransition(
        scale: _chartScale,
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 25,
                spreadRadius: 3,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Consumer<DashboardProvider>(
            builder: (context, provider, child) {
              final selectedIndex = provider.selectedStatusIndex;
              final isIntroActive = !_introExplodeDone;

              final (centerLabel, centerCount) = switch (selectedIndex) {
                0 => ('Stopped', status.ack),
                1 => ('Running', status.online),
                2 => ('Idle', status.idle),
                3 => ('Offline', status.offline),
                _ => ('Total', status.total),
              };

              if (isIntroActive) {
                return AnimatedBuilder(
                  animation: _introExplodeOffset,
                  builder: (context, _) {
                    return _buildChart(
                      context: context,
                      status: status,
                      centerLabel: centerLabel,
                      centerCount: centerCount,
                      explodeOffset: _introExplodeOffset.value,
                      explode: true,
                      explodeAll: true,
                      explodeIndex: 0,
                      provider: provider,
                    );
                  },
                );
              }

              return TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 360),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(end: selectedIndex == -1 ? 0.0 : 14.0),
                builder: (context, explodeOffset, _) {
                  return _buildChart(
                    context: context,
                    status: status,
                    centerLabel: centerLabel,
                    centerCount: centerCount,
                    explodeOffset: explodeOffset,
                    explode: selectedIndex != -1,
                    explodeAll: false,
                    explodeIndex: selectedIndex == -1 ? 0 : selectedIndex,
                    provider: provider,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChart({
    required BuildContext context,
    required dynamic status,
    required String centerLabel,
    required int centerCount,
    required double explodeOffset,
    required bool explode,
    required bool explodeAll,
    required int explodeIndex,
    required DashboardProvider provider,
  }) {
    return SfCircularChart(
      legend: const Legend(isVisible: false),
      series: <DoughnutSeries<ChartData, String>>[
        DoughnutSeries<ChartData, String>(
          dataSource: _getChartData(status),
          xValueMapper: (d, _) => d.x,
          yValueMapper: (d, _) => d.y,
          pointColorMapper: (d, _) => d.color,
          innerRadius: '55%',
          radius: '100%',
          animationDuration: 0,
          explode: explode,
          explodeAll: explodeAll,
          explodeIndex: explodeIndex,
          explodeOffset: '${explodeOffset.toStringAsFixed(1)}%',
          strokeWidth: 1.5,
          strokeColor:
              const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.1),
          onPointTap: (details) {
            final index = details.pointIndex ?? -1;
            if (index == -1) return;

            provider.setSelectedStatusIndex(
              provider.selectedStatusIndex == index ? -1 : index,
            );
          },
          dataLabelSettings: const DataLabelSettings(isVisible: false),
        ),
      ],
      annotations: <CircularChartAnnotation>[
        CircularChartAnnotation(
          widget: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$centerCount',
                style: AppStyles.boldTextStyle(context).copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 0.0.h),
              Text(
                centerLabel,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<ChartData> _getChartData(dynamic status) {
    return [
      ChartData('Stopped', status.ack.toDouble(), AppColors.red, 0),
      ChartData('Running', status.online.toDouble(), AppColors.green, 1),
      ChartData('Idle', status.idle.toDouble(), AppColors.yellow, 2),
      ChartData('Offline', status.offline.toDouble(), AppColors.blueCyan, 3),
    ];
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color, this.index);

  final String x;
  final double y;
  final Color color;
  final int index;
}
