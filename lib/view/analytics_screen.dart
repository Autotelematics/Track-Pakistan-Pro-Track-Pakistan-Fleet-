import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final surface = theme.cardColor;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final primary = theme.colorScheme.primary;
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return Scaffold(
          backgroundColor: scaffoldBg,
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(theme, onSurface, onSurfaceVariant, surface),
                  SizedBox(height: 3.h),
                  _buildSectionTitle(onSurface, "Yesterday"),
                  SizedBox(height: 1.h),
                  _buildAnalyticsRow(onSurface, "0.3 ltr.", "49 Pkr", "19.41 km"),
                  SizedBox(height: 3.h),
                  _buildSectionTitle(onSurface, "Past 7 days"),
                  SizedBox(height: 1.h),
                  _buildAnalyticsRow(onSurface, "4.65 ltr.", "697 Pkr", "279 km"),
                  SizedBox(height: 3.h),
                  _buildSectionTitle(onSurface, "Past 4 Weeks Money Spent (Pkr)"),
                  SizedBox(height: 1.h),
                  _buildFourWeeksCard(theme, onSurface, surface, primary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ---------------- Section Title ----------------
  Widget _buildSectionTitle(Color onSurface, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.bold,
        color: onSurface,
      ),
    );
  }

  /// ---------------- Current Status Card ----------------
  Widget _buildStatusCard(ThemeData theme, Color onSurface, Color onSurfaceVariant, Color surface) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(3.w),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 6, backgroundColor: Colors.red),
                  SizedBox(width: 2.w),
                  Text(
                    "Stopped - Ignition On 1 hr 18 min ago",
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: onSurface),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("Track Here",
                    style: TextStyle(fontSize: 13.5.sp, color: Colors.white)),
              )
            ],
          ),

          Divider(height: 3.h, thickness: 0.8, color: onSurfaceVariant),
          _buildInfoRow(onSurfaceVariant, onSurface, "Your Speed is", "0 km/h at 7:42 PM"),
          SizedBox(height: 1.h),
          _buildInfoRow(onSurfaceVariant, onSurface, "Since 12 am", "39.6 km driven"),
          SizedBox(height: 1.h),
          _buildInfoRow(onSurfaceVariant, onSurface, "Spent", "99 pkr, consumed 0.7 ltr."),

          SizedBox(height: 1.5.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.local_gas_station, color: Colors.green),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  "Do you know that you burn 0.48 liters of fuel every day",
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: onSurface),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(Color labelColor, Color valueColor, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(fontSize: 15.sp, color: labelColor)),
        Text(value,
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: valueColor)),
      ],
    );
  }

  /// ---------------- Analytics Row ----------------
  Widget _buildAnalyticsRow(Color onSurface, String fuel, String cost, String distance) {
    return Row(
      children: [
        Expanded(
            child: _buildAnalyticsCircle(onSurface, Icons.local_gas_station, Colors.green, fuel)),
        Expanded(
            child: _buildAnalyticsCircle(onSurface, Icons.payments, Colors.orange, cost)),
        Expanded(
            child: _buildAnalyticsCircle(onSurface, Icons.location_on, Colors.blue, distance)),
      ],
    );
  }

  Widget _buildAnalyticsCircle(Color onSurface, IconData icon, Color color, String value) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3)),
          child: Icon(icon, color: color, size: 22.sp),
        ),
        SizedBox(height: 1.h),
        Text(value,
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: onSurface),
            textAlign: TextAlign.center),
      ],
    );
  }

  /// ---------------- Past 4 Weeks ----------------
  Widget _buildFourWeeksCard(ThemeData theme, Color onSurface, Color surface, Color primary) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(2.5.w),
      decoration: _cardDecoration(theme),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.only(left: 4.w),
              height: 26.h,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  barTouchData: BarTouchData(enabled: false),
                  maxY: 700,
                  titlesData: FlTitlesData(
                    leftTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return _weekTitle(onSurface, "25 Apr - 02 May", "Week 1");
                            case 1:
                              return _weekTitle(onSurface, "02 May - 09 May", "Week 2");
                            case 2:
                              return _weekTitle(onSurface, "09 May - 16 May", "Week 3");
                            case 3:
                              return _weekTitle(onSurface, "16 May - 23 May", "Week 4");
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _makeGroupData(0, 477),
                    _makeGroupData(1, 615),
                    _makeGroupData(2, 34),
                    _makeGroupData(3, 697),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _totalBox(onSurface, "12.2 ltr.", Colors.green, Icons.local_gas_station),
                SizedBox(height: 1.2.h),
                _totalBox(onSurface, "1823 Pkr", Colors.orange, Icons.payments),
                SizedBox(height: 1.2.h),
                _totalBox(onSurface, "729.33 km", Colors.blue, Icons.location_on),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _totalBox(Color onSurface, String value, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 0.5.h),
          Text(value,
              style: TextStyle(
                  fontSize: 15.sp, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
        toY: y,
        width: 20, // wider bar for exact look
        color: Colors.blue,
        borderRadius: BorderRadius.circular(6),
      )
    ]);
  }

  Widget _weekTitle(Color onSurface, String range, String week) {
    return Column(
      children: [
        Text(range,
            style: TextStyle(fontSize: 11.sp, color: onSurface.withOpacity(0.6)),
            textAlign: TextAlign.center),
        Text(week,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: onSurface)),
      ],
    );
  }

  BoxDecoration _cardDecoration(ThemeData theme) {
    return BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(2, 2),
        ),
      ],
    );
  }
}