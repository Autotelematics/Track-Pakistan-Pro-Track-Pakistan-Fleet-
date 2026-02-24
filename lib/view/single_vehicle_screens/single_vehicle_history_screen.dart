import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/get_device_history_provider.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/widgets/single_vehicle_history_widget/history_bottom_sheet.dart';
import 'package:trackerapp/widgets/single_vehicle_history_widget/history_custom_date_picker.dart';
import 'package:trackerapp/widgets/single_vehicle_history_widget/history_filter_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

class SingleVehicleHistoryScreen extends StatefulWidget {
  final int deviceId;
  final String deviceTitle;
  final LatLng? initialLivePosition; // live tracking se current location pass karne ke liye

  const SingleVehicleHistoryScreen({
    super.key,
    required this.deviceId,
    required this.deviceTitle,
    this.initialLivePosition,
  });

  @override
  State<SingleVehicleHistoryScreen> createState() =>
      _SingleVehicleHistoryScreenState();
}

class _SingleVehicleHistoryScreenState extends State<SingleVehicleHistoryScreen>
    with TickerProviderStateMixin {
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

  @override
  void initState() {
    super.initState();

    // Default last 12 hours dummy
    final now = DateTime.now();
    final from = now.subtract(const Duration(hours: 12));
    fromDate = _dateFormatApi.format(from);
    toDate = _dateFormatApi.format(now);
    fromTime = _timeFormat.format(from);
    toTime = _timeFormat.format(now);

    // History screen open hote hi API call NAHI hogi
    // Koi filter selected nahi
  }

  void _applyQuickFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      _hasFilterApplied = true;
    });

    final now = DateTime.now();
    switch (filter) {
      case "Today":
        fromDate = toDate = _dateFormatApi.format(now);
        fromTime = "00:00";
        toTime = _timeFormat.format(now);
        break;
      case "Yesterday":
        final y = now.subtract(const Duration(days: 1));
        fromDate = toDate = _dateFormatApi.format(y);
        fromTime = "00:00";
        toTime = "23:59";
        break;
      case "Last 3 Days":
        fromDate = _dateFormatApi.format(now.subtract(const Duration(days: 2)));
        toDate = _dateFormatApi.format(now);
        fromTime = "00:00";
        toTime = _timeFormat.format(now);
        break;
      case "Last 7 Days":
        fromDate = _dateFormatApi.format(now.subtract(const Duration(days: 6)));
        toDate = _dateFormatApi.format(now);
        fromTime = "00:00";
        toTime = _timeFormat.format(now);
        break;
    }
    _fetchHistory(); // sirf filter select hone par API call
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
    );
  }

  // Left side From/To date par click → custom picker
  void _openCustomPicker() {
    setState(() => showCustomPicker = true);
  }

  void _onDatePicked(DateTime date, bool isStart) {
    setState(() {
      if (isStart) {
        customStartDate = date;
        fromDate = _dateFormatApi.format(date);
      } else {
        customEndDate = date;
        toDate = _dateFormatApi.format(date);
      }
    });
  }

  void _onTimePicked(TimeOfDay time, bool isStart) {
    final t = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
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

  void _autoFollowPlayback(DeviceHistoryProvider provider) {
    if (!provider.isPlaying ||
        _mapController == null ||
        provider.currentSliderValue >= provider.routeList.length) {
      return;
    }
    final loc = provider.routeList[provider.currentSliderValue];
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(loc.lat, loc.lng), zoom: 17),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Consumer<DeviceHistoryProvider>(
        builder: (context, provider, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _autoFollowPlayback(provider);
          });

          return Stack(
            children: [
              _buildMap(provider),
              if (provider.isLoading) _buildLoadingOverlay(),
              if (provider.errorMessage != null && !provider.isLoading)
                _buildErrorBanner(provider.errorMessage!),

              // Filter Bar
              HistoryFilterBar(
                fromDate: fromDate,
                toDate: toDate,
                selectedFilter: selectedFilter,
                onFilterSelected: _applyQuickFilter,
                onDateRangeTap: _openCustomPicker, // left side click
              ),

              if (showCustomPicker)
                HistoryCustomDateTimePicker(
                  customStartDate: customStartDate,
                  customEndDate: customEndDate,
                  customStartTime: customStartTime,
                  customEndTime: customEndTime,
                  onClose: () => setState(() => showCustomPicker = false),
                  onApply: () {
                    if (customStartDate != null &&
                        customEndDate != null &&
                        customStartTime != null &&
                        customEndTime != null) {
                      setState(() {
                        showCustomPicker = false;
                        _hasFilterApplied = true;
                      });
                      _fetchHistory();
                    }
                  },
                  onDatePicked: _onDatePicked,
                  onTimePicked: _onTimePicked,
                ),

              // Bottom Sheet
              if (provider.routeList.isNotEmpty && _hasFilterApplied)
                HistoryBottomSheet(
                  provider: provider,
                  mapController: _mapController,
                )
              else
                _buildDummyBottomSheet(provider), // dummy jab tak history na aaye
            ],
          );
        },
      ),
    );
  }

  Widget _buildMap(DeviceHistoryProvider provider) {
    final livePos = widget.initialLivePosition ??
        (provider.routeList.isNotEmpty
            ? LatLng(provider.routeList.first.lat, provider.routeList.first.lng)
            : const LatLng(24.8607, 67.0011));

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: livePos,
        zoom: widget.initialLivePosition != null ? 15 : 12,
      ),
      zoomGesturesEnabled: true,
      scrollGesturesEnabled: true,
      rotateGesturesEnabled: true,
      tiltGesturesEnabled: true,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      },
      myLocationEnabled: true,
      mapType: _mapType,
      onMapCreated: (controller) {
        _mapController = controller;
        if (provider.polyLatLng.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 500), () {
            final bounds = provider.calculateBounds();
            if (bounds != null) {
              controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
            }
          });
        } else if (widget.initialLivePosition != null) {
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: widget.initialLivePosition!, zoom: 15),
            ),
          );
        }
      },
      markers: {
        ...provider.mapMarkers,
        // Current live location marker (blue)
        if (!_hasFilterApplied && widget.initialLivePosition != null)
          Marker(
            markerId: const MarkerId('current_live'),
            position: widget.initialLivePosition!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            anchor: const Offset(0.5, 0.5),
            infoWindow: const InfoWindow(title: 'Current Live Location'),
          ),
      },
      polylines: provider.routePolyLine,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
    );
  }

  Widget _buildDummyBottomSheet(DeviceHistoryProvider provider) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Current Location",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            verticalSpace(height: 1.h),
            Text(
              "Live marker map par dikhai ja raha hai.\nFilter select karein ya date range click karein history dekhne ke liye.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            verticalSpace(height: 2.h),
            // Dummy data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _dummyStat("Distance", "0.0 km"),
                _dummyStat("Top Speed", "0 km/h"),
                _dummyStat("Duration", "0 min"),
              ],
            ),
            verticalSpace(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _dummyStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
      ],
    );
  }

  Widget _buildLoadingOverlay() => Container(
    color: Colors.black.withOpacity(0.3),
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
            CircularProgressIndicator(color: ConstantColor.primaryColor),
            verticalSpace(height: 2.h),
            Text('Loading history...',
                style: AppStyles.semiboldTextStyle(context)
                    .copyWith(fontSize: 16.sp)),
          ],
        ),
      ),
    ),
  );

  Widget _buildErrorBanner(String message) => Positioned(
    top: 20.h,
    left: 4.w,
    right: 4.w,
    child: Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Text(
        message,
        style: AppStyles.semiboldTextStyle(context)
            .copyWith(color: AppColors.white, fontSize: 14.sp),
        textAlign: TextAlign.center,
      ),
    ),
  );
}