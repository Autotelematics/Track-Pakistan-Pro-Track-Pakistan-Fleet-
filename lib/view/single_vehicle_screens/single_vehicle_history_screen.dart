import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/app/theme/responsive_scale.dart';
import 'package:trackerapp/providers/get_device_history_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/widgets/single_vehicle_common/single_vehicle_date_filter_widgets.dart';
import 'package:trackerapp/widgets/single_vehicle_history_widget/history_bottom_sheet.dart';

class SingleVehicleHistoryScreen extends StatefulWidget {
  final int deviceId;
  final String deviceTitle;
  final LatLng?
      initialLivePosition; // live tracking se current location pass karne ke liye
  final String? initialLiveStatus;
  final DateTime? initialFromDateTime;
  final DateTime? initialToDateTime;
  final String? initialKmPerLiter;
  final String? initialEngineType;

  const SingleVehicleHistoryScreen({
    super.key,
    required this.deviceId,
    required this.deviceTitle,
    this.initialLivePosition,
    this.initialLiveStatus,
    this.initialFromDateTime,
    this.initialToDateTime,
    this.initialKmPerLiter,
    this.initialEngineType,
  });

  @override
  State<SingleVehicleHistoryScreen> createState() =>
      _SingleVehicleHistoryScreenState();
}

class _SingleVehicleHistoryScreenState extends State<SingleVehicleHistoryScreen>
    with TickerProviderStateMixin {
  static const double _vehicleMarkerLogicalHeight = 30.0;
  static const double _vehicleMarkerRenderScale = 3.0;
  static const double _preferredPlaybackZoom = 15.5;
  static const double _playbackSafeSidePadding = 36.0;
  static const double _playbackSafeTopInset = 120.0;
  static const double _playbackSafeBottomInset = 250.0;
  static String? _darkMapStyle;
  String selectedFilter = ""; // by default koi filter selected nahi
  bool showCustomPicker = false;
  bool _hasFilterApplied = false; // API sirf filter select hone par call hogi

  late String fromDate, toDate;
  String fromTime = "00:00", toTime = "";

  DateTime? customStartDate, customEndDate;
  TimeOfDay? customStartTime, customEndTime;

  final _dateFormatApi = DateFormat("yyyy-MM-dd");
  final _timeFormat = DateFormat("HH:mm");

  GoogleMapController? _mapController;
  final MapType _mapType = MapType.normal;
  Brightness? _appliedMapBrightness;
  String? _googleMapStyle;
  String _lastRouteSignature = '';
  bool _hasFittedHistoryBounds = false;
  bool _wasPlaying = false;
  bool _hasPrimedPlaybackViewport = false;
  DateTime? _lastPlaybackCameraFollowAt;
  BitmapDescriptor? _initialLiveMarkerIcon;
  bool _isDisposing = false;
  bool _followPlaybackCamera = false;
  bool get _isTaskPlaybackMode =>
      widget.initialFromDateTime != null && widget.initialToDateTime != null;

  @override
  void initState() {
    super.initState();

    final DateTime now = DateTime.now();
    final DateTime from =
        widget.initialFromDateTime ?? now.subtract(const Duration(hours: 12));
    final DateTime to = widget.initialToDateTime ?? now;
    fromDate = _dateFormatApi.format(from);
    toDate = _dateFormatApi.format(to);
    fromTime = _timeFormat.format(from);
    toTime = _timeFormat.format(to);

    customStartDate = DateTime(from.year, from.month, from.day);
    customEndDate = DateTime(to.year, to.month, to.day);
    customStartTime = TimeOfDay(hour: from.hour, minute: from.minute);
    customEndTime = TimeOfDay(hour: to.hour, minute: to.minute);

    if (widget.initialFromDateTime != null &&
        widget.initialToDateTime != null) {
      selectedFilter = "Custom";
      _hasFilterApplied = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _fetchHistory();
      });
    }

    unawaited(_loadInitialLiveMarkerIcon());
  }

  String _liveStatusToCarAsset(String? rawStatus) {
    final status = (rawStatus ?? '').toLowerCase().trim();
    if (['running', 'online', 'moving'].contains(status)) {
      return 'assets/images/car_green.png';
    }
    if (['stopped', 'ack', 'parking'].contains(status)) {
      return 'assets/images/car_red.png';
    }
    if (['idle', 'engine'].contains(status)) {
      return 'assets/images/car_yellow.png';
    }
    return 'assets/images/car_blue.png';
  }

  Future<void> _loadInitialLiveMarkerIcon() async {
    if (widget.initialLivePosition == null) return;
    try {
      final ByteData data = await rootBundle
          .load(_liveStatusToCarAsset(widget.initialLiveStatus));
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetHeight:
            (_vehicleMarkerLogicalHeight * 1.22 * _vehicleMarkerRenderScale)
                .round(),
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ByteData? bytes =
          await frame.image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;
      final icon = BitmapDescriptor.bytes(
        bytes.buffer.asUint8List(),
        width: frame.image.width.toDouble() / _vehicleMarkerRenderScale,
        height: frame.image.height.toDouble() / _vehicleMarkerRenderScale,
        imagePixelRatio: _vehicleMarkerRenderScale,
      );
      if (!mounted) return;
      setState(() => _initialLiveMarkerIcon = icon);
    } catch (_) {}
  }

  void _applyQuickFilter(String filter) {
    final now = DateTime.now();
    late String nextFromDate;
    late String nextToDate;
    late String nextFromTime;
    late String nextToTime;

    switch (filter) {
      case "Today":
        nextFromDate = _dateFormatApi.format(now);
        nextToDate = _dateFormatApi.format(now);
        nextFromTime = "00:00";
        nextToTime = _timeFormat.format(now);
        break;
      case "Yesterday":
        final y = now.subtract(const Duration(days: 1));
        nextFromDate = _dateFormatApi.format(y);
        nextToDate = _dateFormatApi.format(y);
        nextFromTime = "00:00";
        nextToTime = "23:59";
        break;
      case "Last 3 Days":
        nextFromDate =
            _dateFormatApi.format(now.subtract(const Duration(days: 2)));
        nextToDate = _dateFormatApi.format(now);
        nextFromTime = "00:00";
        nextToTime = _timeFormat.format(now);
        break;
      case "Last 7 Days":
        nextFromDate =
            _dateFormatApi.format(now.subtract(const Duration(days: 6)));
        nextToDate = _dateFormatApi.format(now);
        nextFromTime = "00:00";
        nextToTime = _timeFormat.format(now);
        break;
      default:
        return;
    }

    setState(() {
      selectedFilter = filter;
      _hasFilterApplied = true;
      showCustomPicker = false;
      fromDate = nextFromDate;
      toDate = nextToDate;
      fromTime = nextFromTime;
      toTime = nextToTime;

      // Keep custom picker values in sync with latest active range.
      customStartDate = DateFormat('yyyy-MM-dd').parse(nextFromDate);
      customEndDate = DateFormat('yyyy-MM-dd').parse(nextToDate);
      customStartTime = TimeOfDay(
        hour: int.parse(nextFromTime.split(':')[0]),
        minute: int.parse(nextFromTime.split(':')[1]),
      );
      customEndTime = TimeOfDay(
        hour: int.parse(nextToTime.split(':')[0]),
        minute: int.parse(nextToTime.split(':')[1]),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchHistory());
  }

  void _fetchHistory() {
    if (fromDate.isEmpty || toDate.isEmpty) return;
    context.read<DeviceHistoryProvider>().fetchDeviceHistory(
          deviceId: widget.deviceId.toString(),
          fromDate: fromDate,
          fromTime: fromTime,
          toDate: toDate,
          toTime: toTime,
          snapToRoad: false,
          fallbackAveragePerLiter: widget.initialKmPerLiter,
          fallbackEngineType: widget.initialEngineType,
        );
  }

  // Left side From/To date par click → custom picker
  void _openCustomPicker() {
    setState(() {
      selectedFilter = "Custom";
      showCustomPicker = true;
    });
  }

  void _toggleCustomPicker() {
    setState(() {
      selectedFilter = "Custom";
      showCustomPicker = !showCustomPicker;
    });
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isDateRangeValid(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    return !_dateOnly(start).isAfter(_dateOnly(end));
  }

  int _selectedQuickFilterIndex() {
    switch (selectedFilter) {
      case "Today":
        return 0;
      case "Yesterday":
        return 1;
      case "Last 3 Days":
        return 2;
      case "Last 7 Days":
        return 3;
      default:
        return 4;
    }
  }

  String _formatPickerDate(DateTime? value) {
    if (value == null) return '';
    return "${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}";
  }

  String _formatPickerTime(TimeOfDay? value) {
    if (value == null) return '';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, value.hour, value.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  String _formatDateDisplay(String apiDate) {
    if (apiDate.isEmpty) return '';
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(apiDate));
    } catch (_) {
      return apiDate;
    }
  }

  String _formatTimeDisplay(String value) {
    if (value.isEmpty) return '';
    try {
      return DateFormat('hh:mm a').format(DateFormat('HH:mm').parse(value));
    } catch (_) {
      try {
        return DateFormat('hh:mm a')
            .format(DateFormat('hh:mm:ss a').parse(value));
      } catch (_) {
        return value;
      }
    }
  }

  void _onDatePicked(DateTime date, bool isStart) {
    final picked = _dateOnly(date);
    final start = customStartDate == null ? null : _dateOnly(customStartDate!);
    final end = customEndDate == null ? null : _dateOnly(customEndDate!);
    if (isStart && end != null && picked.isAfter(end)) return;
    if (!isStart && start != null && picked.isBefore(start)) return;

    setState(() {
      if (isStart) {
        customStartDate = picked;
        fromDate = _dateFormatApi.format(picked);
      } else {
        customEndDate = picked;
        toDate = _dateFormatApi.format(picked);
      }
    });
  }

  void _onTimePicked(TimeOfDay time, bool isStart) {
    final t =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    setState(() {
      if (isStart) {
        customStartTime = time;
        fromTime = t;
      } else {
        customEndTime = time;
        toTime = t;
      }
    });
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

    return showModalBottomSheet<DateTime>(
      context: context,
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
                  use24hFormat: false,
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

  String _routeSignature(DeviceHistoryProvider provider) {
    if (provider.routeList.isEmpty) return 'empty';
    final first = provider.routeList.first;
    final last = provider.routeList.last;
    return '${provider.routeList.length}:${first.lat},${first.lng}:${last.lat},${last.lng}';
  }

  void _syncHistoryCamera(DeviceHistoryProvider provider) {
    if (_mapController == null) return;

    final signature = _routeSignature(provider);
    if (signature != _lastRouteSignature) {
      _lastRouteSignature = signature;
      _hasFittedHistoryBounds = false;
      _hasPrimedPlaybackViewport = false;
      _lastPlaybackCameraFollowAt = null;
    }

    if (_hasFilterApplied &&
        provider.routeList.isNotEmpty &&
        !_hasFittedHistoryBounds) {
      final bounds = provider.calculateBounds();
      if (bounds != null) {
        _hasFittedHistoryBounds = true;
        _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      }
    }

    if (_wasPlaying && !provider.isPlaying) {
      _lastPlaybackCameraFollowAt = null;
    }

    if (!_wasPlaying && provider.isPlaying && provider.routeList.isNotEmpty) {
      if (provider.carLat != 0 && provider.carLng != 0) {
        final pos = LatLng(provider.carLat, provider.carLng);
        if (!_hasPrimedPlaybackViewport) {
          _hasPrimedPlaybackViewport = true;
          unawaited(_animatePlaybackCameraTo(pos,
              zoom: _preferredPlaybackZoom,
              bearing: provider.headingUpMode ? provider.carRotation : 0));
        }
      }
    } else if (provider.isPlaying &&
        provider.routeList.isNotEmpty &&
        provider.carLat != 0 &&
        provider.carLng != 0) {
      final pos = LatLng(provider.carLat, provider.carLng);
      final now = DateTime.now();
      final followIntervalMs = _followPlaybackCamera ? 140 : 110;
      final canMoveCamera = _lastPlaybackCameraFollowAt == null ||
          now.difference(_lastPlaybackCameraFollowAt!).inMilliseconds >=
              followIntervalMs;
      if (canMoveCamera) {
        if (_followPlaybackCamera || provider.headingUpMode) {
          _lastPlaybackCameraFollowAt = now;
          unawaited(_animatePlaybackCameraTo(pos,
              bearing: provider.headingUpMode ? provider.carRotation : 0));
        } else {
          unawaited(() async {
            final shouldRecenter = await _isPlaybackCarOutsideSafeViewport(pos);
            if (!mounted || _isDisposing || !shouldRecenter) return;
            _lastPlaybackCameraFollowAt = DateTime.now();
            await _animatePlaybackCameraTo(pos);
          }());
        }
      }
    }

    _wasPlaying = provider.isPlaying;
  }

  Future<void> _animatePlaybackCameraTo(
    LatLng target, {
    double? zoom,
    double bearing = 0,
  }) async {
    final controller = _mapController;
    if (controller == null || _isDisposing || !mounted) return;
    try {
      if (zoom != null) {
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: target, zoom: zoom, bearing: bearing),
          ),
        );
      } else {
        final currentZoom = await controller.getZoomLevel();
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: target,
              zoom: currentZoom,
              bearing: bearing,
            ),
          ),
        );
      }
    } catch (_) {}
  }

  Future<bool> _isPlaybackCarOutsideSafeViewport(LatLng target) async {
    final controller = _mapController;
    if (controller == null || !mounted || _isDisposing) return true;
    try {
      final screenCoordinate = await controller.getScreenCoordinate(target);
      if (!mounted || _isDisposing) return true;
      final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
      final offset = Offset(
        screenCoordinate.x.toDouble() / devicePixelRatio,
        screenCoordinate.y.toDouble() / devicePixelRatio,
      );
      final size = MediaQuery.sizeOf(context);
      final mediaQuery = MediaQuery.of(context);
      final topLimit = mediaQuery.padding.top + _playbackSafeTopInset;
      final bottomLimit = size.height - _playbackSafeBottomInset;
      final leftLimit = _playbackSafeSidePadding;
      final rightLimit = size.width - _playbackSafeSidePadding;

      final isInside = offset.dx >= leftLimit &&
          offset.dx <= rightLimit &&
          offset.dy >= topLimit &&
          offset.dy <= bottomLimit;
      return !isInside;
    } catch (_) {
      return true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (_appliedMapBrightness != brightness) {
      unawaited(_applyMapStyleForTheme());
    }
  }

  Future<void> _applyMapStyleForTheme() async {
    final brightness = Theme.of(context).brightness;
    String? nextStyle;
    if (brightness == Brightness.dark) {
      _darkMapStyle ??=
          await rootBundle.loadString('assets/map_styles/google_dark.json');
      nextStyle = _darkMapStyle;
    }
    if (!mounted) return;
    setState(() {
      _googleMapStyle = nextStyle;
      _appliedMapBrightness = brightness;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final textScale = appTextScale(context, ScaleProfile.reportType);
    final iconScale = appIconScale(context, ScaleProfile.reportType);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<DeviceHistoryProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              _buildMap(provider),
              if (provider.isLoading) _buildLoadingOverlay(),
              if (provider.errorMessage != null && !provider.isLoading)
                _buildErrorBanner(provider.errorMessage!),

              if (_isTaskPlaybackMode)
                _buildTaskPlaybackRangeCard()
              else
                Positioned(
                  top: .6.h,
                  left: 4.w,
                  right: 4.w,
                  child: MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.linear(textScale)),
                    child: IconTheme(
                      data:
                          IconTheme.of(context).copyWith(size: 24 * iconScale),
                      child: Column(
                        children: [
                          SingleVehicleDateFilterBar(
                            filterLabels: [
                              l10n.today,
                              l10n.yesterday,
                              l10n.last3Days,
                              l10n.last7Days,
                              l10n.custom,
                            ],
                            selectedFilterIndex: _selectedQuickFilterIndex(),
                            showDateRangePicker: showCustomPicker,
                            rangeText:
                                '${_formatDateDisplay(fromDate)} ${_formatTimeDisplay(fromTime)}  ->  ${_formatDateDisplay(toDate)} ${_formatTimeDisplay(toTime)}',
                            onFilterTap: (index) {
                              if (index == 4) {
                                _openCustomPicker();
                                return;
                              }
                              const filters = [
                                'Today',
                                'Yesterday',
                                'Last 3 Days',
                                'Last 7 Days'
                              ];
                              _applyQuickFilter(filters[index]);
                            },
                            onDateRangeTap: _toggleCustomPicker,
                          ),
                          if (showCustomPicker) ...[
                            verticalSpace(height: 1.h),
                            SingleVehicleDateRangePickerCard(
                              fromDateTitle: l10n.fromDate,
                              toDateTitle: l10n.toDate,
                              fromTimeTitle: l10n.fromTime,
                              toTimeTitle: l10n.toTime,
                              selectDateLabel: l10n.selectDate,
                              selectTimeLabel: l10n.selectTime,
                              applyLabel: l10n.applyRange,
                              fromDateValue: _formatPickerDate(customStartDate),
                              toDateValue: _formatPickerDate(customEndDate),
                              fromTimeValue: _formatPickerTime(customStartTime),
                              toTimeValue: _formatPickerTime(customEndTime),
                              onApply: () {
                                if (customStartDate != null &&
                                    customEndDate != null &&
                                    customStartTime != null &&
                                    customEndTime != null) {
                                  if (!_isDateRangeValid(
                                      customStartDate, customEndDate)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n
                                            .fromDateCannotBeLaterThanToDate),
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() {
                                    showCustomPicker = false;
                                    _hasFilterApplied = true;
                                    selectedFilter = "Custom";
                                  });
                                  provider.disableHeadingUp();
                                  _fetchHistory();
                                }
                              },
                              onFromDateTap: () async {
                                final picked = await _pickDate(
                                  customStartDate ?? DateTime.now(),
                                  maxDate: customEndDate ?? DateTime.now(),
                                );
                                if (picked != null) {
                                  _onDatePicked(picked, true);
                                }
                              },
                              onToDateTap: () async {
                                final picked = await _pickDate(
                                  customEndDate ?? DateTime.now(),
                                  minDate: customStartDate ?? DateTime(2020),
                                  maxDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  _onDatePicked(picked, false);
                                }
                              },
                              onFromTimeTap: () async {
                                final picked = await _pickTime(customStartTime);
                                if (picked != null) {
                                  _onTimePicked(picked, true);
                                }
                              },
                              onToTimeTap: () async {
                                final picked = await _pickTime(customEndTime);
                                if (picked != null) {
                                  _onTimePicked(picked, false);
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              if (_hasFilterApplied && provider.routeList.isNotEmpty)
                Positioned(
                  right: 4.w,
                  top: showCustomPicker ? 28.h : 12.5.h,
                  child: _buildPlaybackFollowControl(),
                ),
                if (_hasFilterApplied && provider.routeList.isNotEmpty) ...[
                  Positioned(
                    left: 4.w,
                    top: showCustomPicker ? 28.h : 12.5.h,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeadingUpControl(provider),
                        SizedBox(height: 1.h),
                        _buildMapTypeControl(provider),
                      ],
                    ),
                  ),
                ],

              // Bottom Sheet
              if (provider.routeList.isNotEmpty && _hasFilterApplied)
                HistoryBottomSheet(
                  provider: provider,
                  mapController: _mapController,
                )
              else
                _buildDummyBottomSheet(
                    provider), // dummy jab tak history na aaye
            ],
          );
        },
      ),
    );
  }

  Widget _buildMap(DeviceHistoryProvider provider) {
    final hasActiveHistory = _hasFilterApplied && provider.routeList.isNotEmpty;
    final livePos = widget.initialLivePosition ??
        (hasActiveHistory
            ? LatLng(provider.routeList.first.lat, provider.routeList.first.lng)
            : const LatLng(24.8607, 67.0011));

    return ValueListenableBuilder<Marker?>(
      valueListenable: provider.carMarkerNotifier,
      builder: (context, carMarker, _) {
        _syncHistoryCamera(provider);
        return GoogleMap(
          style: _googleMapStyle,
          initialCameraPosition: CameraPosition(
            target: livePos,
            zoom: widget.initialLivePosition != null ? 15 : 12,
          ),
          zoomGesturesEnabled: true,
          scrollGesturesEnabled: true,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: true,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer()),
          },
          myLocationEnabled: true,
          mapType: provider.currentMapType,
          onMapCreated: (controller) {
            if (_isDisposing) {
              try {
                controller.dispose();
              } catch (_) {}
              return;
            }
            _mapController = controller;
            if (_hasFilterApplied && provider.polyLatLng.isNotEmpty) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (!mounted || _isDisposing || _mapController != controller) {
                  return;
                }
                final bounds = provider.calculateBounds();
                if (bounds != null) {
                  try {
                    controller.animateCamera(
                        CameraUpdate.newLatLngBounds(bounds, 50));
                  } catch (_) {}
                }
              });
            } else if (widget.initialLivePosition != null) {
              try {
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                        target: widget.initialLivePosition!, zoom: 15),
                  ),
                );
              } catch (_) {}
            }
          },
          markers: {
            if (_hasFilterApplied) ...provider.mapMarkers,
            if (!_hasFilterApplied && widget.initialLivePosition != null)
              Marker(
                markerId: const MarkerId('current_live'),
                position: widget.initialLivePosition!,
                icon: _initialLiveMarkerIcon ??
                    BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue),
                anchor: const Offset(0.5, 0.5),
                infoWindow: InfoWindow(title: context.l10n.currentLiveLocation),
              ),
          },
          polylines:
              _hasFilterApplied ? provider.routePolyLine : const <Polyline>{},
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        );
      },
    );
  }

  Widget _buildPlaybackFollowControl() {
    final theme = Theme.of(context);
    final isEnabled = _followPlaybackCamera;
    final Color activeColor = ConstantColor.primaryColor;
    final isDark = theme.brightness == Brightness.dark;
    final Color bgColor = isEnabled
        ? activeColor
        : (isDark
            ? theme.cardColor.withValues(alpha: .9)
            : Colors.white.withValues(alpha: .94));
    final Color iconColor =
        isEnabled ? Colors.white : theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? .28 : .14),
              blurRadius: 14,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: bgColor,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              setState(() {
                _followPlaybackCamera = !_followPlaybackCamera;
                _lastPlaybackCameraFollowAt = null;
              });
            },
            child: SizedBox(
              height: 5.1.h,
              width: 5.1.h,
              child: Icon(
                isEnabled
                    ? Icons.navigation_rounded
                    : Icons.navigation_outlined,
                size: 2.0.h,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeadingUpControl(DeviceHistoryProvider provider) {
    final theme = Theme.of(context);
    final isEnabled = provider.headingUpMode;
    final Color activeColor = AppColors.green;
    final isDark = theme.brightness == Brightness.dark;
    final Color bgColor = isEnabled
        ? activeColor
        : (isDark
            ? theme.cardColor.withValues(alpha: .9)
            : Colors.white.withValues(alpha: .94));
    final Color iconColor =
        isEnabled ? Colors.white : theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? .28 : .14),
              blurRadius: 14,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: bgColor,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              provider.toggleHeadingUpMode();
              if (provider.headingUpMode) {
                if (provider.carLat != 0 && provider.carLng != 0) {
                  _animatePlaybackCameraTo(
                    LatLng(provider.carLat, provider.carLng),
                    bearing: provider.carRotation,
                  );
                }
              } else {
                if (provider.carLat != 0 && provider.carLng != 0) {
                  _animatePlaybackCameraTo(
                    LatLng(provider.carLat, provider.carLng),
                    bearing: 0,
                  );
                }
              }
            },
            child: SizedBox(
              height: 5.1.h,
              width: 5.1.h,
              child: Icon(
                isEnabled ? Icons.explore : Icons.explore_outlined,
                size: 2.0.h,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapTypeControl(DeviceHistoryProvider provider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color bgColor = isDark
        ? theme.cardColor.withValues(alpha: .9)
        : Colors.white.withValues(alpha: .94);
    final Color iconColor = theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? .28 : .14),
              blurRadius: 14,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: bgColor,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: provider.toggleMapType,
            child: SizedBox(
              height: 5.1.h,
              width: 5.1.h,
              child: Icon(
                provider.currentMapType == MapType.normal
                    ? Icons.map_outlined
                    : Icons.layers,
                size: 2.0.h,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskPlaybackRangeCard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 56,
      right: 12,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: .75.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2433) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? .16 : .08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: ConstantColor.primaryColor,
              size: 16.sp,
            ),
            SizedBox(width: 1.8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.taskPlayback,
                    style: AppStyles.semiboldTextStyle(context).copyWith(
                      fontSize: 14.1.sp,
                      color: onSurface,
                    ),
                  ),
                  SizedBox(height: .1.h),
                  Text(
                    '${_formatOverlayDateTime(fromDate, fromTime)}  ->  ${_formatOverlayDateTime(toDate, toTime)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: 13.1.sp,
                      color: onSurface.withValues(alpha: .78),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatOverlayDateTime(String date, String time) {
    try {
      final parsed = DateTime.parse('${date}T$time:00');
      return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
    } catch (_) {
      return '$date $time';
    }
  }

  Widget _buildDummyBottomSheet(DeviceHistoryProvider provider) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.currentLocation,
              style: AppStyles.semiboldTextStyle(context).copyWith(
                fontSize: 17.sp,
                color: onSurface,
              ),
            ),
            verticalSpace(height: 1.h),
            Text(
              context.l10n.currentVehicleLocationHistoryHint,
              textAlign: TextAlign.center,
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: 13.sp,
                color: onSurface.withValues(alpha: 0.72),
              ),
            ),
            verticalSpace(height: 2.h),
            verticalSpace(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12.sp),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: ConstantColor.primaryColor),
              verticalSpace(height: 2.h),
              Text(
                context.l10n.loadingHistory,
                style: AppStyles.semiboldTextStyle(context).copyWith(
                  fontSize: 16.sp,
                  color: onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    final theme = Theme.of(context);
    return Positioned(
      top: 8.4.h,
      left: 4.w,
      right: 4.w,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12.sp),
        ),
        child: Text(
          message,
          style: AppStyles.semiboldTextStyle(context).copyWith(
            color: theme.colorScheme.onErrorContainer,
            fontSize: 14.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposing = true;
    try {
      _mapController?.dispose();
    } catch (_) {}
    _mapController = null;
    super.dispose();
  }
}
