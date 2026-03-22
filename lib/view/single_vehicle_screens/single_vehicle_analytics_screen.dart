import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/single_vehicle_analytics_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/widgets/single_vehicle_analytics_widgets/analytics_charts.dart';
import 'package:trackerapp/widgets/single_vehicle_analytics_widgets/analytics_filter_bar.dart';
import 'package:trackerapp/widgets/single_vehicle_analytics_widgets/analytics_mode_badge.dart';
import 'package:trackerapp/widgets/single_vehicle_analytics_widgets/analytics_scale.dart';
import 'package:trackerapp/widgets/single_vehicle_analytics_widgets/analytics_stat_cards.dart';
import 'package:trackerapp/widgets/single_vehicle_analytics_widgets/single_vehicle_expense_analytics_card.dart';
import 'package:trackerapp/widgets/single_vehicle_analytics_widgets/single_vehicle_maintenance_analytics_card.dart';
import 'package:trackerapp/widgets/single_vehicle_analytics_widgets/single_vehicle_tasks_analytics_card.dart';

class SingleVehicleAnalyticsScreen extends StatefulWidget {
  final int deviceId;
  final String vehicleName;
  const SingleVehicleAnalyticsScreen({
    super.key,
    required this.deviceId,
    required this.vehicleName,
  });

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
  late String _fromDate, _toDate, _fromTime, _toTime;
  late final TooltipBehavior _speedTooltip;
  late final TooltipBehavior _distanceTooltip;
  late final TooltipBehavior _fuelTooltip;
  late final TooltipBehavior _stopTooltip;
  late final TooltipBehavior _engineTooltip;
  bool _didAutoRetryTodayFetch = false;
  bool _showDateRangePicker = false;

  String _filterLabel(BuildContext context, String value) {
    final l10n = context.l10n;
    switch (value) {
      case "Today":
        return l10n.today;
      case "Yesterday":
        return l10n.yesterday;
      case "Last 3 Days":
        return l10n.last3Days;
      case "Last 7 Days":
        return l10n.last7Days;
      case "Custom":
        return l10n.custom;
      default:
        return value;
    }
  }

  @override
  void initState() {
    super.initState();
    _speedTooltip = _makeTooltip();
    _distanceTooltip = _makeTooltip();
    _fuelTooltip = _makeTooltip();
    _stopTooltip = _makeTooltip();
    _engineTooltip = _makeTooltip();

    final now = DateTime.now();
    _fromDate = _toDate = _dateFormatApi.format(now);
    _fromTime = "00:00";
    _toTime = "23:59";
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
    setState(() {
      selectedFilter = filter;
      _showDateRangePicker = filter == "Custom";
    });
    if (filter == "Custom") {
      return;
    }

    final now = DateTime.now();
    switch (filter) {
      case "Today":
        _fromDate = _toDate = _dateFormatApi.format(now);
        _fromTime = "00:00";
        _toTime = "23:59";
        break;
      case "Yesterday":
        final y = now.subtract(const Duration(days: 1));
        _fromDate = _toDate = _dateFormatApi.format(y);
        _fromTime = "00:00";
        _toTime = "23:59";
        break;
      case "Last 3 Days":
        _fromDate =
            _dateFormatApi.format(now.subtract(const Duration(days: 2)));
        _toDate = _dateFormatApi.format(now);
        _fromTime = "00:00";
        _toTime = "23:59";
        break;
      case "Last 7 Days":
        _fromDate =
            _dateFormatApi.format(now.subtract(const Duration(days: 6)));
        _toDate = _dateFormatApi.format(now);
        _fromTime = "00:00";
        _toTime = "23:59";
        break;
    }
    _didAutoRetryTodayFetch = false;
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isCustomDateRangeValid(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    return !_dateOnly(start).isAfter(_dateOnly(end));
  }

  Future<DateTime?> _pickDate(
    DateTime? initial, {
    DateTime? minDate,
    DateTime? maxDate,
  }) async {
    final today = _dateOnly(DateTime.now());
    final minimum = _dateOnly(minDate ?? DateTime(2020));
    final maximum = _dateOnly(maxDate ?? today);
    DateTime tempDate = _dateOnly(initial ?? maximum);
    if (tempDate.isBefore(minimum)) tempDate = minimum;
    if (tempDate.isAfter(maximum)) tempDate = maximum;

    final result = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final l10n = ctx.l10n;
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          height: 36.h,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2433) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 1.h, bottom: .6.h),
                width: 10.w,
                height: .45.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l10n.cancel),
                    ),
                    const Spacer(),
                    Text(
                      l10n.selectDate,
                      style: AppStyles.semiboldTextStyle(ctx)
                          .copyWith(fontSize: 14.sp),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, tempDate),
                      child: Text(
                        l10n.done,
                        style: TextStyle(color: ConstantColor.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tempDate,
                  minimumDate: minimum,
                  maximumDate: maximum,
                  onDateTimeChanged: (value) => tempDate = value,
                ),
              ),
            ],
          ),
        );
      },
    );

    return result;
  }

  Future<TimeOfDay?> _pickTime(TimeOfDay? initial) async {
    final now = DateTime.now();
    DateTime tempTime = DateTime(
      now.year,
      now.month,
      now.day,
      initial?.hour ?? now.hour,
      initial?.minute ?? now.minute,
    );

    final result = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final l10n = ctx.l10n;
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          height: 34.h,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2433) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 1.h, bottom: .6.h),
                width: 10.w,
                height: .45.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l10n.cancel),
                    ),
                    const Spacer(),
                    Text(
                      l10n.selectTime,
                      style: AppStyles.semiboldTextStyle(ctx)
                          .copyWith(fontSize: 14.sp),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, tempTime),
                      child: Text(
                        l10n.done,
                        style: TextStyle(color: ConstantColor.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: tempTime,
                  use24hFormat: true,
                  onDateTimeChanged: (value) => tempTime = value,
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result == null) return null;
    return TimeOfDay(hour: result.hour, minute: result.minute);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textScale = analyticsTextScale(context);
    final iconScale = analyticsIconScale(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF0E1624) : AppColors.white;

    return Scaffold(
      backgroundColor: surfaceColor,
      body: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: IconTheme(
          data: IconTheme.of(context).copyWith(size: 24 * iconScale),
          child: Consumer<SingleVehicleAnalyticsProvider>(
            builder: (context, provider, _) {
              final isMultiDay = provider.groupMode == AnalyticsGroupMode.daily;
              final hasNoChartData = provider.speedChartData.isEmpty &&
                  provider.distanceChartData.isEmpty &&
                  provider.stopDurationChartData.isEmpty &&
                  provider.engineHoursChartData.isEmpty;
              final hasVisibleCharts = provider.speedChartData.isNotEmpty ||
                  provider.distanceChartData.isNotEmpty ||
                  (!isMultiDay && provider.fuelChartData.isNotEmpty) ||
                  provider.stopDurationChartData.isNotEmpty ||
                  provider.engineHoursChartData.isNotEmpty;

              if (!provider.isLoading &&
                  provider.errorMessage == null &&
                  hasNoChartData &&
                  selectedFilter == "Today" &&
                  !_didAutoRetryTodayFetch) {
                _didAutoRetryTodayFetch = true;
                WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
              }

              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(4.w, 5.2.h, 4.w, 3.0.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filter bar
                        AnalyticsFilterBar(
                          fromDate: _fromDate,
                          toDate: _toDate,
                          selectedFilter: selectedFilter,
                          onFilterSelected: _applyFilter,
                          showDateRangePicker: _showDateRangePicker,
                          onDateRangeTap: () {
                            setState(() {
                              selectedFilter = "Custom";
                              _showDateRangePicker = true;
                            });
                          },
                          onCloseDateRange: () {
                            setState(() {
                              _showDateRangePicker = false;
                            });
                          },
                          customStartDate: customStartDate,
                          customEndDate: customEndDate,
                          customStartTime: customStartTime,
                          customEndTime: customEndTime,
                          onStartDateTap: () async {
                            final d = await _pickDate(
                              customStartDate,
                              maxDate: customEndDate ?? DateTime.now(),
                            );
                            if (d != null) {
                              final normalized = _dateOnly(d);
                              setState(() {
                                selectedFilter = "Custom";
                                _showDateRangePicker = true;
                                customStartDate = normalized;
                                _fromDate = _dateFormatApi.format(normalized);
                              });
                            }
                          },
                          onEndDateTap: () async {
                            final d = await _pickDate(
                              customEndDate,
                              minDate: customStartDate ?? DateTime(2020),
                              maxDate: DateTime.now(),
                            );
                            if (d != null) {
                              final normalized = _dateOnly(d);
                              setState(() {
                                selectedFilter = "Custom";
                                _showDateRangePicker = true;
                                customEndDate = normalized;
                                _toDate = _dateFormatApi.format(normalized);
                              });
                            }
                          },
                          onStartTimeTap: () async {
                            final t = await _pickTime(customStartTime);
                            if (t != null) {
                              setState(() {
                                selectedFilter = "Custom";
                                _showDateRangePicker = true;
                                customStartTime = t;
                                _fromTime =
                                    "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
                              });
                            }
                          },
                          onEndTimeTap: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final t = await _pickTime(customEndTime);
                            if (t != null) {
                              setState(() {
                                selectedFilter = "Custom";
                                _showDateRangePicker = true;
                                customEndTime = t;
                                _toTime =
                                    "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
                              });
                              if (customStartDate != null &&
                                  customEndDate != null &&
                                  customStartTime != null &&
                                  _isCustomDateRangeValid(
                                      customStartDate, customEndDate)) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) => _fetch());
                              } else if (customStartDate != null &&
                                  customEndDate != null &&
                                  !_isCustomDateRangeValid(
                                      customStartDate, customEndDate)) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.fromDateCannotBeLaterThanToDate,
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        verticalSpace(height: 1.h),
                        _AnalyticsHeroCard(
                          fromDate: _fromDate,
                          toDate: _toDate,
                          selectedFilter: selectedFilter,
                          selectedFilterLabel:
                              _filterLabel(context, selectedFilter),
                          isMultiDay: isMultiDay,
                        ),

                        verticalSpace(height: 1.h),

                        if (!provider.isLoading &&
                            provider.errorMessage == null) ...[
                          Text(
                            l10n.overview,
                            style:
                                AppStyles.semiboldTextStyle(context).copyWith(
                              fontSize: 15.4.sp,
                              color: isDark
                                  ? AppColors.white
                                  : AppColors.textBlack,
                            ),
                          ),
                          verticalSpace(height: 1.h),
                          // Stat cards
                          AnalyticsStatCards(provider: provider),
                          verticalSpace(height: 1.h),
                          SingleVehicleMaintenanceAnalyticsCard(
                            deviceId: widget.deviceId,
                            vehicleName: widget.vehicleName,
                          ),
                          verticalSpace(height: 1.h),
                          SingleVehicleTasksAnalyticsCard(
                            deviceId: widget.deviceId,
                            vehicleName: widget.vehicleName,
                          ),
                          verticalSpace(height: 1.h),

                          if (hasVisibleCharts) ...[
                            // Mode badge
                            AnalyticsModeBadge(isMultiDay: isMultiDay),
                            verticalSpace(height: 1.h),
                          ],

                          // Charts
                          if (provider.speedChartData.isNotEmpty) ...[
                            AnalyticsSpeedChart(
                              provider: provider,
                              isMultiDay: isMultiDay,
                              tooltip: _speedTooltip,
                            ),
                            verticalSpace(height: 1.h),
                          ],
                          if (provider.distanceChartData.isNotEmpty) ...[
                            AnalyticsDistanceChart(
                              provider: provider,
                              isMultiDay: isMultiDay,
                              tooltip: _distanceTooltip,
                            ),
                            verticalSpace(height: 1.h),
                          ],
                          if (!isMultiDay && provider.fuelChartData.isNotEmpty) ...[
                            AnalyticsFuelChart(
                              provider: provider,
                              tooltip: _fuelTooltip,
                            ),
                            verticalSpace(height: 1.h),
                          ],
                          if (provider.stopDurationChartData.isNotEmpty) ...[
                            AnalyticsStopDurationChart(
                              provider: provider,
                              tooltip: _stopTooltip,
                            ),
                            verticalSpace(height: 1.h),
                          ],
                          if (provider.engineHoursChartData.isNotEmpty) ...[
                            AnalyticsEngineHoursChart(
                              provider: provider,
                              isMultiDay: isMultiDay,
                              tooltip: _engineTooltip,
                            ),
                            verticalSpace(height: 1.h),
                          ],
                          SingleVehicleExpenseAnalyticsCard(
                            deviceId: widget.deviceId,
                            vehicleName: widget.vehicleName,
                          ),
                          verticalSpace(height: 1.h),
                        ],
                      ],
                    ),
                  ),
                  if (provider.isLoading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.25),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1B2638)
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(14.sp),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                  color: ConstantColor.primaryColor),
                              verticalSpace(height: 2.h),
                              Text(
                                l10n.loadingAnalytics,
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
                      top: 10.h,
                      left: 4.w,
                      right: 4.w,
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.92),
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
        ),
      ),
    );
  }
}

class _AnalyticsHeroCard extends StatelessWidget {
  final String fromDate;
  final String toDate;
  final String selectedFilter;
  final String selectedFilterLabel;
  final bool isMultiDay;

  const _AnalyticsHeroCard({
    required this.fromDate,
    required this.toDate,
    required this.selectedFilter,
    required this.selectedFilterLabel,
    required this.isMultiDay,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateText = "$fromDate  to  $toDate";

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.05.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A2A44), const Color(0xFF121E31)]
              : [
                  ConstantColor.primaryColor.withValues(alpha: .93),
                  AppColors.blueCyan.withValues(alpha: .92),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .25 : .14),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 9.2.w,
            height: 4.4.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(10.sp),
            ),
            child:
                Icon(Icons.analytics_rounded, color: Colors.white, size: 17.sp),
          ),
          SizedBox(width: 2.2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.vehicleAnalytics,
                  style: AppStyles.boldTextStyle(context).copyWith(
                    color: Colors.white,
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: .08.h),
                Text(
                  dateText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.regularTextStyle(context).copyWith(
                    color: Colors.white.withValues(alpha: .9),
                    fontSize: 11.2.sp,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.0.w, vertical: .35.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(16.sp),
              border: Border.all(color: Colors.white.withValues(alpha: .28)),
            ),
            child: Text(
              isMultiDay ? l10n.daily : selectedFilterLabel,
              style: AppStyles.semiboldTextStyle(context).copyWith(
                color: Colors.white,
                fontSize: 10.7.sp,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
