import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/admin_status_model.dart';

class AdminStatusCountCard extends StatefulWidget {
  final AdminDeviceStatus status;

  const AdminStatusCountCard({
    super.key,
    required this.status,
  });

  @override
  State<AdminStatusCountCard> createState() => _AdminStatusCountCardState();
}

class _AdminStatusCountCardState extends State<AdminStatusCountCard>
    with TickerProviderStateMixin {
  AnimationController? _entryController;
  AnimationController? _introExplodeController;
  Animation<double> _chartScale = const AlwaysStoppedAnimation<double>(1.0);
  Animation<double> _chartOpacity = const AlwaysStoppedAnimation<double>(1.0);
  Animation<double> _introExplodeOffset =
      const AlwaysStoppedAnimation<double>(0.0);
  bool _introExplodeDone = false;

  int _selectedStatusIndex = -1;

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

  void _toggleStatusIndex(int index) {
    setState(() {
      _selectedStatusIndex = _selectedStatusIndex == index ? -1 : index;
    });
  }

  (String, int) _centerInfo(AdminDeviceStatus status) {
    switch (_selectedStatusIndex) {
      case 0:
        return ('Stopped', status.ack);
      case 1:
        return ('Running', status.online);
      case 2:
        return ('Idle', status.idle);
      case 3:
        return ('Offline', status.offline);
      case 4:
        return ('Expired', status.expired);
      case 5:
        return ('Never Connected', status.neverConnected);
      default:
        return ('Total', status.totalCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = MediaQuery.of(context).size.width < 350;

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
      child: isCompact
          ? Column(
              children: [
                _buildLegend(context),
                SizedBox(height: 1.2.h),
                _buildChart(context),
              ],
            )
          : Row(
              children: [
                Expanded(child: _buildLegend(context)),
                SizedBox(width: 2.w),
                _buildChart(context),
              ],
            ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final status = widget.status;
    return Column(
      children: [
        _legendItem(context, "Stopped", status.ack, AppColors.red, 0),
        SizedBox(height: .8.h),
        _legendItem(context, "Running", status.online, AppColors.green, 1),
        SizedBox(height: .8.h),
        _legendItem(context, "Idle", status.idle, AppColors.yellow, 2),
        SizedBox(height: .8.h),
        _legendItem(context, "Offline", status.offline, AppColors.blueCyan, 3),
        SizedBox(height: .8.h),
        _legendItem(context, "Expired", status.expired, Colors.deepOrange, 4),
        SizedBox(height: .8.h),
        _legendItem(
          context,
          "Never Connected",
          status.neverConnected,
          Colors.grey,
          5,
        ),
      ],
    );
  }

  Widget _legendItem(
    BuildContext context,
    String label,
    int count,
    Color color,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _toggleStatusIndex(index),
      child: Row(
        children: [
          Container(
            width: 1.9.h,
            height: 1.9.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          SizedBox(width: 2.2.w),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "$label  ",
                    style: AppStyles.lightTextStyle(context).copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: "$count",
                    style: AppStyles.semiboldTextStyle(context).copyWith(
                      fontSize: 14.sp,
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

  Widget _buildChart(BuildContext context) {
    final status = widget.status;
    final (centerLabel, centerCount) = _centerInfo(status);
    final isIntroActive = !_introExplodeDone;

    return FadeTransition(
      opacity: _chartOpacity,
      child: ScaleTransition(
        scale: _chartScale,
        child: Container(
          width: 16.5.h,
          height: 16.5.h,
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
          child: isIntroActive
              ? AnimatedBuilder(
                  animation: _introExplodeOffset,
                  builder: (context, _) {
                    return _buildCircularChart(
                      context: context,
                      centerLabel: centerLabel,
                      centerCount: centerCount,
                      explodeOffset: _introExplodeOffset.value,
                      explode: true,
                      explodeAll: true,
                      explodeIndex: 0,
                    );
                  },
                )
              : TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 360),
                  curve: Curves.easeOutCubic,
                  tween: Tween<double>(
                    end: _selectedStatusIndex == -1 ? 0.0 : 14.0,
                  ),
                  builder: (context, explodeOffset, _) {
                    return _buildCircularChart(
                      context: context,
                      centerLabel: centerLabel,
                      centerCount: centerCount,
                      explodeOffset: explodeOffset,
                      explode: _selectedStatusIndex != -1,
                      explodeAll: false,
                      explodeIndex:
                          _selectedStatusIndex == -1 ? 0 : _selectedStatusIndex,
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildCircularChart({
    required BuildContext context,
    required String centerLabel,
    required int centerCount,
    required double explodeOffset,
    required bool explode,
    required bool explodeAll,
    required int explodeIndex,
  }) {
    final status = widget.status;

    return SfCircularChart(
      legend: const Legend(isVisible: false),
      series: <DoughnutSeries<_ChartData, String>>[
        DoughnutSeries<_ChartData, String>(
          dataSource: [
            _ChartData('Stopped', status.ack.toDouble(), AppColors.red),
            _ChartData('Running', status.online.toDouble(), AppColors.green),
            _ChartData('Idle', status.idle.toDouble(), AppColors.yellow),
            _ChartData(
                'Offline', status.offline.toDouble(), AppColors.blueCyan),
            _ChartData('Expired', status.expired.toDouble(), Colors.deepOrange),
            _ChartData(
              'Never Connected',
              status.neverConnected.toDouble(),
              Colors.grey,
            ),
          ],
          xValueMapper: (d, _) => d.label,
          yValueMapper: (d, _) => d.value,
          pointColorMapper: (d, _) => d.color,
          innerRadius: '58%',
          radius: '100%',
          animationDuration: 0,
          explode: explode,
          explodeAll: explodeAll,
          explodeIndex: explodeIndex,
          explodeOffset: '${explodeOffset.toStringAsFixed(1)}%',
          strokeWidth: 1.4,
          strokeColor: Colors.black.withValues(alpha: .08),
          onPointTap: (details) {
            final index = details.pointIndex ?? -1;
            if (index < 0) return;
            _toggleStatusIndex(index);
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
                ),
              ),
              Text(
                centerLabel,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartData {
  final String label;
  final double value;
  final Color color;

  _ChartData(this.label, this.value, this.color);
}
