import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';

class ReportTypesScreen extends StatefulWidget {
  const ReportTypesScreen({
    super.key,
  });

  @override
  State<ReportTypesScreen> createState() => _ReportTypesScreenState();
}

class _ReportTypesScreenState extends State<ReportTypesScreen> {
  final TextEditingController _speedLimitController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  int? _selectedMinutes;
  bool _showMoreReports = false;

  final List<Map<String, dynamic>> prioritizedItems = [
    {"type": 1, "name": "Map Report", "icon": Icons.map_rounded},
    {"type": 3, "name": "Trip Report", "icon": Icons.directions_car_rounded},
    {"type": 34, "name": "Speed Report", "icon": Icons.speed_rounded},
    {"type": 7, "name": "Geofence Report", "icon": Icons.location_on_rounded},
    {"type": 25, "name": "History Report", "icon": Icons.history_rounded},
    {"type": 43, "name": "Playback Report", "icon": Icons.play_circle_fill_rounded},
    {"type": 48, "name": "Calendar Report", "icon": Icons.calendar_today_rounded},
    {"type": 8, "name": "Alerts Report", "icon": Icons.warning_rounded},
  ];

  final List<Map<String, dynamic>> otherItems = [
    {"type": 5, "name": "Speed Limit Report"},
    {"type": 30, "name": "Idle Duration Report"},
    {"type": 50, "name": "Fuel Usage Report"},
    {"type": 60, "name": "Distance Travelled Report"},
  ];

  void _dummyNavigate(String reportName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Opening $reportName (dummy)", style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
    );
  }

  void _showSpeedLimitDialog(String reportName) {
    _speedLimitController.clear();
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => Theme(
        data: theme.copyWith(dialogBackgroundColor: theme.cardColor),
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.sp)),
          title: Text("Enter Speed Limit", style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface)),
          content: TextField(
            controller: _speedLimitController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            cursorColor: theme.colorScheme.primary,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Speed Limit (km/h)",
              labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.sp)),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(8.sp),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(8.sp),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text("Cancel", style: TextStyle(color: theme.colorScheme.onSurface))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.sp)),
                  backgroundColor: AppColors.blueCyan
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _dummyNavigate(reportName);
              },
              child: const Text("Generate Report", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showMinutesSelectionDialog(String reportName) {
    _minutesController.clear();
    _selectedMinutes = null;
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => Theme(
        data: theme.copyWith(dialogBackgroundColor: theme.cardColor),
        child: StatefulBuilder(
          builder: (context, dialogSetState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.sp)),
            title: Text("Enter Duration", style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface)),
            content: TextField(
              controller: _minutesController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              cursorColor: theme.colorScheme.primary,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Duration (Minutes)",
                labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.sp)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                  borderRadius: BorderRadius.circular(8.sp),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(8.sp),
                ),
              ),
              onChanged: (value) => dialogSetState(() => _selectedMinutes = int.tryParse(value)),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text("Cancel", style: TextStyle(color: theme.colorScheme.onSurface))
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.sp)),
                    backgroundColor: AppColors.blueCyan
                ),
                onPressed: _selectedMinutes != null && _selectedMinutes! > 0
                    ? () {
                  Navigator.pop(dialogContext);
                  _dummyNavigate(reportName);
                }
                    : null,
                child: const Text("Generate Report", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speedLimitController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final cardColor = theme.cardColor;
    final primary = theme.colorScheme.primary;
    final outline = theme.colorScheme.outline;
    final surface = theme.colorScheme.surface;

    final _dialogBorder = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.sp));
    final _buttonBorder = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.sp));
    final _cardDecoration = BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(10.sp),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(2, 2))],
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(3.w),
            padding: EdgeInsets.all(2.w),
            decoration: _cardDecoration,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.directions_car, color: AppColors.blueCyan),
                  SizedBox(width: 1.w),
                  Text("AAT-829", style: TextStyle(fontSize: 14.sp, color: onSurface)),
                ]),
                Row(children: [
                  Icon(Icons.calendar_month, color: onSurface),
                  SizedBox(width: 1.w),
                  Text("From: 12-10-2025", style: TextStyle(fontSize: 13.sp, color: onSurface)),
                ]),
                Row(children: [
                  Icon(Icons.calendar_month, color: onSurface),
                  SizedBox(width: 1.w),
                  Text("To: 12-10-2025", style: TextStyle(fontSize: 13.sp, color: onSurface)),
                ]),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Prioritized Grid
                  Padding(
                    padding: EdgeInsets.only(left: 4.w,right: 4.w, bottom: 1.h),
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 4.w,
                        mainAxisSpacing: 1.h,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: prioritizedItems.length,
                      itemBuilder: (context, index) {
                        final item = prioritizedItems[index];
                        return GestureDetector(
                          onTap: () {
                            if (item["type"] == 5) {
                              _showSpeedLimitDialog(item["name"]);
                            } else if (item["type"] == 30) {
                              _showMinutesSelectionDialog(item["name"]);
                            } else {
                              _dummyNavigate(item["name"]);
                            }
                          },
                          child: Container(
                            decoration: _cardDecoration,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(item["icon"], size: 28.sp, color: AppColors.blueCyan),
                                SizedBox(height: 1.h),
                                Text(item["name"], style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: onSurface)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // See More button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueCyan, shape: _buttonBorder),
                    onPressed: () => setState(() => _showMoreReports = !_showMoreReports),
                    child: Text(_showMoreReports ? "Show Less" : "See More",
                        style: const TextStyle(color: Colors.white)),
                  ),
                  if (_showMoreReports)
                    Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        children: otherItems.map((item) {
                          return GestureDetector(
                            onTap: () {
                              if (item["type"] == 5) {
                                _showSpeedLimitDialog(item["name"]);
                              } else if (item["type"] == 30) {
                                _showMinutesSelectionDialog(item["name"]);
                              } else {
                                _dummyNavigate(item["name"]);
                              }
                            },
                            child: Container(
                              decoration: _cardDecoration,
                              margin: EdgeInsets.only(bottom: 2.h),
                              padding: EdgeInsets.all(3.w),
                              child: Row(
                                children: [
                                  Icon(Icons.report, color: primary),
                                  SizedBox(width: 3.w),
                                  Expanded(child: Text(item["name"], style: TextStyle(fontSize: 14.sp, color: onSurface))),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}