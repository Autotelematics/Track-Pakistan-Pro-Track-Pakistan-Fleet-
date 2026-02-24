import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/single_vehicle_analytics_provider.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/widgets/single_vehicle_analytics_widgets/analytics_charts.dart';
import 'package:trackerapp/widgets/single_vehicle_analytics_widgets/analytics_filter_bar.dart';
import 'package:trackerapp/widgets/single_vehicle_analytics_widgets/analytics_mode_badge.dart';
import 'package:trackerapp/widgets/single_vehicle_analytics_widgets/analytics_stat_cards.dart';

class SingleVehicleAnalyticsScreen extends StatefulWidget {
  final int deviceId;
  const SingleVehicleAnalyticsScreen({super.key, required this.deviceId});

  @override
  State<SingleVehicleAnalyticsScreen> createState() =>
      _SingleVehicleAnalyticsScreenState();
}

class _SingleVehicleAnalyticsScreenState
    extends State<SingleVehicleAnalyticsScreen> {
  String selectedFilter = "Today";
  DateTime? customStartDate;
  DateTime? customEndDate;
  TimeOfDay? customStartTime;
  TimeOfDay? customEndTime;

  final _dateFormatApi = DateFormat("yyyy-MM-dd");
  final _timeFormat = DateFormat("HH:mm");
  late String _fromDate, _toDate, _fromTime, _toTime;
  late final TooltipBehavior _speedTooltip;
  late final TooltipBehavior _distanceTooltip;
  late final TooltipBehavior _fuelTooltip;
  late final TooltipBehavior _stopTooltip;
  late final TooltipBehavior _engineTooltip;

  @override
  void initState() {
    super.initState();
    _speedTooltip    = _makeTooltip();
    _distanceTooltip = _makeTooltip();
    _fuelTooltip     = _makeTooltip();
    _stopTooltip     = _makeTooltip();
    _engineTooltip   = _makeTooltip();

    final now = DateTime.now();
    _fromDate = _toDate = _dateFormatApi.format(now);
    _fromTime = "00:00";
    _toTime   = _timeFormat.format(now);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }
  TooltipBehavior _makeTooltip() => TooltipBehavior(
    enable: true,
    activationMode: ActivationMode.singleTap,
    shouldAlwaysShow: false,
    duration: 3000,
    animationDuration: 200,
    color: Colors.black87,
    borderColor: Colors.white,
    borderWidth: 1.5,
    opacity: 0.92,
    textStyle: TextStyle(
      color: Colors.white,
      fontSize: 13.sp,
      fontWeight: FontWeight.w600,
    ),
    format: 'point.x : point.y',
    header: '',
    decimalPlaces: 2,
    canShowMarker: true,
  );

  void _fetch() {
    context.read<SingleVehicleAnalyticsProvider>().fetchAnalytics(
      deviceId: widget.deviceId.toString(),
      fromDate: _fromDate,
      fromTime: _fromTime,
      toDate: _toDate,
      toTime: _toTime,
    );
  }
  void _applyFilter(String filter) {
    setState(() => selectedFilter = filter);
    if (filter == "Custom") return;

    final now = DateTime.now();
    switch (filter) {
      case "Today":
        _fromDate = _toDate = _dateFormatApi.format(now);
        _fromTime = "00:00";
        _toTime   = _timeFormat.format(now);
        break;
      case "Yesterday":
        final y = now.subtract(const Duration(days: 1));
        _fromDate = _toDate = _dateFormatApi.format(y);
        _fromTime = "00:00";
        _toTime   = "23:59";
        break;
      case "Last 3 Days":
        _fromDate = _dateFormatApi.format(now.subtract(const Duration(days: 2)));
        _toDate   = _dateFormatApi.format(now);
        _fromTime = "00:00";
        _toTime   = _timeFormat.format(now);
        break;
      case "Last 7 Days":
        _fromDate = _dateFormatApi.format(now.subtract(const Duration(days: 6)));
        _toDate   = _dateFormatApi.format(now);
        _fromTime = "00:00";
        _toTime   = _timeFormat.format(now);
        break;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  Future<DateTime?> _pickDate(DateTime? initial) => showDatePicker(
    context: context,
    initialDate: initial ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    builder: (context, child) => Theme(
      data: Theme.of(context).copyWith(
          colorScheme:
          ColorScheme.light(primary: ConstantColor.primaryColor)),
      child: child!,
    ),
  );

  Future<TimeOfDay?> _pickTime(TimeOfDay? initial) => showTimePicker(
    context: context,
    initialTime: initial ?? TimeOfDay.now(),
    builder: (context, child) => Theme(
      data: Theme.of(context).copyWith(
          colorScheme:
          ColorScheme.light(primary: ConstantColor.primaryColor)),
      child: child!,
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Consumer<SingleVehicleAnalyticsProvider>(
        builder: (context, provider, _) {
          final isMultiDay = provider.groupMode == AnalyticsGroupMode.daily;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 7.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verticalSpace(height: 2.h),

                    // Filter bar
                    AnalyticsFilterBar(
                      fromDate: _fromDate,
                      toDate: _toDate,
                      selectedFilter: selectedFilter,
                      onFilterSelected: _applyFilter,
                      customStartDate: customStartDate,
                      customEndDate: customEndDate,
                      customStartTime: customStartTime,
                      customEndTime: customEndTime,
                      onStartDateTap: () async {
                        final d = await _pickDate(customStartDate);
                        if (d != null) {
                          setState(() {
                            customStartDate = d;
                            _fromDate = _dateFormatApi.format(d);
                          });
                        }
                      },
                      onEndDateTap: () async {
                        final d = await _pickDate(customEndDate);
                        if (d != null) {
                          setState(() {
                            customEndDate = d;
                            _toDate = _dateFormatApi.format(d);
                          });
                        }
                      },
                      onStartTimeTap: () async {
                        final t = await _pickTime(customStartTime);
                        if (t != null) {
                          setState(() {
                            customStartTime = t;
                            _fromTime =
                            "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
                          });
                        }
                      },
                      onEndTimeTap: () async {
                        final t = await _pickTime(customEndTime);
                        if (t != null) {
                          setState(() {
                            customEndTime = t;
                            _toTime =
                            "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
                          });
                          if (customStartDate != null &&
                              customEndDate != null &&
                              customStartTime != null) {
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) => _fetch());
                          }
                        }
                      },
                    ),

                    verticalSpace(height: 2.h),

                    if (!provider.isLoading &&
                        provider.errorMessage == null) ...[
                      // Stat cards
                      AnalyticsStatCards(provider: provider),
                      verticalSpace(height: 2.h),

                      // Mode badge
                      AnalyticsModeBadge(isMultiDay: isMultiDay),
                      verticalSpace(height: 1.5.h),

                      // Charts
                      AnalyticsSpeedChart(
                        provider: provider,
                        isMultiDay: isMultiDay,
                        tooltip: _speedTooltip,
                      ),
                      verticalSpace(height: 2.h),

                      AnalyticsDistanceChart(
                        provider: provider,
                        isMultiDay: isMultiDay,
                        tooltip: _distanceTooltip,
                      ),
                      verticalSpace(height: 2.h),
                      if (!isMultiDay) ...[
                        AnalyticsFuelChart(
                          provider: provider,
                          tooltip: _fuelTooltip,
                        ),
                        verticalSpace(height: 2.h),
                      ],

                      AnalyticsStopDurationChart(
                        provider: provider,
                        tooltip: _stopTooltip,
                      ),
                      verticalSpace(height: 2.h),

                      AnalyticsEngineHoursChart(
                        provider: provider,
                        isMultiDay: isMultiDay,
                        tooltip: _engineTooltip,
                      ),
                      verticalSpace(height: 2.h),
                    ],
                  ],
                ),
              ),
              if (provider.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.25),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12.sp),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                              color: ConstantColor.primaryColor),
                          verticalSpace(height: 2.h),
                          Text(
                            'Loading analytics...',
                            style: AppStyles.semiboldTextStyle(context)
                                .copyWith(fontSize: 16.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              if (provider.errorMessage != null && !provider.isLoading)
                Positioned(
                  top: 12.h,
                  left: 4.w,
                  right: 4.w,
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppColors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12.sp),
                    ),
                    child: Text(
                      provider.errorMessage!,
                      style: AppStyles.semiboldTextStyle(context).copyWith(
                          color: AppColors.white, fontSize: 14.sp),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}