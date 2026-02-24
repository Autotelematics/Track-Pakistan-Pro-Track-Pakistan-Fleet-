import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/data/models/initial_reports.dart';
import 'package:trackerapp/providers/get_device_reports_provider.dart';
import 'package:trackerapp/view/view_report_screen.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
class SingleReportTypesScreen extends StatefulWidget {
  final int deviceId;
  final String deviceTitle;

  const SingleReportTypesScreen({
    super.key,
    required this.deviceId,
    required this.deviceTitle,
  });
  @override
  State<SingleReportTypesScreen> createState() => _SingleReportTypesScreenState();
}

class _SingleReportTypesScreenState extends State<SingleReportTypesScreen> {
  int _selectedFilterIndex = 0;
  bool _showMoreReports = false;

  String fromDate = '';
  String toDate = '';
  String fromTime = '12:00:00 AM';
  String toTime = '';

  final List<Map<String, dynamic>> filters = [
    {"label": "Today", "icon": Icons.today},
    {"label": "Yesterday", "icon": Icons.calendar_today},
    {"label": "Week", "icon": Icons.date_range},
    {"label": "Month", "icon": Icons.calendar_month},
    {"label": "Custom", "icon": Icons.edit_calendar},
  ];
  @override
  void initState() {
    super.initState();
    _applyFilter(0);
    Future.microtask(
        () => context.read<ReportTypeProvider>().fetchReportsType());
  }

  void _applyFilter(int index) async {
    setState(() => _selectedFilterIndex = index);

    final now = DateTime.now();
    final fmt = DateFormat("yyyy-MM-dd");
    final timeFmt = DateFormat("hh:mm:ss a");

    switch (index) {
      case 0:
        fromDate = toDate = fmt.format(now);
        toTime = timeFmt.format(now);
        break;
      case 1:
        final y = now.subtract(const Duration(days: 1));
        fromDate = toDate = fmt.format(y);
        toTime = '11:59:59 PM';
        break;
      case 2:
        fromDate = fmt.format(now.subtract(const Duration(days: 6)));
        toDate = fmt.format(now);
        toTime = timeFmt.format(now);
        break;
      case 3:
        fromDate = fmt.format(now.subtract(const Duration(days: 29)));
        toDate = fmt.format(now);
        toTime = timeFmt.format(now);
        break;
      case 4:
        await _pickCustomRange();
        if (fromDate.isEmpty) _applyFilter(0);
        return;
    }
    setState(() {});
  }

  Future<void> _pickCustomRange() async {
    final fmt = DateFormat("yyyy-MM-dd");
    final timeFmt = DateFormat("hh:mm:ss a");

    final from = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (from == null) return;

    final to = await showDatePicker(
      context: context,
      initialDate: from,
      firstDate: from,
      lastDate: DateTime.now(),
    );
    if (to == null) return;

    setState(() {
      fromDate = fmt.format(from);
      toDate = fmt.format(to);
      toTime = timeFmt.format(DateTime.now());
    });
  }

  void _generateReport(int type, String name,
      {int speed = 0, int minutes = 0}) {
    if (fromDate.isEmpty || toDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date range')),
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
      reportFormat: type == 43 ? 'html' : 'pdf',
      reportName: name,
      speedLimit: speed,
      ignitionOff: minutes,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ViewReportScreen(reportData: data, reportName: name)),
    );
  }

  void _showInputDialog({
    required String title,
    required IconData icon,
    required String label,
    required Function(int) onConfirm,
  }) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        icon: Icon(icon),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                Navigator.pop(ctx);
                onConfirm(val);
              }
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _onReportTap(dynamic item) {
    final type = item.type ?? 0;
    final name = item.name ?? '';

    if (type == 5) {
      _showInputDialog(
        title: 'Speed Limit',
        icon: Icons.speed,
        label: 'Speed Limit (km/h)',
        onConfirm: (speed) => _generateReport(type, name, speed: speed),
      );
    } else if (type == 30) {
      _showInputDialog(
        title: 'Duration',
        icon: Icons.timer,
        label: 'Minimum Duration (minutes)',
        onConfirm: (mins) => _generateReport(type, name, minutes: mins),
      );
    } else if (type == 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geofence selection coming soon')),
      );
    } else {
      _generateReport(type, name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportTypeProvider>();

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          children: [
            verticalSpace(height: 8.h),
            SizedBox(
              height: 4.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: filters.length,
                itemBuilder: (ctx, i) => Padding(
                  padding: EdgeInsets.only(right: 2.w),
                  child: FilterChip(
                    labelPadding: EdgeInsets.zero,
                    label: Text(filters[i]['label']),
                    selected: _selectedFilterIndex == i,
                    onSelected: (_) => _applyFilter(i),
                    // Selected styling
                    selectedColor: ConstantColor.primaryColor,
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: _selectedFilterIndex == i
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: _selectedFilterIndex == i
                          ? ConstantColor.primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),
            verticalSpace(height: 1.5.h),
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('From: $fromDate',
                            style: TextStyle(fontSize: 14.sp)),
                        const Icon(Icons.arrow_forward, size: 18),
                        Text('To: $toDate', style: TextStyle(fontSize: 14.sp)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            verticalSpace(height: 1.5.h),
            Expanded(
              child: Builder(builder: (_) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.errorMessage != null) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 60, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(provider.errorMessage!),
                      ElevatedButton(
                          onPressed: provider.retry,
                          child: const Text('Retry')),
                    ],
                  );
                }
                if (provider.itemsMain.isEmpty && provider.itemsOther.isEmpty) {
                  return const Center(child: Text('No reports available'));
                }

                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.6,
                        crossAxisSpacing: 4.w,
                        mainAxisSpacing: 2.h,
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
                      ElevatedButton.icon(
                        onPressed: () => setState(
                            () => _showMoreReports = !_showMoreReports),
                        icon: Icon(_showMoreReports
                            ? Icons.expand_less
                            : Icons.expand_more),
                        label: Text(
                            _showMoreReports ? 'Show Less' : 'More Reports'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(5), // 5px radius
                          ),
                        ),
                      ),
                      if (_showMoreReports)
                        ...provider.itemsOther.map((item) => Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Icon(
                                  Icons.description,
                                  color: ConstantColor.primaryColor,
                                ),
                                title: Text(
                                  item.name ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _onReportTap(item),
                              ),
                            )),
                    ],
                    verticalSpace(height: 4.h),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final int type;
  final VoidCallback onTap;

  const _ReportCard(
      {required this.title, required this.onTap, required this.type});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                title == "Daily Travel Report"
                    ? Icons.calendar_today_rounded
                    : title == "Travel Summary with Playback Image"
                        ? Icons.play_circle_filled_rounded
                        : title == "Travel Summary"
                            ? Icons.map_rounded
                            : title == "Stops Move Summary"
                                ? Icons.directions_car_rounded
                                : title == "Events"
                                    ? Icons.warning_rounded
                                    : Icons.history_rounded,
                size: 28.sp,
                color: ConstantColor.primaryColor),
            verticalSpace(height: 1.h),
            Text(
              type == 8
                  ? "Alerts Report"
                  : type == 3
                      ? "Trip Report"
                      : title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
