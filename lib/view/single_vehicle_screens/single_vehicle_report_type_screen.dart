import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/app/theme/responsive_scale.dart';
import 'package:trackerapp/data/models/get_device_reports_model.dart';
import 'package:trackerapp/data/models/initial_reports.dart';
import 'package:trackerapp/providers/get_device_reports_provider.dart';
import 'package:trackerapp/providers/get_geofence_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/utils/app_validation_dialog.dart';
import 'package:trackerapp/view/view_report_screen.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/widgets/single_vehicle_common/single_vehicle_date_filter_widgets.dart';

class SingleReportTypesScreen extends StatefulWidget {
  final int deviceId;
  final String deviceTitle;

  const SingleReportTypesScreen({
    super.key,
    required this.deviceId,
    required this.deviceTitle,
  });

  @override
  State<SingleReportTypesScreen> createState() =>
      _SingleReportTypesScreenState();
}

class _SingleReportTypesScreenState extends State<SingleReportTypesScreen> {
  int _selectedFilterIndex = 0;
  bool _showMoreReports = false;
  bool _showDateRangePicker = false;

  String fromDate = '';
  String toDate = '';
  String fromTime = '12:00:00 AM';
  String toTime = '11:59:59 PM';

  final List<Map<String, dynamic>> filters = const [
    {"label": "Today", "icon": Icons.today_rounded},
    {"label": "Yesterday", "icon": Icons.history_toggle_off_rounded},
    {"label": "Last 7 Days", "icon": Icons.date_range_rounded},
    {"label": "Last 30 Days", "icon": Icons.calendar_month_rounded},
    {"label": "Custom", "icon": Icons.edit_calendar_rounded},
  ];

  String _filterLabel(BuildContext context, int index) {
    final l10n = context.l10n;
    switch (index) {
      case 0:
        return l10n.today;
      case 1:
        return l10n.yesterday;
      case 2:
        return l10n.last7Days;
      case 3:
        return l10n.last30Days;
      case 4:
        return l10n.custom;
      default:
        return filters[index]["label"] as String;
    }
  }

  @override
  void initState() {
    super.initState();
    _applyFilter(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ReportTypeProvider>().fetchReportsType();
    });
  }

  void _applyFilter(int index) {
    setState(() {
      _selectedFilterIndex = index;
      _showDateRangePicker = index == 4;
    });

    if (index == 4) {
      return;
    }

    final now = DateTime.now();
    final dateFmt = DateFormat("yyyy-MM-dd");
    final timeFmt = DateFormat("hh:mm:ss a");

    switch (index) {
      case 0:
        fromDate = toDate = dateFmt.format(now);
        fromTime = '12:00:00 AM';
        toTime = timeFmt.format(now);
        break;
      case 1:
        final y = now.subtract(const Duration(days: 1));
        fromDate = toDate = dateFmt.format(y);
        fromTime = '12:00:00 AM';
        toTime = '11:59:59 PM';
        break;
      case 2:
        fromDate = dateFmt.format(now.subtract(const Duration(days: 6)));
        toDate = dateFmt.format(now);
        fromTime = '12:00:00 AM';
        toTime = '11:59:59 PM';
        break;
      case 3:
        fromDate = dateFmt.format(now.subtract(const Duration(days: 29)));
        toDate = dateFmt.format(now);
        fromTime = '12:00:00 AM';
        toTime = '11:59:59 PM';
        break;
    }

    setState(() {});
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime? _tryParseApiDate(String value) {
    if (value.isEmpty) return null;
    try {
      return _dateOnly(DateFormat('yyyy-MM-dd').parse(value));
    } catch (_) {
      return null;
    }
  }

  bool _isValidDateRangeStrings(String from, String to) {
    final fromDt = _tryParseApiDate(from);
    final toDt = _tryParseApiDate(to);
    if (fromDt == null || toDt == null) return false;
    return !fromDt.isAfter(toDt);
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

  String _formatDateDisplay(String apiDate) {
    if (apiDate.isEmpty) return '--/--/----';
    try {
      final parsed = DateFormat('yyyy-MM-dd').parse(apiDate);
      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (_) {
      return apiDate;
    }
  }

  String _formatTimeDisplay(String value) {
    if (value.isEmpty) return '--:--';
    try {
      final parsed = DateFormat('hh:mm:ss a').parse(value);
      return DateFormat('hh:mm a').format(parsed);
    } catch (_) {
      return value;
    }
  }

  void _generateReport({
    required int type,
    required String name,
    required String reportFormat,
    int speed = 0,
    int minutes = 0,
    List<int> geofences = const [],
    int stops = 0,
    bool showAddresses = false,
    bool zonesInstead = false,
  }) {
    if (fromDate.isEmpty || toDate.isEmpty) {
      showValidationErrorDialog(
        context,
        message: context.l10n.pleaseSelectDateRangeFirst,
      );
      return;
    }
    if (!_isValidDateRangeStrings(fromDate, toDate)) {
      showValidationErrorDialog(
        context,
        message: context.l10n.fromDateCannotBeLaterThanToDate,
      );
      return;
    }

    final data = ViewReportInitialData(
      fromDate: fromDate,
      toDate: toDate,
      fromTime: fromTime,
      toTime: toTime,
      deviceId: widget.deviceId,
      reportType: type,
      reportFormat: reportFormat,
      reportName: name,
      speedLimit: speed,
      ignitionOff: minutes,
      geofences: geofences,
      stops: stops,
      showAddresses: showAddresses,
      zonesInstead: zonesInstead,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewReportScreen(reportData: data, reportName: name),
      ),
    );
  }

  List<String> _normalizedFormats(ReportTypeItem item) {
    return (item.formats ?? const <dynamic>[])
        .map((e) => e.toString().trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> _normalizedFields(ReportTypeItem item) {
    return (item.fields ?? const <dynamic>[])
        .map((e) => e.toString().trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  String _defaultFormatForReport(int type, List<String> formats) {
    if (formats.isEmpty) {
      return type == 43 ? 'html' : 'pdf';
    }
    if (type == 43 && formats.contains('html')) return 'html';
    if (formats.contains('pdf')) return 'pdf';
    if (formats.contains('pdf_land')) return 'pdf_land';
    if (formats.contains('html')) return 'html';
    return formats.first;
  }

  String _fieldLabel(String key) {
    switch (key) {
      case 'speed_limit':
        return 'Speed Limit (km/h)';
      case 'ignition_off':
        return 'Ignition Off Duration (min)';
      case 'stops':
        return 'Stops (minutes)';
      case 'geofences':
        return 'Geofence IDs (comma separated)';
      case 'show_addresses':
        return 'Show Addresses';
      case 'zones_instead':
        return 'Zones Instead';
      default:
        return key.replaceAll('_', ' ');
    }
  }

  Future<void> _showDynamicReportOptionsDialog(ReportTypeItem item) async {
    final type = item.type ?? 0;
    final name = item.name ?? '';
    final formats = _normalizedFormats(item);
    final fields = _normalizedFields(item);

    final needsSpeed = fields.contains('speed_limit') || type == 5;
    final needsIgnitionOff = fields.contains('ignition_off') || type == 30;
    final needsStops = fields.contains('stops');
    final needsGeofences = fields.contains('geofences') || type == 7;
    final needsShowAddresses = fields.contains('show_addresses');
    final needsZonesInstead = fields.contains('zones_instead');

    final hasOptions = formats.length > 1 ||
        needsSpeed ||
        needsIgnitionOff ||
        needsStops ||
        needsGeofences ||
        needsShowAddresses ||
        needsZonesInstead;

    if (!hasOptions) {
      _generateReport(
        type: type,
        name: name,
        reportFormat: _defaultFormatForReport(type, formats),
      );
      return;
    }

    final speedCtrl = TextEditingController();
    final ignitionOffCtrl = TextEditingController();
    final stopsCtrl = TextEditingController();
    var selectedFormat = _defaultFormatForReport(type, formats);
    var showAddresses = false;
    var zonesInstead = false;
    final selectedGeofenceIds = <int>{};

    if (needsGeofences) {
      final geofenceProvider = context.read<GeofenceProvider>();
      if (!geofenceProvider.isLoading && geofenceProvider.model == null) {
        await geofenceProvider.fetchGeofence(
          isRefresh: false,
          context: context,
        );
        if (!mounted) return;
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              backgroundColor: isDark ? const Color(0xFF1A2433) : Colors.white,
              child: Padding(
                padding: EdgeInsets.fromLTRB(4.w, 1.8.h, 4.w, 1.6.h),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppStyles.semiboldTextStyle(ctx)
                            .copyWith(fontSize: 15.sp),
                      ),
                      verticalSpace(height: 1.h),
                      if (formats.length > 1) ...[
                        DropdownButtonFormField<String>(
                          initialValue: selectedFormat,
                          decoration: const InputDecoration(
                            labelText: 'Format',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          items: formats
                              .map(
                                (f) => DropdownMenuItem<String>(
                                  value: f,
                                  child: Text(f.toUpperCase()),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setLocalState(() => selectedFormat = v);
                          },
                        ),
                        verticalSpace(height: 1.h),
                      ],
                      if (needsSpeed) ...[
                        TextField(
                          controller: speedCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: _fieldLabel('speed_limit'),
                            isDense: true,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        verticalSpace(height: 1.h),
                      ],
                      if (needsIgnitionOff) ...[
                        TextField(
                          controller: ignitionOffCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: _fieldLabel('ignition_off'),
                            isDense: true,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        verticalSpace(height: 1.h),
                      ],
                      if (needsStops) ...[
                        TextField(
                          controller: stopsCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: _fieldLabel('stops'),
                            isDense: true,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        verticalSpace(height: 1.h),
                      ],
                      if (needsGeofences) ...[
                        Text(
                          _fieldLabel('geofences'),
                          style: AppStyles.semiboldTextStyle(ctx)
                              .copyWith(fontSize: 12.8.sp),
                        ),
                        verticalSpace(height: .4.h),
                        Consumer<GeofenceProvider>(
                          builder: (_, geofenceProvider, __) {
                            if (geofenceProvider.isLoading) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final geofences =
                                geofenceProvider.model?.geofences ?? const [];
                            if (geofences.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(2.4.w),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.black26,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      geofenceProvider.errorMessage ??
                                          'No geofences found',
                                      style: TextStyle(
                                        fontSize: 11.8.sp,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                    verticalSpace(height: .8.h),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          geofenceProvider.fetchGeofence(
                                            isRefresh: true,
                                            context: context,
                                          );
                                        },
                                        icon: const Icon(Icons.refresh_rounded),
                                        label: const Text('Reload Geofences'),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Container(
                              constraints: BoxConstraints(maxHeight: 24.h),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      isDark ? Colors.white24 : Colors.black26,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: geofences.length,
                                itemBuilder: (_, index) {
                                  final geofence = geofences[index];
                                  final checked =
                                      selectedGeofenceIds.contains(geofence.id);
                                  return CheckboxListTile(
                                    dense: true,
                                    value: checked,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    onChanged: (v) {
                                      setLocalState(() {
                                        if (v == true) {
                                          selectedGeofenceIds.add(geofence.id);
                                        } else {
                                          selectedGeofenceIds
                                              .remove(geofence.id);
                                        }
                                      });
                                    },
                                    title: Text(
                                      geofence.name,
                                      style: TextStyle(fontSize: 12.2.sp),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        if (selectedGeofenceIds.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: .6.h),
                            child: Text(
                              '${selectedGeofenceIds.length} geofence(s) selected',
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                color: ConstantColor.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        verticalSpace(height: 1.h),
                      ],
                      if (needsShowAddresses)
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(_fieldLabel('show_addresses')),
                          value: showAddresses,
                          onChanged: (v) =>
                              setLocalState(() => showAddresses = v),
                        ),
                      if (needsZonesInstead)
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(_fieldLabel('zones_instead')),
                          value: zonesInstead,
                          onChanged: (v) =>
                              setLocalState(() => zonesInstead = v),
                        ),
                      if (fields.isNotEmpty)
                        Text(
                          'Fields: ${fields.where((f) => f != 'metas' && f != 'devices').map(_fieldLabel).join(', ')}',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      verticalSpace(height: 1.2.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ConstantColor.primaryColor,
                              ),
                              onPressed: () {
                                final speed =
                                    int.tryParse(speedCtrl.text.trim()) ?? 0;
                                final ignitionOff =
                                    int.tryParse(ignitionOffCtrl.text.trim()) ??
                                        0;
                                final stops =
                                    int.tryParse(stopsCtrl.text.trim()) ?? 0;
                                final geofences =
                                    selectedGeofenceIds.toList(growable: false);

                                Navigator.pop(ctx);
                                _generateReport(
                                  type: type,
                                  name: name,
                                  reportFormat: selectedFormat,
                                  speed: speed,
                                  minutes: ignitionOff,
                                  geofences: geofences,
                                  stops: stops,
                                  showAddresses: showAddresses,
                                  zonesInstead: zonesInstead,
                                );
                              },
                              child: const Text('Generate'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _onReportTap(ReportTypeItem item) {
    _showDynamicReportOptionsDialog(item);
  }

  @override
  Widget build(BuildContext context) {
    final textScale = appTextScale(context, ScaleProfile.reportType);
    final iconScale = appIconScale(context, ScaleProfile.reportType);
    final provider = context.watch<ReportTypeProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0E1624) : AppColors.white,
      body: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: IconTheme(
          data: IconTheme.of(context).copyWith(size: 24 * iconScale),
          child: Padding(
            padding: EdgeInsets.fromLTRB(4.w, .6.h, 4.w, 1.2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(height: .3.h),
                SingleVehicleDateFilterBar(
                  filterLabels: List.generate(
                      filters.length, (i) => _filterLabel(context, i)),
                  selectedFilterIndex: _selectedFilterIndex,
                  showDateRangePicker: _showDateRangePicker,
                  rangeText:
                      "${_formatDateDisplay(fromDate)} ${_formatTimeDisplay(fromTime)}  ->  ${_formatDateDisplay(toDate)} ${_formatTimeDisplay(toTime)}",
                  onFilterTap: _applyFilter,
                  onDateRangeTap: () {
                    setState(() {
                      _selectedFilterIndex = 4;
                      _showDateRangePicker = !_showDateRangePicker;
                    });
                  },
                ),
                if (_showDateRangePicker) ...[
                  verticalSpace(height: 1.h),
                  SingleVehicleDateRangePickerCard(
                    fromDateTitle: l10n.fromDate,
                    toDateTitle: l10n.toDate,
                    fromTimeTitle: l10n.fromTime,
                    toTimeTitle: l10n.toTime,
                    selectDateLabel: l10n.selectDate,
                    selectTimeLabel: l10n.selectTime,
                    applyLabel: l10n.applyRange,
                    fromDateValue: _formatDateDisplay(fromDate),
                    toDateValue: _formatDateDisplay(toDate),
                    fromTimeValue: _formatTimeDisplay(fromTime),
                    toTimeValue: _formatTimeDisplay(toTime),
                    onFromDateTap: () async {
                      final currentTo =
                          _tryParseApiDate(toDate) ?? DateTime.now();
                      final picked = await _pickDate(
                        fromDate.isEmpty
                            ? DateTime.now()
                            : DateFormat('yyyy-MM-dd').parse(fromDate),
                        maxDate: currentTo,
                      );
                      if (picked != null) {
                        setState(() =>
                            fromDate = DateFormat('yyyy-MM-dd').format(picked));
                      }
                    },
                    onToDateTap: () async {
                      final currentFrom =
                          _tryParseApiDate(fromDate) ?? DateTime(2020);
                      final picked = await _pickDate(
                        toDate.isEmpty
                            ? DateTime.now()
                            : DateFormat('yyyy-MM-dd').parse(toDate),
                        minDate: currentFrom,
                        maxDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() =>
                            toDate = DateFormat('yyyy-MM-dd').format(picked));
                      }
                    },
                    onFromTimeTap: () async {
                      final picked = await _pickTime(_parseTimeOfDay(fromTime));
                      if (picked != null) {
                        final now = DateTime.now();
                        final dt = DateTime(now.year, now.month, now.day,
                            picked.hour, picked.minute);
                        setState(() =>
                            fromTime = DateFormat('hh:mm:ss a').format(dt));
                      }
                    },
                    onToTimeTap: () async {
                      final picked = await _pickTime(_parseTimeOfDay(toTime));
                      if (picked != null) {
                        final now = DateTime.now();
                        final dt = DateTime(now.year, now.month, now.day,
                            picked.hour, picked.minute);
                        setState(
                            () => toTime = DateFormat('hh:mm:ss a').format(dt));
                      }
                    },
                    onApply: () {
                      if (fromDate.isEmpty || toDate.isEmpty) {
                        showValidationErrorDialog(
                          context,
                          message: 'Please select both dates',
                        );
                        return;
                      }
                      if (!_isValidDateRangeStrings(fromDate, toDate)) {
                        showValidationErrorDialog(
                          context,
                          message: l10n.fromDateCannotBeLaterThanToDate,
                        );
                        return;
                      }
                      setState(() => _showDateRangePicker = false);
                    },
                  ),
                ],
                verticalSpace(height: 1.h),
                Expanded(
                  child: Builder(
                    builder: (_) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.errorMessage != null) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 58, color: Colors.grey),
                              SizedBox(height: 1.h),
                              Text(provider.errorMessage!),
                              verticalSpace(height: .8.h),
                              ElevatedButton(
                                  onPressed: provider.retry,
                                  child: const Text('Retry')),
                            ],
                          ),
                        );
                      }

                      if (provider.itemsMain.isEmpty &&
                          provider.itemsOther.isEmpty) {
                        return const Center(
                            child: Text('No reports available'));
                      }

                      return ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          Text(
                            "Report Types",
                            style:
                                AppStyles.semiboldTextStyle(context).copyWith(
                              fontSize: 14.sp,
                              color: isDark
                                  ? AppColors.white
                                  : AppColors.textBlack,
                            ),
                          ),
                          verticalSpace(height: .8.h),
                          GridView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.55,
                              crossAxisSpacing: 2.8.w,
                              mainAxisSpacing: 1.h,
                            ),
                            itemCount: provider.itemsMain.length,
                            itemBuilder: (_, i) => _ReportCard(
                              title: provider.itemsMain[i].name ?? '',
                              type: provider.itemsMain[i].type ?? 0,
                              onTap: () => _onReportTap(provider.itemsMain[i]),
                            ),
                          ),
                          if (provider.itemsOther.isNotEmpty) ...[
                            verticalSpace(height: 1.h),
                            OutlinedButton.icon(
                              onPressed: () => setState(
                                  () => _showMoreReports = !_showMoreReports),
                              icon: Icon(
                                _showMoreReports
                                    ? Icons.expand_less_rounded
                                    : Icons.expand_more_rounded,
                              ),
                              label: Text(_showMoreReports
                                  ? 'Show Less'
                                  : 'More Reports'),
                            ),
                            if (_showMoreReports)
                              ...provider.itemsOther.map(
                                (item) => Container(
                                  margin: EdgeInsets.only(bottom: .8.h),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: .06)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: isDark
                                            ? Colors.white12
                                            : Colors.black12),
                                  ),
                                  child: ListTile(
                                    leading: Icon(Icons.description_outlined,
                                        color: ConstantColor.primaryColor),
                                    title: Text(
                                      item.name ?? '',
                                      style:
                                          AppStyles.semiboldTextStyle(context)
                                              .copyWith(
                                        fontSize: 12.8.sp,
                                      ),
                                    ),
                                    trailing:
                                        const Icon(Icons.chevron_right_rounded),
                                    onTap: () => _onReportTap(item),
                                  ),
                                ),
                              ),
                          ],
                          verticalSpace(height: 1.h),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TimeOfDay? _parseTimeOfDay(String value) {
    if (value.isEmpty) return null;
    try {
      final dt = DateFormat('hh:mm:ss a').parse(value);
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {
      return null;
    }
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final int type;
  final VoidCallback onTap;

  const _ReportCard(
      {required this.title, required this.onTap, required this.type});

  IconData _resolveIcon() {
    if (title == 'Daily Travel Report') return Icons.calendar_today_rounded;
    if (title == 'Travel Summary with Playback Image') {
      return Icons.play_circle_fill_rounded;
    }
    if (title == 'Travel Summary') return Icons.map_rounded;
    if (title == 'Stops Move Summary') return Icons.directions_car_rounded;
    if (title == 'Events') return Icons.warning_rounded;
    return Icons.history_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const reportAccent = Color(0xFFE0A800);
    final iconColor = reportAccent.withValues(alpha: isDark ? .28 : .24);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.6.w, vertical: 1.1.h),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: .06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? .16 : .06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -1.0.w,
              bottom: -.25.h,
              child: Icon(
                _resolveIcon(),
                size: 42.sp,
                color: iconColor,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                type == 8
                    ? 'Alerts Report'
                    : type == 3
                        ? 'Trip Report'
                        : title,
                textAlign: TextAlign.left,
                style: AppStyles.semiboldTextStyle(context).copyWith(
                  fontSize: 13.9.sp,
                  color: isDark ? Colors.white : Colors.grey.shade800,
                  height: 1.15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
