import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/res/components/custom_widgets.dart';
import 'package:trackerapp/utils/constant_colors.dart';
import 'package:trackerapp/utils/constant_styles.dart';

class NewDashboard extends StatefulWidget {
  const NewDashboard({super.key});

  @override
  State<NewDashboard> createState() => _NewDashboardState();
}

class _NewDashboardState extends State<NewDashboard> {
  int touchedIndex = -1;

  final List<Map<String, dynamic>> chartData = [
    {
      "color": ConstantColors.green,
      "value": 50.0,
      "label": "Running (50)",
      "percent": "17%"
    },
    {
      "color": ConstantColors.yellow,
      "value": 120.0,
      "label": "Idle (120)",
      "percent": "40%"
    },
    {
      "color": ConstantColors.red,
      "value": 80.0,
      "label": "Stopped (80)",
      "percent": "27%"
    },
    {
      "color": ConstantColors.grey,
      "value": 50.0,
      "label": "Not Connected (50)",
      "percent": "16%"
    },
  ];
  final List<String> alertsSvg = [
    'assets/svgs/overspeed.svg',
    'assets/svgs/stop.svg',
    'assets/svgs/idle.svg',
    'assets/svgs/geofence.svg',
    'assets/svgs/running.svg',
    'assets/svgs/fuel.svg',
  ];
  final List<String> alertsName = [
    'Overspeed',
    'Stop Duration',
    'Idle',
    'Geofencing (In/Out)',
    'Running Duration',
    'Fuel',
  ];
  final List<String> daysOfWeek = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
  List<String> alertsUnit = [
    "Times",
    "Times",
    "Times",
    "Times",
    "Mins",
    "Times"
  ];



  List<String> alertsValue = ["6", "4", "3", "8", "120", "2"];

  List<Color> alertsBgColor = [
    Color(0xFFFFC107), // Yellow
    Color(0xFFEF5350), // Red
    Color(0xFFFF9800), // Orange
    Color(0xFF2196F3), // Blue
    Color(0xFFEF5350), // Red again
    Color(0xFF009688), // Teal
  ];

// Data for Distance Travelled
  final List<int> distanceData = [60, 40, 50, 50, 90]; // Dec 2 to Dec 6
  final int totalDistance = 3000; // km
  final double averageDistance = 956.27; // km
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _headerStack(),
            verticalSpace(height: 1.h),
            _alertFilterRow(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w,vertical: 2.h),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: alertsName.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          spreadRadius: 0,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: alertsBgColor[index],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: SvgPicture.asset(
                                alertsSvg[index],
                                height: 24,
                                width: 24,
                                color: Colors.white,
                              ),
                            ),
                            horizontalSpace(width: 1.h),
                            Expanded(
                              child: Text(
                                alertsName[index],
                                style: ConstantTextStyles.boldTextStyle.copyWith(
                                  color: ConstantColors.textBlack,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: .5.h),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${alertsValue[index]}  ',
                                  style: ConstantTextStyles.boldTextStyle.copyWith(
                                    color: ConstantColors.textBlack,
                                    fontSize: 17.sp,
                                  ),
                                ),
                                TextSpan(
                                  text: alertsUnit[index],
                                  style: ConstantTextStyles.regularTextStyle.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 6.w),
              margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 6.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    spreadRadius: 0,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Maintenance Reminder",
                    style: ConstantTextStyles.boldTextStyle.copyWith(
                      color: ConstantColors.textBlack,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  verticalSpace(height: 1.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.orange, size: 20.sp),
                      horizontalSpace(width: 3.w),
                      Expanded(
                        child: Text(
                          "Due",
                          style:ConstantTextStyles.regularTextStyle.copyWith(color: ConstantColors.textBlack,fontWeight: FontWeight.w700,fontSize: 15.sp)
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 1.h,vertical: .5.h),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE6F4FF),
                            borderRadius: BorderRadius.circular(50)
                        ),
                        child: Text(
                            "6",
                            style:ConstantTextStyles.regularTextStyle.copyWith(color: ConstantColors.textBlack,fontWeight: FontWeight.w700,fontSize: 14.sp)
                        ),
                      ),
                      horizontalSpace(width: 1.h),
                      Icon(Icons.arrow_forward_ios_rounded, size: 18.sp, color: Colors.grey),
                    ],
                  ),
                  verticalSpace(height: 1.h),

                  Divider(),
                  verticalSpace(height: 1.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.red, size: 20.sp),
                      horizontalSpace(width: 3.w),
                      Expanded(
                        child: Text(
                            "Overdue",
                            style:ConstantTextStyles.regularTextStyle.copyWith(color: ConstantColors.textBlack,fontWeight: FontWeight.w700,fontSize: 15.sp)
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 1.h,vertical: .5.h),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE6F4FF),
                            borderRadius: BorderRadius.circular(50)
                        ),
                        child: Text(
                            "256",
                            style:ConstantTextStyles.regularTextStyle.copyWith(color: ConstantColors.textBlack,fontWeight: FontWeight.w700,fontSize: 14.sp)
                        ),
                      ),
                      horizontalSpace(width: 1.h),
                      Icon(Icons.arrow_forward_ios_rounded, size: 18.sp, color: Colors.grey),
                    ],
                  ),

                ],
              ),
            ),
            _distanceTravelledSection(),
            buildAlertsGraphView(),
            buildExpenseCardView(),
            verticalSpace(height: 5.h)


          ],
        ),
      ),
    );
  }


  Widget _headerStack() {
    return SizedBox(
      height: 48.h,
      width: 100.w,
      child: Stack(
        children: [
          _header(),
          Positioned(
            top: 24.h,
            left: 5.w,
            right: 5.w,
            child: _vehicleSummaryCard(),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      height: 38.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ConstantColors.purple, ConstantColors.blueCyan],
        ),
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(38),
          bottomLeft: Radius.circular(38),
        ),
        boxShadow: [
          BoxShadow(
            color: ConstantColors.white.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          verticalSpace(height: 7.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 3.h,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=2670&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                    fit: BoxFit.cover,
                    height: 7.h,
                    width: 7.h,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.settings, size: 3.h, color: ConstantColors.white),
                  horizontalSpace(width: 5.w),
                  Icon(Icons.notifications,
                      size: 3.h, color: ConstantColors.white),
                ],
              )
            ],
          ),
          verticalSpace(height: 1.h),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text("Good Afternoon",
                style: ConstantTextStyles.regularTextStyle
                    .copyWith(fontSize: 16.sp)),
            subtitle: Text("Alex Bahadur Nepali",
                style: ConstantTextStyles.boldTextStyle),
          ),
        ],
      ),
    );
  }

  Widget _vehicleSummaryCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: ConstantColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _vehicleLegend(),
          const Spacer(),
          _vehicleChart(),
          horizontalSpace(width: 5.w),
        ],
      ),
    );
  }

  Widget _vehicleLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Total Vehicles", style: ConstantTextStyles.regularTextStyle),
        Text("300",
            style: TextStyle(
                color: ConstantColors.textColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w900)),
        verticalSpace(height: 1.h),
        ...chartData.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 1.h),
              child: _legendRow(item['color'], item['label']),
            )),
      ],
    );
  }

  Widget _vehicleChart() {
    return SizedBox(
      height: 10.h,
      width: 10.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, pieTouchResponse) {
                  setState(() {
                    touchedIndex =
                        pieTouchResponse?.touchedSection?.touchedSectionIndex ??
                            -1;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: _buildPieSections(),
            ),
          ),
          Text("300",
              style: ConstantTextStyles.boldTextStyle
                  .copyWith(color: ConstantColors.textBlack)),
        ],
      ),
    );
  }

  Widget _legendRow(Color color, String label) {
    return Row(
      children: [
        Container(
          height: 2.5.h,
          width: 1.6.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        horizontalSpace(width: 1.5.w),
        Text(label, style: ConstantTextStyles.lightTextStyle),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    return List.generate(chartData.length, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 60.0 : 30.0;
      return PieChartSectionData(
        color: chartData[i]['color'],
        value: chartData[i]['value'],
        title: chartData[i]['percent'],
        showTitle: false,
        radius: radius,
      );
    });
  }
  Widget _distanceTravelledSection() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Distance Travelled",
                style: ConstantTextStyles.boldTextStyle.copyWith(
                  color: ConstantColors.textBlack,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.calendar_today_outlined, size: 14, color: Colors.blue),
                    SizedBox(width: 6),
                    Text(
                      'This week (Sun–Today)',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpace(height: 1.2.h),

          /// Total Distance
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:  [
                  Text(
                    "Total Distance",
                    style:ConstantTextStyles.regularTextStyle.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    "3000 km",
                    style: ConstantTextStyles.lightTextStyle.copyWith(fontSize: 15.sp,fontWeight: FontWeight.w700),
                  ),
                ],
              ),

              /// Average Distance
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:  [
                  Text(
                    "Average Distance",
                    style:ConstantTextStyles.regularTextStyle.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    "956.27 km",
                    style: ConstantTextStyles.lightTextStyle.copyWith(fontSize: 15.sp,fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
          verticalSpace(height: 0.4.h),

          verticalSpace(height: 2.h),

          /// Bar Chart
          SizedBox(
            height: 220, // or use: 18.h if you're using Sizer
            child: BarChart(
              BarChartData(
                maxY: 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        const days = ['Dec 2', 'Dec 3', 'Dec 4', 'Dec 5', 'Dec 6'];
                        return SideTitleWidget(
                          meta: meta,
                          space: 8.0,
                          child: Text(
                            days[value.toInt()],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),

                // ✅ Grid Lines – horizontal & vertical
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: true,
                  horizontalInterval: 20,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  ),
                ),

                borderData: FlBorderData(show: false),

                // ✅ Bar groups (data)
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: 65,
                        width: 18,
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: 48,
                        width: 18,
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: 56,
                        width: 18,
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barRods: [
                      BarChartRodData(
                        toY: 55,
                        width: 18,
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 4,
                    barRods: [
                      BarChartRodData(
                        toY: 90,
                        width: 18,
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _alertFilterRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Row(
        children: [
          Text(
            "Alerts Count",
            style: ConstantTextStyles.boldTextStyle.copyWith(
              color: ConstantColors.textBlack,
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          horizontalSpace(width: 4.w),
          PopupMenuButton(
            position: PopupMenuPosition.under,
            onSelected: (value) {
              // You can add filter logic here
            },
            itemBuilder: (context) => daysOfWeek
                .map((day) => PopupMenuItem<String>(
                      value: day,
                      child: Text(day),
                    ))
                .toList(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: .3.h),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.calendar_today_outlined,
                      size: 16, color: Colors.blue),
                  SizedBox(width: 6),
                  Text(
                    'This week (Sun–Today)',
                    style: TextStyle(color: Colors.blue),
                  ),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.blue),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget buildAlertsGraphView() {
    final List<_DummyAlertData> dummyData = [
      _DummyAlertData(label: 'BA C AB 0123', value: 24, total: 100),
      _DummyAlertData(label: 'B AB 0123', value: 2, total: 100),
      _DummyAlertData(label: 'G AB 0123', value: 40, total: 100),
      _DummyAlertData(label: 'BA 1 GHA 3456', value: 20, total: 100),
      _DummyAlertData(label: 'BA 1 GHA 3456', value: 24, total: 100),
    ];

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Fleet Alerts",
                style: ConstantTextStyles.boldTextStyle.copyWith(
                  color: ConstantColors.textBlack,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.calendar_today_outlined, size: 14, color: Colors.blue),
                    SizedBox(width: 6),
                    Text(
                      'This week (Sun–Today)',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpace(height: 1.2.h),

          Column(
            children: dummyData.map((data) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.label,
                      style:ConstantTextStyles.regularTextStyle.copyWith(color: ConstantColors.textBlack,fontSize: 15.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: LinearProgressIndicator(
                            value: data.value / data.total,
                            backgroundColor: Colors.grey.shade300,
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                            minHeight: 6,
                          ),
                        ),
                         horizontalSpace(width: 4.w),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${data.value}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        horizontalSpace(width: 2.w),

                         Icon(Icons.chevron_right, size: 20.sp),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  Widget buildExpenseCardView() {
    final List<_ExpenseData> expenseList = [
      _ExpenseData(label: 'BA C AB 0123', amount: 12000.00),
      _ExpenseData(label: 'B AB 0123', amount: 11000.00),
      _ExpenseData(label: 'G AB 0123', amount: 10000.00),
      _ExpenseData(label: 'BA 1 GHA 3456', amount: 9000.00),
      _ExpenseData(label: 'BA 1 GHA 3456', amount: 500.00),
    ];

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Expense",
                style: ConstantTextStyles.boldTextStyle.copyWith(
                  color: ConstantColors.textBlack,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.calendar_today_outlined, size: 14, color: Colors.blue),
                    SizedBox(width: 6),
                    Text(
                      'This week (Sun–Today)',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          verticalSpace(height: 1.2.h),
          const SizedBox(height: 16),
          Column(
            children: expenseList.map((data) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Text(
                          data.label,
                          style:ConstantTextStyles.regularTextStyle.copyWith(color: ConstantColors.textBlack.withOpacity(0.6),fontSize: 15.sp),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Rs. ${data.amount.toStringAsFixed(2)}",
                              style:ConstantTextStyles.regularTextStyle.copyWith(color: ConstantColors.textBlack,fontSize: 15.sp),

                            ),
                            horizontalSpace(width: 2.w),
                             Icon(Icons.chevron_right, size: 20.sp),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(thickness: 0.4),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }



}
class _ExpenseData {
  final String label;
  final double amount;

  _ExpenseData({required this.label, required this.amount});
}

class _DummyAlertData {
  final String label;
  final int value;
  final int total;

  _DummyAlertData({
    required this.label,
    required this.value,
    this.total = 100,
  });
}

