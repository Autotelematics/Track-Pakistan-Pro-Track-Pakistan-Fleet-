import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/app/theme/popups.dart';
import 'package:trackerapp/data/models/device_expense_model.dart';
import 'package:trackerapp/data/models/device_service_model.dart';
import 'package:trackerapp/data/models/get_device_list_model.dart';
import 'package:trackerapp/data/models/local_reminder_model.dart';
import 'package:trackerapp/data/repositories/device_expense_repository.dart';
import 'package:trackerapp/data/repositories/device_service_repository.dart';
import 'package:trackerapp/providers/device_expense_provider.dart';
import 'package:trackerapp/providers/device_service_provider.dart';
import 'package:trackerapp/providers/reminder_provider.dart';
import 'package:trackerapp/providers/update_device_data_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/utils/app_snackbar.dart';
import 'package:trackerapp/view/setting_screens/manager_chat_screen.dart';
import 'package:trackerapp/view/single_vehicle_screens/single_vehicle_expense_screen.dart';
import 'package:trackerapp/view/single_vehicle_screens/single_vehicle_service_screen.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class SingleVehicleInfoScreen extends StatelessWidget {
  final List<Sensor> sensors;
  final int deviceId;
  final String vehicleName;
  final String? initialKmPerLiter;
  final String? initialEngineType;
  final String? initialVehicleType;

  const SingleVehicleInfoScreen({
    super.key,
    required this.sensors,
    required this.deviceId,
    required this.vehicleName,
    this.initialKmPerLiter,
    this.initialEngineType,
    this.initialVehicleType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final pressedOverlay = ConstantColor.primaryColor.withValues(alpha: .14);

    return Theme(
      data: theme.copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            animationDuration: const Duration(milliseconds: 90),
            elevation: WidgetStateProperty.resolveWith<double>(
              (states) => states.contains(WidgetState.pressed) ? 0 : 2,
            ),
            overlayColor: WidgetStatePropertyAll<Color>(pressedOverlay),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            animationDuration: const Duration(milliseconds: 90),
            overlayColor: WidgetStatePropertyAll<Color>(pressedOverlay),
            side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
              if (states.contains(WidgetState.pressed)) {
                return BorderSide(
                  color: ConstantColor.primaryColor.withValues(alpha: .35),
                );
              }
              return null;
            }),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            animationDuration: const Duration(milliseconds: 90),
            overlayColor: WidgetStatePropertyAll<Color>(pressedOverlay),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            animationDuration: const Duration(milliseconds: 90),
            overlayColor: WidgetStatePropertyAll<Color>(pressedOverlay),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          top: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(4.w, .6.h, 4.w, 1.h),
            children: [
              // Text(
              //   "Vehicle Info",
              //   style: AppStyles.boldTextStyle(context).copyWith(
              //     fontSize: 16.4.sp,
              //     color: isDark ? AppColors.white : AppColors.textBlack,
              //   ),
              // ),
              verticalSpace(height: 0.0.h),
              _SensorsCard(sensors: sensors),
              verticalSpace(height: 1.h),
              _UpdateVehicleInfoCard(
                deviceId: deviceId,
                initialKmPerLiter: initialKmPerLiter,
                initialEngineType: initialEngineType,
                initialVehicleType: initialVehicleType,
              ),
              verticalSpace(height: 1.h),
              _InfoCard(
                index: 0,
                icon: Icons.person_outline,
                iconBg: const Color(0xFFEAF1FF),
                iconColor: const Color(0xFF3B82F6),
                title: l10n.driverAssignment,
                actionText: l10n.assign,
                bodyText: l10n.seeDriver,
                deviceId: deviceId,
                vehicleName: vehicleName,
              ),
              verticalSpace(height: 1.h),
              _InfoCard(
                index: 1,
                icon: Icons.assignment_turned_in,
                iconBg: const Color(0xFFEAF1FF),
                iconColor: const Color(0xFF3B82F6),
                title: l10n.alertAssign,
                actionText: l10n.assign,
                bodyText: l10n.noAlertAssigned,
                deviceId: deviceId,
                vehicleName: vehicleName,
              ),
              verticalSpace(height: 1.h),
              _InfoCard(
                index: 2,
                icon: Icons.build_outlined,
                iconBg: const Color(0xFFFFF3E8),
                iconColor: const Color(0xFFF97316),
                title: l10n.maintenance,
                actionText: l10n.add,
                bodyText: l10n.noUpcomingMaintenance,
                deviceId: deviceId,
                vehicleName: vehicleName,
              ),
              verticalSpace(height: 1.h),
              _InfoCard(
                index: 3,
                icon: Icons.attach_money,
                iconBg: const Color(0xFFE9F9F1),
                iconColor: const Color(0xFF10B981),
                title: l10n.expenses,
                subtitle: l10n.trackManageExpenses,
                actionText: l10n.add,
                bodyText: l10n.viewAllExpenses,
                deviceId: deviceId,
                vehicleName: vehicleName,
              ),
              verticalSpace(height: 1.h),
              _InfoCard(
                index: 5,
                icon: Icons.notifications_none_outlined,
                iconBg: const Color(0xFFFFF1F2),
                iconColor: const Color(0xFFE4395E),
                title: l10n.reminders,
                actionText: l10n.add,
                bodyText: l10n.noActiveReminders,
                deviceId: deviceId,
                vehicleName: vehicleName,
              ),
              verticalSpace(height: 1.h),
              _InfoCard(
                index: 6,
                icon: Icons.report_problem_outlined,
                iconBg: const Color(0xFFFFF4E5),
                iconColor: const Color(0xFFD97706),
                title: l10n.complainVehicle,
                subtitle: l10n.supportChatVehicle,
                actionText: l10n.complain,
                bodyText: l10n.talkToSupportVehicle(vehicleName),
                deviceId: deviceId,
                vehicleName: vehicleName,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PushInkWell extends StatefulWidget {
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Widget child;
  final double pressedScale;
  final double pressedYOffset;

  const _PushInkWell({
    required this.onTap,
    required this.child,
    this.borderRadius,
    this.pressedScale = 0.97,
    this.pressedYOffset = 0.0,
  });

  @override
  State<_PushInkWell> createState() => _PushInkWellState();
}

class _PushInkWellState extends State<_PushInkWell> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: EdgeInsets.only(top: _isPressed ? widget.pressedYOffset : 0),
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOutCubic,
      child: AnimatedScale(
        scale: _isPressed ? widget.pressedScale : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutCubic,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: widget.borderRadius,
            onHighlightChanged: (pressed) {
              if (_isPressed == pressed) return;
              setState(() => _isPressed = pressed);
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _SensorsCard extends StatelessWidget {
  final List<Sensor> sensors;

  const _SensorsCard({required this.sensors});

  static const Map<String, IconData> _sensorIcons = {
    "IGNITION": Icons.flash_on,
    "GPS": Icons.gps_fixed,
    "charging": Icons.battery_charging_full,
    "External Volts": Icons.bolt,
    "Satellites": Icons.satellite_alt,
    "Engine hours": Icons.av_timer,
    "Odometer": Icons.speed,
    "Network": Icons.signal_cellular_4_bar,
    "Immobiliser": Icons.lock_outline,
    "Result": Icons.info_outline,
    "SIM": Icons.sim_card,
  };

  static const IconData _fallbackIcon = Icons.sensors;

  Color _getValueColor(String? value, bool isDark) {
    if (value == "On") return AppColors.green;
    if (value == "Off") return AppColors.red;
    return isDark ? Colors.white : Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: .06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .18 : .06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: .2.h),
        childrenPadding: EdgeInsets.fromLTRB(3.w, .1.h, 3.w, 1.0.h),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(7.px),
              decoration: BoxDecoration(
                color: ConstantColor.primaryColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12.px),
              ),
              child: Icon(
                Icons.sensors,
                color: ConstantColor.primaryColor,
                size: 2.6.h,
              ),
            ),
            horizontalSpace(width: 2.4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.vehicleSensors,
                    style: AppStyles.semiboldTextStyle(context).copyWith(
                      fontSize: 14.2.sp,
                      color: isDark ? AppColors.white : AppColors.textBlack,
                    ),
                  ),
                  Text(
                    l10n.sensorItemsCount(sensors.length),
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: 13.2.sp,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          if (sensors.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 1.2.h),
              child: Text(
                l10n.noSensorsAvailable,
                style: AppStyles.regularTextStyle(context).copyWith(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            )
          else
            ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sensors.length,
              separatorBuilder: (_, __) => Divider(
                color: isDark ? Colors.white10 : Colors.grey.shade300,
                height: 1.2.h,
              ),
              itemBuilder: (context, index) {
                final sensor = sensors[index];
                final label =
                    sensor.name ?? sensor.type ?? l10n.vehicleStatusUnknown;
                final value = sensor.value ?? sensor.val?.toString() ?? "-";
                final sensorIcon = _sensorIcons[label] ?? _fallbackIcon;

                return Row(
                  children: [
                    Container(
                      width: 8.2.w,
                      height: 4.0.h,
                      decoration: BoxDecoration(
                        color: AppColors.blueCyan.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        sensorIcon,
                        size: 15.sp,
                        color: AppColors.blueCyan,
                      ),
                    ),
                    horizontalSpace(width: 2.2.w),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.regularTextStyle(context).copyWith(
                          fontSize: 13.1.sp,
                          color: isDark ? AppColors.white : AppColors.textBlack,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 1.6.w),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 36.w),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.2.w, vertical: .5.h),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: .07)
                                  : Colors.black.withValues(alpha: .03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? Colors.white10 : Colors.black12,
                              ),
                            ),
                            child: Text(
                              value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style:
                                  AppStyles.semiboldTextStyle(context).copyWith(
                                fontSize: 12.3.sp,
                                color: _getValueColor(value, isDark),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _UpdateVehicleInfoCard extends StatefulWidget {
  final int deviceId;
  final String? initialKmPerLiter;
  final String? initialEngineType;
  final String? initialVehicleType;

  const _UpdateVehicleInfoCard({
    required this.deviceId,
    this.initialKmPerLiter,
    this.initialEngineType,
    this.initialVehicleType,
  });

  @override
  State<_UpdateVehicleInfoCard> createState() => _UpdateVehicleInfoCardState();
}

class _UpdateVehicleInfoCardState extends State<_UpdateVehicleInfoCard> {
  static const List<String> _engineOptions = ['Petrol', 'Diesel'];
  static const List<String> _vehicleOptions = [
    'Car',
    'Truck',
    'Motorbike',
    'Bicycle',
    'Bus',
    'Boat',
    'Truck Trailer',
    'Ambulance',
    'SUV',
    'Other',
  ];

  String _kmPerLiter = '-';
  String _engineType = '-';
  String _vehicleType = '-';
  bool _didRequestCurrentData = false;
  late final TextEditingController _dialogKmController;

  @override
  void initState() {
    super.initState();
    _dialogKmController = TextEditingController();
    _kmPerLiter = (widget.initialKmPerLiter?.trim().isNotEmpty ?? false)
        ? widget.initialKmPerLiter!.trim()
        : '-';
    _engineType = _engineOptions.contains(widget.initialEngineType)
        ? widget.initialEngineType!
        : '-';
    _vehicleType = _vehicleOptions.contains(widget.initialVehicleType)
        ? widget.initialVehicleType!
        : '-';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didRequestCurrentData) return;
    _didRequestCurrentData = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadCurrentData();
    });
  }

  @override
  void dispose() {
    _dialogKmController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentData() async {
    final provider = context.read<UpdateDeviceDataProvider>();
    final response = await provider.fetchCurrentDeviceData(
      deviceId: widget.deviceId.toString(),
      showErrorSnackBar: false,
    );

    if (!mounted || response == null) return;

    setState(() {
      if ((response.kmPerLiter?.trim().isNotEmpty ?? false)) {
        _kmPerLiter = response.kmPerLiter!.trim();
      }
      if (_engineOptions.contains(response.engineType)) {
        _engineType = response.engineType!;
      }
      if (_vehicleOptions.contains(response.vehicleType)) {
        _vehicleType = response.vehicleType!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.25.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: .06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .18 : .06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.px),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF8FF),
                  borderRadius: BorderRadius.circular(11.px),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: Color(0xFF0284C7),
                  size: 1.9.h,
                ),
              ),
              horizontalSpace(width: 2.4.w),
              Expanded(
                child: Text(
                  l10n.vehicleInfo,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: 13.8.sp,
                    color: isDark ? AppColors.white : AppColors.textBlack,
                  ),
                ),
              ),
              Consumer<UpdateDeviceDataProvider>(
                builder: (context, provider, _) {
                  return _PushInkWell(
                    onTap:
                        provider.isLoading ? null : () => _showUpdateDialog(),
                    borderRadius: BorderRadius.circular(16),
                    pressedScale: 0.93,
                    pressedYOffset: 1.4,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.0.w, vertical: .78.h),
                      decoration: BoxDecoration(
                        color: AppColors.blueCyan.withValues(alpha: .70),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.blueCyan.withValues(alpha: .85),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blueCyan.withValues(alpha: .22),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          provider.isLoading
                              ? SizedBox(
                                  height: 1.75.h,
                                  width: 1.75.h,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  Icons.edit_outlined,
                                  size: 1.75.h,
                                  color: Colors.white,
                                ),
                          horizontalSpace(width: .8.w),
                          Text(
                            l10n.update,
                            style:
                                AppStyles.semiboldTextStyle(context).copyWith(
                              fontSize: 12.4.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          verticalSpace(height: 1.2.h),
          _valueTile(context, l10n.averagePerLiter, _kmPerLiter),
          verticalSpace(height: .8.h),
          _valueTile(context, l10n.engineType, _engineType),
          verticalSpace(height: .8.h),
          _valueTile(context, l10n.vehicleType, _vehicleType),
        ],
      ),
    );
  }

  Widget _valueTile(BuildContext context, String title, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: .95.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: .05)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppStyles.semiboldTextStyle(context).copyWith(
                fontSize: 13.5.sp,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: AppStyles.semiboldTextStyle(context).copyWith(
              fontSize: 13.5.sp,
              color: isDark ? AppColors.white : AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showUpdateDialog() async {
    _dialogKmController.text = _kmPerLiter == '-' ? '' : _kmPerLiter;
    String selectedEngineType = _engineOptions.contains(_engineType)
        ? _engineType
        : _engineOptions.first;
    String selectedVehicleType = _vehicleOptions.contains(_vehicleType)
        ? _vehicleType
        : _vehicleOptions.first;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dialogFieldWidth = 84.w;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final l10n = context.l10n;
            return AlertDialog(
              backgroundColor: theme.cardColor,
              title: SizedBox(
                width: double.infinity,
                height: 4.6.h,
                child: Stack(
                  children: [
                    Positioned(
                      top: -.6.h,
                      right: -1.w,
                      child: Icon(
                        Icons.directions_car_rounded,
                        color: AppColors.blueCyan
                            .withValues(alpha: isDark ? 0.22 : 0.16),
                        size: 6.2.h,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        l10n.updateVehicleInfo,
                        style: AppStyles.boldTextStyle(context).copyWith(
                          fontSize: 16.2.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.white : AppColors.textBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 84.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _dialogFieldLabel(context, l10n.averagePerLiter),
                      verticalSpace(height: .5.h),
                      _dialogTextField(
                        context: context,
                        isDark: isDark,
                        controller: _dialogKmController,
                        hintText: l10n.exampleAveragePerLiter,
                      ),
                      verticalSpace(height: 1.2.h),
                      _dialogFieldLabel(context, l10n.engineType),
                      verticalSpace(height: .5.h),
                      _dialogDropdownField(
                        context: context,
                        isDark: isDark,
                        fieldWidth: dialogFieldWidth,
                        value: selectedEngineType,
                        hintText: l10n.selectEngineType,
                        items: _engineOptions,
                        onChanged: (value) {
                          setDialogState(() => selectedEngineType = value);
                        },
                      ),
                      verticalSpace(height: 1.2.h),
                      _dialogFieldLabel(context, l10n.vehicleType),
                      verticalSpace(height: .5.h),
                      _dialogDropdownField(
                        context: context,
                        isDark: isDark,
                        fieldWidth: dialogFieldWidth,
                        value: selectedVehicleType,
                        hintText: l10n.selectVehicleType,
                        items: _vehicleOptions,
                        onChanged: (value) {
                          setDialogState(() => selectedVehicleType = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    l10n.cancel,
                    style: AppStyles.semiboldTextStyle(context).copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                Consumer<UpdateDeviceDataProvider>(
                  builder: (context, provider, _) {
                    return ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              final kmText = _dialogKmController.text.trim();
                              final value = double.tryParse(kmText);
                              if (kmText.isEmpty ||
                                  value == null ||
                                  value <= 0) {
                                AppSnackBar.error(
                                  message: l10n.pleaseEnterValidAveragePerLiter,
                                );
                                return;
                              }

                              final response = await context
                                  .read<UpdateDeviceDataProvider>()
                                  .updateDeviceData(
                                    deviceId: widget.deviceId.toString(),
                                    fuelQuantity: kmText,
                                    vehicleType: selectedVehicleType,
                                    engineType: selectedEngineType,
                                  );

                              if (!mounted ||
                                  response == null ||
                                  response.status != 1) {
                                return;
                              }

                              setState(() {
                                _kmPerLiter = response.kmPerLiter ?? kmText;
                                _engineType =
                                    _engineOptions.contains(response.engineType)
                                        ? response.engineType!
                                        : selectedEngineType;
                                _vehicleType = _vehicleOptions
                                        .contains(response.vehicleType)
                                    ? response.vehicleType!
                                    : selectedVehicleType;
                              });
                              if (!dialogContext.mounted) return;
                              Navigator.pop(dialogContext);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueCyan,
                        foregroundColor: Colors.white,
                      ),
                      child: provider.isLoading
                          ? SizedBox(
                              height: 1.6.h,
                              width: 1.6.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              l10n.save,
                              style: AppStyles.semiboldTextStyle(context)
                                  .copyWith(color: Colors.white),
                            ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _dialogFieldLabel(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: AppStyles.semiboldTextStyle(context).copyWith(
        fontSize: 14.2.sp,
        color: isDark ? Colors.white70 : Colors.black87,
      ),
    );
  }

  Widget _dialogTextField({
    required BuildContext context,
    required bool isDark,
    required TextEditingController controller,
    required String hintText,
  }) {
    final horizontalInset = 2.6.w;
    return Container(
      height: 4.6.h,
      decoration: _dialogControlDecoration(isDark: isDark),
      padding: EdgeInsets.symmetric(horizontal: horizontalInset),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlignVertical: TextAlignVertical.center,
        style: AppStyles.regularTextStyle(context).copyWith(
          fontSize: 14.2.sp,
          color: isDark ? AppColors.white : AppColors.textBlack,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          isDense: true,
          isCollapsed: true,
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: AppStyles.regularTextStyle(context).copyWith(
            fontSize: 14.sp,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
      ),
    );
  }

  Widget _dialogDropdownField({
    required BuildContext context,
    required bool isDark,
    required double fieldWidth,
    required String value,
    required String hintText,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final horizontalInset = 2.6.w;
    final innerWidth = fieldWidth - (horizontalInset * 2);
    return Container(
      height: 4.6.h,
      decoration: _dialogControlDecoration(isDark: isDark),
      padding: EdgeInsets.symmetric(horizontal: horizontalInset),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          value: value,
          hint: Text(
            hintText,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 14.sp,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          style: AppStyles.regularTextStyle(context).copyWith(
            fontSize: 13.2.sp,
            color: isDark ? AppColors.white : AppColors.textBlack,
            fontWeight: FontWeight.w500,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: 13.2.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (newValue) {
            if (newValue == null) return;
            onChanged(newValue);
          },
          buttonStyleData: ButtonStyleData(
            height: 4.6.h,
            width: innerWidth,
            padding: EdgeInsets.zero,
          ),
          iconStyleData: IconStyleData(
            icon: Icon(
              Icons.arrow_drop_down_rounded,
              color: onSurface.withValues(alpha: .7),
              size: 2.3.h,
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            width: innerWidth - 50,
            maxHeight: 36.h,
            isOverButton: false,
            offset: const Offset(-8, -6),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            height: 4.6.h,
          ),
        ),
      ),
    );
  }

  BoxDecoration _dialogControlDecoration({required bool isDark}) {
    return BoxDecoration(
      color: isDark
          ? Colors.white.withValues(alpha: .05)
          : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark ? Colors.white12 : Colors.black12,
      ),
    );
  }
}

class _InfoCard extends StatefulWidget {
  final int index;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String actionText;
  final String bodyText;
  final int deviceId;
  final String vehicleName;

  const _InfoCard({
    required this.index,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.actionText,
    required this.bodyText,
    required this.deviceId,
    required this.vehicleName,
  });

  @override
  State<_InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<_InfoCard> {
  bool _isAlertAssignLoading = false;

  int get index => widget.index;
  IconData get icon => widget.icon;
  Color get iconBg => widget.iconBg;
  Color get iconColor => widget.iconColor;
  String get title => widget.title;
  String? get subtitle => widget.subtitle;
  String get actionText => widget.actionText;
  String get bodyText => widget.bodyText;
  int get deviceId => widget.deviceId;
  String get vehicleName => widget.vehicleName;

  Future<void> _onPrimaryTap(BuildContext context) async {
    final l10n = context.l10n;
    if (index == 0) {
      showAssignDriverPopup(context, deviceId.toString());
    } else if (index == 1) {
      if (_isAlertAssignLoading) return;
      setState(() => _isAlertAssignLoading = true);
      try {
        await showAlertSettingsPopup(context, deviceId: deviceId);
      } finally {
        if (mounted) setState(() => _isAlertAssignLoading = false);
      }
    } else if (index == 2) {
      final formData = await showServiceFormDialog(context);
      if (formData == null) return;
      try {
        await DeviceServiceRepository().createService(
          deviceId: deviceId,
          name: formData.name,
          expirationBy: formData.expirationBy,
          interval: formData.interval,
          lastService: formData.lastService,
          triggerEventLeft: formData.triggerEventLeft,
          renewAfterExpiration: formData.renewAfterExpiration,
          expires: formData.expires,
          expiresDate: formData.expiresDate,
          remind: formData.remind,
          remindDate: formData.remindDate,
          email: formData.email,
          mobilePhone: formData.mobilePhone,
          description: formData.description,
        );
        AppSnackBar.success(message: l10n.serviceAddedSuccessfully);
      } catch (e) {
        AppSnackBar.error(message: e.toString());
      }
    } else if (index == 3) {
      final formData = await showExpenseFormDialog(
        context,
        deviceId: deviceId,
      );
      if (formData == null) return;

      try {
        await DeviceExpenseRepository().createExpense(
          deviceId: deviceId,
          typeId: formData.typeId,
          date: formData.date,
          quantity: formData.quantity,
          unitCost: formData.unitCost,
          name: formData.name,
          supplier: formData.supplier,
          comment: formData.comment,
        );
        AppSnackBar.success(message: l10n.expenseAddedSuccessfully);
      } catch (e) {
        AppSnackBar.error(message: e.toString());
      }
    } else if (index == 5) {
      showAddReminderPopup(
        context,
        deviceId: deviceId,
        vehicleName: vehicleName,
      );
    } else if (index == 6) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ManagerChatScreen(
            deviceId: deviceId,
            vehicleName: vehicleName,
          ),
        ),
      );
    }
  }

  void _onBodyTap(BuildContext context) {
    if (index == 0) {
      showDriverDetailPopup(context, deviceId: deviceId.toString());
      return;
    }
    if (index == 3) {
      _showExpenseListBottomSheet(
        context,
        deviceId: deviceId,
        vehicleName: vehicleName,
      );
      return;
    }
    if (index == 2) {
      _showServiceListBottomSheet(
        context,
        deviceId: deviceId,
        vehicleName: vehicleName,
      );
      return;
    }
    if (index == 5) {
      _showReminderListBottomSheet(
        context,
        deviceId: deviceId,
        vehicleName: vehicleName,
      );
      return;
    }
    if (index == 6) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ManagerChatScreen(
            deviceId: deviceId,
            vehicleName: vehicleName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    final activeReminderText = index == 5
        ? context.select<ReminderProvider, String>((provider) {
            final now = DateTime.now();
            final active = provider.reminders
                .where((r) =>
                    r.deviceId == deviceId &&
                    (r.repeatType != "none" || !r.dueAt.isBefore(now)))
                .length;
            if (active == 0) return l10n.noActiveReminders;
            if (active == 1) return l10n.singleActiveReminder;
            return l10n.multipleActiveReminders(active);
          })
        : "";
    final pastReminderText = index == 5
        ? context.select<ReminderProvider, String>((provider) {
            final now = DateTime.now();
            final past = provider.reminders
                .where((r) =>
                    r.deviceId == deviceId &&
                    r.repeatType == "none" &&
                    r.dueAt.isBefore(now))
                .length;
            if (past == 0) return l10n.noPastReminders;
            if (past == 1) return l10n.singlePastReminder;
            return l10n.multiplePastReminders(past);
          })
        : "";

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.25.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: .06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .18 : .06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: 0,
            left: 0,
            top: 0,
            height: 6.8.h,
            child: Icon(
              icon,
              size: 40.sp,
              color: iconColor.withValues(alpha: .11),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.px),
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(11.px),
                    ),
                    child: Icon(icon, color: iconColor, size: 1.9.h),
                  ),
                  horizontalSpace(width: 2.4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppStyles.semiboldTextStyle(context).copyWith(
                            fontSize: 13.8.sp,
                            color:
                                isDark ? AppColors.white : AppColors.textBlack,
                          ),
                        ),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              subtitle!,
                              style:
                                  AppStyles.regularTextStyle(context).copyWith(
                                fontSize: 13.0.sp,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _PushInkWell(
                    onTap: index == 1 && _isAlertAssignLoading
                        ? null
                        : () => _onPrimaryTap(context),
                    borderRadius: BorderRadius.circular(16),
                    pressedScale: 0.93,
                    pressedYOffset: 1.4,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.0.w, vertical: .78.h),
                      decoration: BoxDecoration(
                        color: AppColors.blueCyan.withValues(alpha: .70),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.blueCyan.withValues(alpha: .85),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blueCyan.withValues(alpha: .22),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          if (index == 1 && _isAlertAssignLoading)
                            SizedBox(
                              height: 1.75.h,
                              width: 1.75.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          else
                            Icon(
                              index == 0
                                  ? Icons.person_outline
                                  : index == 6
                                      ? Icons.chat_rounded
                                      : Icons.add_rounded,
                              size: 1.75.h,
                              color: Colors.white,
                            ),
                          horizontalSpace(width: .8.w),
                          Text(
                            actionText,
                            style:
                                AppStyles.semiboldTextStyle(context).copyWith(
                              fontSize: 13.0.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (index != 1) ...[
                verticalSpace(height: .9.h),
                if (index == 5)
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(vertical: .9.h, horizontal: 2.4.w),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: .05)
                          : const Color(0xFFF6F8FB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: .07)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                          ),
                          child: _PushInkWell(
                            onTap: () {
                              _showReminderListBottomSheet(
                                context,
                                deviceId: deviceId,
                                vehicleName: vehicleName,
                              );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: .8.h, horizontal: 1.2.w),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      activeReminderText,
                                      style: AppStyles.regularTextStyle(context)
                                          .copyWith(
                                        fontSize: 14.0.sp,
                                        color: isDark
                                            ? AppColors.white
                                            : AppColors.textBlack,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14.5.sp,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        verticalSpace(height: .75.h),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: .07)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                          ),
                          child: _PushInkWell(
                            onTap: () {
                              _showOldReminderHistoryBottomSheet(
                                context,
                                deviceId: deviceId,
                                vehicleName: vehicleName,
                              );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: .8.h, horizontal: 1.2.w),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      pastReminderText,
                                      style: AppStyles.regularTextStyle(context)
                                          .copyWith(
                                        fontSize: 14.0.sp,
                                        color: isDark
                                            ? AppColors.white
                                            : AppColors.textBlack,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14.5.sp,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  _PushInkWell(
                    onTap: () => _onBodyTap(context),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          vertical: 1.0.h, horizontal: 3.w),
                      decoration: BoxDecoration(
                        color: index == 0
                            ? AppColors.blueCyan.withValues(alpha: .70)
                            : (isDark
                                ? Colors.white.withValues(alpha: .05)
                                : const Color(0xFFF6F8FB)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bodyText,
                            style: AppStyles.regularTextStyle(context).copyWith(
                              fontSize: 13.5.sp,
                              color: index == 0
                                  ? AppColors.white
                                  : (isDark
                                      ? AppColors.white
                                      : AppColors.textBlack),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

void _showReminderListBottomSheet(
  BuildContext context, {
  required int deviceId,
  required String vehicleName,
}) {
  final theme = Theme.of(context);
  final onSurface = theme.colorScheme.onSurface;
  final l10n = context.l10n;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Consumer<ReminderProvider>(
        builder: (context, provider, _) {
          final now = DateTime.now();
          final activeReminders = provider.reminders
              .where((r) =>
                  r.deviceId == deviceId &&
                  (r.repeatType != "none" || !r.dueAt.isBefore(now)))
              .toList()
            ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
          final oldReminders = provider.reminders
              .where((r) =>
                  r.deviceId == deviceId &&
                  r.repeatType == "none" &&
                  r.dueAt.isBefore(now))
              .toList()
            ..sort((a, b) => b.dueAt.compareTo(a.dueAt));

          return Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 70.h, maxHeight: 70.h),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(4.w, 1.4.h, 4.w, 1.2.h),
              child: activeReminders.isEmpty
                  ? SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: 10.w,
                            height: .45.h,
                            decoration: BoxDecoration(
                              color: onSurface.withValues(alpha: .18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          verticalSpace(height: 1.2.h),
                          Text(
                            l10n.activeReminders,
                            style:
                                AppStyles.semiboldTextStyle(context).copyWith(
                              fontSize: 14.sp,
                              color: onSurface,
                            ),
                          ),
                          verticalSpace(height: .35.h),
                          Text(
                            vehicleName,
                            style: AppStyles.regularTextStyle(context).copyWith(
                              fontSize: 13.sp,
                              color: onSurface.withValues(alpha: .62),
                            ),
                          ),
                          verticalSpace(height: 2.2.h),
                          Text(
                            l10n.noActiveReminders,
                            style: AppStyles.regularTextStyle(context).copyWith(
                              fontSize: 13.8.sp,
                              color: onSurface.withValues(alpha: .65),
                            ),
                          ),
                          if (oldReminders.isNotEmpty) ...[
                            verticalSpace(height: 1.2.h),
                            SizedBox(
                              width: 45.w,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _showOldReminderHistoryBottomSheet(
                                    context,
                                    deviceId: deviceId,
                                    vehicleName: vehicleName,
                                  );
                                },
                                icon: const Icon(Icons.history_rounded),
                                label: Text(l10n.oldReminders),
                              ),
                            ),
                          ],
                          verticalSpace(height: 2.2.h),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          width: 10.w,
                          height: .45.h,
                          decoration: BoxDecoration(
                            color: onSurface.withValues(alpha: .18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        verticalSpace(height: 1.2.h),
                        Text(
                          l10n.activeReminders,
                          style: AppStyles.semiboldTextStyle(context).copyWith(
                            fontSize: 14.sp,
                            color: onSurface,
                          ),
                        ),
                        verticalSpace(height: .35.h),
                        Text(
                          vehicleName,
                          style: AppStyles.regularTextStyle(context).copyWith(
                            fontSize: 13.sp,
                            color: onSurface.withValues(alpha: .62),
                          ),
                        ),
                        verticalSpace(height: 1.2.h),
                        Expanded(
                          child: ListView.separated(
                            itemCount: activeReminders.length,
                            separatorBuilder: (_, __) =>
                                verticalSpace(height: .8.h),
                            itemBuilder: (_, index) {
                              final reminder = activeReminders[index];
                              return _ReminderTile(
                                reminder: reminder,
                                onEdit: () async {
                                  Navigator.pop(sheetContext);
                                  await showAddReminderPopup(
                                    context,
                                    deviceId: deviceId,
                                    vehicleName: vehicleName,
                                    existingReminder: reminder,
                                  );
                                },
                                onDelete: () async {
                                  final confirmed =
                                      await _confirmDeleteReminder(context);
                                  if (!confirmed) return;
                                  if (!context.mounted) return;
                                  await context
                                      .read<ReminderProvider>()
                                      .deleteReminder(reminder.id);
                                  AppSnackBar.success(
                                      message: l10n.reminderDeleted);
                                },
                              );
                            },
                          ),
                        ),
                        if (oldReminders.isNotEmpty) ...[
                          verticalSpace(height: .8.h),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _showOldReminderHistoryBottomSheet(
                                  context,
                                  deviceId: deviceId,
                                  vehicleName: vehicleName,
                                );
                              },
                              icon: const Icon(Icons.history_rounded),
                              label: Text(l10n.oldReminders),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          );
        },
      );
    },
  );
}

void _showOldReminderHistoryBottomSheet(
  BuildContext context, {
  required int deviceId,
  required String vehicleName,
}) {
  final theme = Theme.of(context);
  final onSurface = theme.colorScheme.onSurface;
  final l10n = context.l10n;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Consumer<ReminderProvider>(
        builder: (context, provider, _) {
          final now = DateTime.now();
          final oldReminders = provider.reminders
              .where((r) =>
                  r.deviceId == deviceId &&
                  r.repeatType == "none" &&
                  r.dueAt.isBefore(now))
              .toList()
            ..sort((a, b) => b.dueAt.compareTo(a.dueAt));

          return Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 70.h, maxHeight: 70.h),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(4.w, 1.4.h, 4.w, 1.2.h),
              child: oldReminders.isEmpty
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10.w,
                          height: .45.h,
                          decoration: BoxDecoration(
                            color: onSurface.withValues(alpha: .18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        verticalSpace(height: 1.2.h),
                        Text(
                          l10n.oldReminders,
                          style: AppStyles.semiboldTextStyle(context).copyWith(
                            fontSize: 14.sp,
                            color: onSurface,
                          ),
                        ),
                        verticalSpace(height: .35.h),
                        Text(
                          vehicleName,
                          style: AppStyles.regularTextStyle(context).copyWith(
                            fontSize: 13.sp,
                            color: onSurface.withValues(alpha: .62),
                          ),
                        ),
                        verticalSpace(height: 2.2.h),
                        Text(
                          l10n.noOldReminders,
                          style: AppStyles.regularTextStyle(context).copyWith(
                            fontSize: 13.8.sp,
                            color: onSurface.withValues(alpha: .65),
                          ),
                        ),
                        verticalSpace(height: 2.2.h),
                      ],
                    )
                  : Column(
                      children: [
                        Container(
                          width: 10.w,
                          height: .45.h,
                          decoration: BoxDecoration(
                            color: onSurface.withValues(alpha: .18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        verticalSpace(height: 1.2.h),
                        Text(
                          l10n.oldReminders,
                          style: AppStyles.semiboldTextStyle(context).copyWith(
                            fontSize: 14.sp,
                            color: onSurface,
                          ),
                        ),
                        verticalSpace(height: .35.h),
                        Text(
                          vehicleName,
                          style: AppStyles.regularTextStyle(context).copyWith(
                            fontSize: 13.sp,
                            color: onSurface.withValues(alpha: .62),
                          ),
                        ),
                        verticalSpace(height: 1.2.h),
                        Expanded(
                          child: ListView.separated(
                            itemCount: oldReminders.length,
                            separatorBuilder: (_, __) =>
                                verticalSpace(height: .8.h),
                            itemBuilder: (_, index) {
                              final reminder = oldReminders[index];
                              return _ReminderTile(
                                reminder: reminder,
                                onEdit: () async {
                                  Navigator.pop(sheetContext);
                                  await showAddReminderPopup(
                                    context,
                                    deviceId: deviceId,
                                    vehicleName: vehicleName,
                                    existingReminder: reminder,
                                  );
                                },
                                onDelete: () async {
                                  final confirmed =
                                      await _confirmDeleteReminder(context);
                                  if (!confirmed) return;
                                  if (!context.mounted) return;
                                  await context
                                      .read<ReminderProvider>()
                                      .deleteReminder(reminder.id);
                                  AppSnackBar.success(
                                      message: l10n.reminderDeleted);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      );
    },
  );
}

void _showExpenseListBottomSheet(
  BuildContext context, {
  required int deviceId,
  required String vehicleName,
}) {
  final theme = Theme.of(context);
  final onSurface = theme.colorScheme.onSurface;
  final l10n = context.l10n;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return ChangeNotifierProvider(
        create: (_) => DeviceExpenseProvider()..initialize(deviceId: deviceId),
        child: Consumer<DeviceExpenseProvider>(
          builder: (context, provider, _) {
            return Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 70.h, maxHeight: 70.h),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(4.w, 1.4.h, 4.w, 1.2.h),
                child: Column(
                  children: [
                    Container(
                      width: 10.w,
                      height: .45.h,
                      decoration: BoxDecoration(
                        color: onSurface.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    verticalSpace(height: 1.2.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.expenses,
                            style:
                                AppStyles.semiboldTextStyle(context).copyWith(
                              fontSize: 14.sp,
                              color: onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: provider.expenses.isEmpty
                              ? null
                              : () => _shareExpenseSummary(
                                    vehicleName: vehicleName,
                                    total: provider.total,
                                    items: provider.expenses,
                                  ),
                          icon: const Icon(Icons.ios_share_rounded),
                          tooltip: l10n.share,
                        ),
                      ],
                    ),
                    verticalSpace(height: .35.h),
                    Text(
                      vehicleName,
                      style: AppStyles.regularTextStyle(context).copyWith(
                        fontSize: 13.sp,
                        color: onSurface.withValues(alpha: .62),
                      ),
                    ),
                    verticalSpace(height: .5.h),
                    Text(
                      l10n.totalCurrencyRs(provider.total.toStringAsFixed(2)),
                      style: AppStyles.semiboldTextStyle(context).copyWith(
                        fontSize: 14.8.sp,
                        color: AppColors.green,
                      ),
                    ),
                    verticalSpace(height: .9.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.6.w, vertical: .8.h),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: .05)
                            : const Color(0xFFF7FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white10
                              : Colors.black12,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _PushInkWell(
                              onTap: () async {
                                final now = DateTime.now();
                                final today =
                                    DateTime(now.year, now.month, now.day);
                                final toBound = provider.toDate == null
                                    ? today
                                    : DateTime(
                                        provider.toDate!.year,
                                        provider.toDate!.month,
                                        provider.toDate!.day);
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      provider.fromDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate:
                                      toBound.isBefore(today) ? toBound : today,
                                );
                                if (picked == null) return;
                                if (!context.mounted) return;
                                await context
                                    .read<DeviceExpenseProvider>()
                                    .setDateRange(
                                      deviceId: deviceId,
                                      from: picked,
                                      to: provider.toDate,
                                    );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: .45.h),
                                child: Text(
                                  l10n.fromValue(
                                    provider.fromDate == null
                                        ? '-'
                                        : DateFormat('dd/MM/yyyy')
                                            .format(provider.fromDate!),
                                  ),
                                  style: AppStyles.regularTextStyle(context)
                                      .copyWith(
                                    fontSize: 13.8.sp,
                                    color: onSurface.withValues(alpha: .78),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          horizontalSpace(width: 2.w),
                          Expanded(
                            child: _PushInkWell(
                              onTap: () async {
                                final now = DateTime.now();
                                final today =
                                    DateTime(now.year, now.month, now.day);
                                final fromBound = provider.fromDate == null
                                    ? DateTime(2020)
                                    : DateTime(
                                        provider.fromDate!.year,
                                        provider.fromDate!.month,
                                        provider.fromDate!.day);
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      provider.toDate ?? DateTime.now(),
                                  firstDate: fromBound,
                                  lastDate: today,
                                );
                                if (picked == null) return;
                                if (!context.mounted) return;
                                await context
                                    .read<DeviceExpenseProvider>()
                                    .setDateRange(
                                      deviceId: deviceId,
                                      from: provider.fromDate,
                                      to: picked,
                                    );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: .45.h),
                                child: Text(
                                  l10n.toValue(
                                    provider.toDate == null
                                        ? '-'
                                        : DateFormat('dd/MM/yyyy')
                                            .format(provider.toDate!),
                                  ),
                                  style: AppStyles.regularTextStyle(context)
                                      .copyWith(
                                    fontSize: 13.8.sp,
                                    color: onSurface.withValues(alpha: .78),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await context
                                  .read<DeviceExpenseProvider>()
                                  .setDateRange(
                                    deviceId: deviceId,
                                    from: null,
                                    to: null,
                                  );
                            },
                            icon: Icon(
                              Icons.clear_rounded,
                              size: 17.sp,
                            ),
                            tooltip: l10n.clearDateFilter,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                    verticalSpace(height: 1.2.h),
                    if (provider.isLoading)
                      Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (provider.expenses.isEmpty)
                      Expanded(
                        child: Center(
                          child: Text(
                            l10n.noExpensesRecorded,
                            style: AppStyles.regularTextStyle(context).copyWith(
                              fontSize: 13.8.sp,
                              color: onSurface.withValues(alpha: .65),
                            ),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: provider.expenses.length,
                          separatorBuilder: (_, __) =>
                              verticalSpace(height: .8.h),
                          itemBuilder: (_, index) {
                            final expense = provider.expenses[index];
                            return _ExpenseListTile(
                              expense: expense,
                              fallbackType: provider.typeName(expense.typeId),
                              onEdit: () async {
                                final payload = await showExpenseFormDialog(
                                  context,
                                  deviceId: deviceId,
                                  initialExpense: expense,
                                );
                                if (payload == null) return;
                                if (!context.mounted) return;
                                await context
                                    .read<DeviceExpenseProvider>()
                                    .editExpense(
                                      deviceId: deviceId,
                                      expenseId: expense.id,
                                      typeId: payload.typeId,
                                      date: payload.date,
                                      quantity: payload.quantity,
                                      unitCost: payload.unitCost,
                                      name: payload.name,
                                      supplier: payload.supplier,
                                      comment: payload.comment,
                                    );
                              },
                              onDelete: () async {
                                final confirmed =
                                    await _confirmDeleteExpense(context);
                                if (!confirmed) return;
                                if (!context.mounted) return;
                                await context
                                    .read<DeviceExpenseProvider>()
                                    .deleteExpense(
                                      deviceId: deviceId,
                                      expenseId: expense.id,
                                    );
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

void _showServiceListBottomSheet(
  BuildContext context, {
  required int deviceId,
  required String vehicleName,
}) {
  final theme = Theme.of(context);
  final onSurface = theme.colorScheme.onSurface;
  final l10n = context.l10n;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return ChangeNotifierProvider(
        create: (_) => DeviceServiceProvider()..initialize(deviceId: deviceId),
        child: Consumer<DeviceServiceProvider>(
          builder: (context, provider, _) {
            return Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 70.h, maxHeight: 70.h),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(4.w, 1.4.h, 4.w, 1.2.h),
                child: Column(
                  children: [
                    Container(
                      width: 10.w,
                      height: .45.h,
                      decoration: BoxDecoration(
                        color: onSurface.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    verticalSpace(height: 1.2.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.maintenance,
                            style:
                                AppStyles.semiboldTextStyle(context).copyWith(
                              fontSize: 14.sp,
                              color: onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: provider.services.isEmpty
                              ? null
                              : () => _shareMaintenanceSummary(
                                    vehicleName: vehicleName,
                                    items: provider.services,
                                  ),
                          icon: const Icon(Icons.ios_share_rounded),
                          tooltip: l10n.share,
                        ),
                      ],
                    ),
                    verticalSpace(height: .35.h),
                    Text(
                      vehicleName,
                      style: AppStyles.regularTextStyle(context).copyWith(
                        fontSize: 13.sp,
                        color: onSurface.withValues(alpha: .62),
                      ),
                    ),
                    verticalSpace(height: .5.h),
                    Text(
                      l10n.totalLabel(provider.total),
                      style: AppStyles.semiboldTextStyle(context).copyWith(
                        fontSize: 14.8.sp,
                        color: AppColors.yellow,
                      ),
                    ),
                    verticalSpace(height: .9.h),
                    if (provider.isLoading)
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (provider.services.isEmpty)
                      Expanded(
                        child: Center(
                          child: Text(
                            l10n.noServicesRecorded,
                            style: AppStyles.regularTextStyle(context).copyWith(
                              fontSize: 13.8.sp,
                              color: onSurface.withValues(alpha: .65),
                            ),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: provider.services.length,
                          separatorBuilder: (_, __) =>
                              verticalSpace(height: .8.h),
                          itemBuilder: (_, index) {
                            final service = provider.services[index];
                            return _ServiceListTile(
                              service: service,
                              onEdit: () async {
                                final payload = await showServiceFormDialog(
                                  context,
                                  initialService: service,
                                );
                                if (payload == null) return;
                                if (!context.mounted) return;
                                await context
                                    .read<DeviceServiceProvider>()
                                    .editService(
                                      deviceId: deviceId,
                                      serviceId: service.id,
                                      name: payload.name,
                                      expirationBy: payload.expirationBy,
                                      interval: payload.interval,
                                      lastService: payload.lastService,
                                      triggerEventLeft:
                                          payload.triggerEventLeft,
                                      renewAfterExpiration:
                                          payload.renewAfterExpiration,
                                      expires: payload.expires,
                                      expiresDate: payload.expiresDate,
                                      remind: payload.remind,
                                      remindDate: payload.remindDate,
                                      email: payload.email,
                                      mobilePhone: payload.mobilePhone,
                                      description: payload.description,
                                    );
                              },
                              onDelete: () async {
                                final confirmed =
                                    await _confirmDeleteService(context);
                                if (!confirmed) return;
                                if (!context.mounted) return;
                                await context
                                    .read<DeviceServiceProvider>()
                                    .deleteService(
                                      deviceId: deviceId,
                                      serviceId: service.id,
                                    );
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

Future<void> _shareMaintenanceSummary({
  required String vehicleName,
  required List<DeviceService> items,
}) async {
  final fmt = DateFormat('dd MMM yyyy');
  final buffer = StringBuffer();
  buffer.writeln("Maintenance Summary");
  buffer.writeln("Vehicle: $vehicleName");
  buffer.writeln("Total Services: ${items.length}");
  buffer.writeln("");
  for (final item in items) {
    final expiresText =
        item.expiresDate == null ? "-" : fmt.format(item.expiresDate!);
    final remindText =
        item.remindDate == null ? "-" : fmt.format(item.remindDate!);
    final title = item.name.isEmpty ? "Service #${item.id}" : item.name;
    buffer.writeln("- $title");
    buffer.writeln(
        "  Type: ${item.expirationBy.isEmpty ? '-' : item.expirationBy} | Interval: ${item.interval.isEmpty ? '-' : item.interval} | Last: ${item.lastService.isEmpty ? '-' : item.lastService}");
    buffer.writeln(
        "  Expires: $expiresText | Remind: $remindText | Status: ${item.expired ? 'expired' : 'active'}");
    if (item.description.isNotEmpty) {
      buffer.writeln("  Notes: ${item.description}");
    }
  }
  await SharePlus.instance.share(ShareParams(text: buffer.toString()));
}

Future<void> _shareExpenseSummary({
  required String vehicleName,
  required double total,
  required List<DeviceExpense> items,
}) async {
  final fmt = DateFormat('dd MMM yyyy');
  final buffer = StringBuffer();
  buffer.writeln("Expense Summary");
  buffer.writeln("Vehicle: $vehicleName");
  buffer.writeln("Total Expense: Rs ${total.toStringAsFixed(2)}");
  buffer.writeln("Total Entries: ${items.length}");
  buffer.writeln("");
  for (final item in items) {
    final dateText = item.date == null ? "-" : fmt.format(item.date!);
    final typeText = item.typeName.trim().isEmpty ? "Unknown" : item.typeName;
    buffer.writeln("- $dateText | $typeText");
    buffer.writeln(
        "  Qty: ${item.quantity} | Unit: Rs ${item.unitCost.toStringAsFixed(2)} | Amount: Rs ${item.totalCost.toStringAsFixed(2)}");
    if (item.name.trim().isNotEmpty) {
      buffer.writeln("  Name: ${item.name}");
    }
    if (item.supplier.trim().isNotEmpty) {
      buffer.writeln("  Supplier: ${item.supplier}");
    }
    if (item.comment.trim().isNotEmpty) {
      buffer.writeln("  Notes: ${item.comment}");
    }
  }
  await SharePlus.instance.share(ShareParams(text: buffer.toString()));
}

Future<bool> _confirmDeleteExpense(BuildContext context) async {
  final l10n = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.deleteExpense),
      content: Text(l10n.deleteExpenseConfirmation),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<bool> _confirmDeleteService(BuildContext context) async {
  final l10n = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.deleteService),
      content: Text(l10n.deleteServiceConfirmation),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<bool> _confirmDeleteReminder(BuildContext context) async {
  final l10n = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.deleteReminder),
      content: Text(l10n.deleteReminderConfirmation),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  return result ?? false;
}

class _ExpenseListTile extends StatelessWidget {
  final DeviceExpense expense;
  final String fallbackType;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseListTile({
    required this.expense,
    required this.fallbackType,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final date = expense.date == null
        ? "-"
        : DateFormat('dd/MM/yyyy').format(expense.date!);
    final type = expense.typeName.isNotEmpty ? expense.typeName : fallbackType;
    final amount = expense.totalCost.toStringAsFixed(2);
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.0.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: .05)
            : const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  type,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: 14.8.sp,
                    color: onSurface,
                  ),
                ),
              ),
              _PushInkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(1.2.w),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 16.5.sp,
                    color: AppColors.blueCyan,
                  ),
                ),
              ),
              horizontalSpace(width: .8.w),
              _PushInkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(1.2.w),
                  child: Icon(
                    Icons.delete_rounded,
                    size: 16.8.sp,
                    color: AppColors.red,
                  ),
                ),
              ),
            ],
          ),
          verticalSpace(height: .35.h),
          Text(
            expense.name.trim().isEmpty
                ? l10n.noName
                : l10n.nameValue(expense.name),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 13.2.sp,
              color: onSurface.withValues(alpha: .72),
            ),
          ),
          verticalSpace(height: .25.h),
          Text(
            l10n.expenseQtyUnitRow(
              date,
              expense.quantity,
              expense.unitCost.toStringAsFixed(2),
            ),
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 13.8.sp,
              color: onSurface.withValues(alpha: .72),
            ),
          ),
          if (expense.supplier.trim().isNotEmpty) ...[
            verticalSpace(height: .2.h),
            Text(
              l10n.supplierValue(expense.supplier),
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: 13.8.sp,
                color: onSurface.withValues(alpha: .72),
              ),
            ),
          ],
          verticalSpace(height: .2.h),
          Text(
            l10n.amountCurrencyRs(amount),
            style: AppStyles.semiboldTextStyle(context).copyWith(
              fontSize: 13.4.sp,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceListTile extends StatelessWidget {
  final DeviceService service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceListTile({
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final expiresDate = service.expiresDate == null
        ? "-"
        : DateFormat('dd/MM/yyyy').format(service.expiresDate!);
    final remindDate = service.remindDate == null
        ? "-"
        : DateFormat('dd/MM/yyyy').format(service.remindDate!);
    final title = service.name.isEmpty
        ? context.l10n.serviceNumber(service.id)
        : service.name;
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.0.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: .05)
            : const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: 14.8.sp,
                    color: onSurface,
                  ),
                ),
              ),
              _PushInkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(1.2.w),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 16.5.sp,
                    color: AppColors.blueCyan,
                  ),
                ),
              ),
              horizontalSpace(width: .8.w),
              _PushInkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(1.2.w),
                  child: Icon(
                    Icons.delete_rounded,
                    size: 16.8.sp,
                    color: AppColors.red,
                  ),
                ),
              ),
            ],
          ),
          verticalSpace(height: .35.h),
          Text(
            l10n.typeValue(
              service.expirationBy.isEmpty ? '-' : service.expirationBy,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 13.2.sp,
              color: onSurface.withValues(alpha: .72),
            ),
          ),
          verticalSpace(height: .25.h),
          Text(
            l10n.intervalLastRow(
              service.interval.isEmpty ? '-' : service.interval,
              service.lastService.isEmpty ? '-' : service.lastService,
            ),
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 13.8.sp,
              color: onSurface.withValues(alpha: .72),
            ),
          ),
          verticalSpace(height: .2.h),
          Text(
            l10n.expiresRemindRow(expiresDate, remindDate),
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 13.8.sp,
              color: onSurface.withValues(alpha: .72),
            ),
          ),
          if (service.description.isNotEmpty) ...[
            verticalSpace(height: .2.h),
            Text(
              service.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: 13.8.sp,
                color: onSurface.withValues(alpha: .72),
              ),
            ),
          ],
          verticalSpace(height: .2.h),
          Text(
            l10n.currentOdometerEngineHoursRow(
              service.currentOdometer?.toString() ?? '-',
              service.currentEngineHours.isEmpty
                  ? '-'
                  : service.currentEngineHours,
            ),
            style: AppStyles.semiboldTextStyle(context).copyWith(
              fontSize: 13.4.sp,
              color: AppColors.yellow,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final LocalReminder reminder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReminderTile({
    required this.reminder,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    final dueDate = DateFormat('dd/MM/yyyy').format(reminder.dueAt);
    final dueTime = DateFormat('hh:mm a').format(reminder.dueAt);
    final description = reminder.description.trim();
    final repeatLabel = reminder.repeatType == "none"
        ? context.l10n.repeatOneTime
        : "${context.l10n.repeatRecurring} • ${_prettyRepeat(context, reminder.repeatType)}";

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.0.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: .05)
            : const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "${reminder.vehicleName} - ${reminder.title}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: 13.8.sp,
                    color: onSurface,
                  ),
                ),
              ),
              _PushInkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(1.2.w),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 16.5.sp,
                    color: AppColors.blueCyan,
                  ),
                ),
              ),
              horizontalSpace(width: .8.w),
              _PushInkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(1.2.w),
                  child: Icon(
                    Icons.delete_rounded,
                    size: 16.8.sp,
                    color: AppColors.red,
                  ),
                ),
              ),
            ],
          ),
          verticalSpace(height: .35.h),
          Text(
            description.isEmpty ? context.l10n.noDescription : description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 13.5.sp,
              color: onSurface.withValues(alpha: .74),
            ),
          ),
          verticalSpace(height: .28.h),
          Text(
            repeatLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 13.6.sp,
              fontWeight: FontWeight.w600,
              color: reminder.repeatType == "none"
                  ? onSurface.withValues(alpha: .62)
                  : AppColors.blueCyan,
            ),
          ),
          verticalSpace(height: .55.h),
          Row(
            children: [
              Icon(Icons.event_rounded,
                  size: 14.5.sp, color: AppColors.blueCyan),
              horizontalSpace(width: 1.2.w),
              Text(
                dueDate,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: 13.7.sp,
                  color: onSurface.withValues(alpha: .8),
                ),
              ),
              horizontalSpace(width: 3.w),
              Icon(Icons.access_time_rounded,
                  size: 14.5.sp, color: AppColors.blueCyan),
              horizontalSpace(width: 1.2.w),
              Text(
                dueTime,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: 13.7.sp,
                  color: onSurface.withValues(alpha: .8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _prettyRepeat(BuildContext context, String repeatType) {
    switch (repeatType) {
      case "daily":
        return context.l10n.daily;
      case "weekly":
        return context.l10n.weekly;
      case "monthly":
        return context.l10n.monthly;
      case "yearly":
        return context.l10n.yearly;
      default:
        return repeatType;
    }
  }
}
