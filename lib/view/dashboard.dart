import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackerapp/data/globalsharedveriables.dart';
import 'package:trackerapp/data/response/status.dart';
import 'package:trackerapp/models/devices_model.dart';
import 'package:trackerapp/models/events_intitial_data.dart';
import 'package:trackerapp/res/colors.dart';
import 'package:trackerapp/utils/routes/routes_name.dart';
import 'package:trackerapp/view_model/device_view_viewmodel.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trackerapp/view_model/event_view_model.dart';
import 'package:trackerapp/view_model/expnese_record_view_model.dart';
import 'package:trackerapp/view_model/vehicle_maintenance_view_model.dart';
import 'package:video_player/video_player.dart';
import 'home.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  final DeviceViewViewModel deviceViewViewModel = DeviceViewViewModel();
  final Map<String, EventViewModel> eventViewModels = {
    for (var type in [
      'all',
      'overspeed',
      'geofence',
      'custom',
      'stop_duration',
      'idle_duration',
      'excess_drive'
    ])
      type: EventViewModel(),
  };
   final ExpenseRecordViewModel expenseViewModel = ExpenseRecordViewModel();
  final VehicleMaintenanceViewModel maintenanceViewModel =
  VehicleMaintenanceViewModel();
  VideoPlayerController? _controller;
  int runningCount = 0,
      stoppedCount = 0,
      idleCount = 0,
      offlineCount = 0,
      noDataCount = 0,
      expiredCount = 0;
  String selectedView = "Graph View",
      selectedDuration = "Today",
      selectedAlertsView = "Graph View"; // Changed to Table View
  List<DevicesModel> groupList = [];
  List<dynamic> devicesList = [];
  List<_ChartData> vehicleStatusData = [];
  List<_AlertChartData> alertData = [];
  TooltipBehavior? _tooltip;
  ScrollController? _scrollController;
  AnimationController? _animationController;
  Animation<double>? _animation;
  Timer? _timer;
  final DateFormat dateFormat = DateFormat("yy-MM-dd");
  String fromDate = '', toDate = '';
  bool isGraphView = true,
      isAlertsGraphView = false; // Changed to false for TableView default

  final List<Color> vehicleStatusColors = const [
    Color(0xFF4CAF50), // Green
    Color(0xFFdd4848), // Red
    Color(0xFFFFA726), // Orange
    Color(0xFF42A5F5), // Blue
    Color(0xFFB0BEC5), // Grey
    Color(0xFF8D6E63), // Brown
  ];

  final TextStyle headingStyle = const TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54);
  final List<ChartData> chartData = List.generate(
    49,
        (i) => ChartData(
      [
        'pak',
        'ind',
        'wes',
        'ban',
        'us',
        'indo',
        'uk',
        'can',
        'aus',
        'nz',
        'sa',
        'ger',
        'fra',
        'ita',
        'spa',
        'por',
        'bra',
        'arg',
        'chi',
        'jap',
        'kor',
        'tha',
        'mal',
        'sin',
        'phi',
        'vie',
        'ind2',
        'sri',
        'nep',
        'bhutan',
        'myan',
        'lao',
        'cam',
        'rus',
        'uae',
        'qat',
        'kuw',
        'saudi',
        'egy',
        'mor',
        'alg',
        'tun',
        'nig',
        'ken',
        'gha',
        'zam',
        'zimb',
        'nam',
        'bot'
      ][i],
      [
        50,
        80,
        100,
        60,
        30,
        60,
        30,
        70,
        90,
        40,
        55,
        75,
        65,
        45,
        85,
        35,
        95,
        50,
        70,
        60,
        80,
        40,
        55,
        75,
        45,
        65,
        90,
        30,
        50,
        70,
        60,
        80,
        40,
        95,
        55,
        75,
        45,
        85,
        65,
        35,
        70,
        50,
        60,
        80,
        40,
        55,
        75,
        45,
        65
      ][i]
          .toDouble(),
    ),
  );
  final List<RetentionData> data1 = [
    RetentionData('Feb', 40, 60),
    RetentionData('Mar', 50, 50),
    RetentionData('Apr', 45, 55),
    RetentionData('May', 60, 40),
    RetentionData('Jun', 55, 45),
    RetentionData('Jul', 50, 50),
    RetentionData('Aug', 40, 60),
  ];

  List<LinearGradient> _getVehicleStatusGradients() {
    return const [
      LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFFF5CF5D),
          Color(0xFFF4B702)
        ], // Total Alerts (Running)
      ),
      LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF8E65FF), Colors.deepPurple], // Geofence (Stopped)
      ),
      LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF66C6F2), Colors.blueAccent], // Excess Idle (Idle)
      ),
      LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFFF96464), Colors.red], // Ignition on/off (Offline)
      ),
      LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFFB0BEC5), Color(0xFFECEFF1)], // No Data
      ),
      LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF8D6E63), Color(0xFFBCAAA4)], // Expired
      ),
    ];
  }

// Header Gradient
  LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF0288D1), Color(0xFF26A69A)],
  );
  List<LinearGradient> _getAlertGradients() {
    return const [
      LinearGradient(
          colors: [Color(0xFFF5CF5D), Color(0xFFF4B702)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft),
      LinearGradient(
          colors: [Color(0xFF8E65FF), Color(0xFF7E57C2)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft),
      LinearGradient(
          colors: [Color(0xFF8E65FF), Color(0xFF7E57C2)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft),
      LinearGradient(
          colors: [Color(0xFF66C6F2), Color(0xFF42A5F5)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft),
      LinearGradient(
          colors: [Color(0xFF66C6F2), Color(0xFF42A5F5)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft),
      LinearGradient(
          colors: [Color(0xFFF96464), Color(0xFFE57373)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft),
      LinearGradient(
          colors: [Color(0xFFF96464), Color(0xFFE57373)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft),
    ];
  }

  Future<void> saveDefaultFuelAverage(
      List<Map<String, dynamic>> vehicles) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (var vehicle in vehicles) {
        final key = 'fuelAverage_${vehicle['id']}';
        if (prefs.getDouble(key) == null) await prefs.setDouble(key, 13.0);
      }
    } catch (e) {
      debugPrint('Error saving fuel average: $e');
    }
  }

  void setDeviceStatusCounts(List<dynamic> devices) {
    vehicleNames.clear();
    vehiclesNamesIdMap.clear();
    runningCount = stoppedCount =
        idleCount = offlineCount = noDataCount = expiredCount = 0;
    for (var device in devices) {
      vehicleNames.add(device['name']?.toString() ?? 'Unknown');
      vehiclesNamesIdMap.add({
        'id': device['id']?.toString() ?? '',
        'name': device['name']?.toString() ?? 'Unknown'
      });
      final status = (device['online']?.toString() ?? '').toLowerCase();
      final time = (device['time']?.toString() ?? '').toLowerCase();
      switch (status) {
        case 'ack':
          stoppedCount++;
          break;
        case 'online':
          runningCount++;
          break;
        case 'offline' when time != 'not connected':
          offlineCount++;
          break;
        case 'offline' when time == 'not connected':
          noDataCount++;
          break;
        case 'engine':
          idleCount++;
          break;
        default:
          if (time == 'expired') expiredCount++;
      }
    }
  }

  late List<_ChartData> data;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    data = [
      _ChartData('CHN', 12),
      _ChartData('GER', 15),
      _ChartData('RUS', 30),
      _ChartData('BRZ', 64),
      _ChartData('IND', 14)
    ];
    _tooltip = TooltipBehavior(enable: true);
    _animationController =
    AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..repeat();
    _animation =
    Tween<double>(begin: 0, end: 2000).animate(_animationController!)
      ..addListener(() {
        if (_scrollController?.hasClients ?? false) {
          _scrollController!.jumpTo(_animation!.value);
        }
      });
    _animationController?.forward();

    expenseViewModel.fetchExpenseRecordsForVehicle('');
    maintenanceViewModel.fetchVehicleMaintenanceList('');
    deviceViewViewModel.getDeviceDataListFromApi();

    final now = DateTime.now();
    fromDate = dateFormat.format(now);
    toDate = dateFormat.format(now.add(const Duration(days: 1)));

    _tooltip = TooltipBehavior(enable: true);
    vehicleStatusData = [
      _ChartData('Running', 1),
      _ChartData('Stopped', 1),
      _ChartData('Idle', 1),
      _ChartData('Offline', 1),
    ];
    alertData = [
      _AlertChartData(
        'Total Alerts', 0, Icons.notifications_active_outlined,),
      _AlertChartData('Geofence', 0, Icons.fence_outlined),
      _AlertChartData('Overspeed', 0, Icons.speed),
      _AlertChartData('Excess Idle', 0, Icons.pause),
      _AlertChartData('Excess Driving', 0, Icons.drive_eta),
      _AlertChartData('Ignition on/off', 0, Icons.key),
      _AlertChartData('Parked', 0, Icons.local_parking_outlined),
    ];

    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      deviceViewViewModel.getDeviceDataListFromApi();
      eventViewModels.forEach((key, model) {
        model.fetchEventsAlertsFromApi(
            '', key == 'all' ? '' : key, fromDate, toDate, '');
      });
    });

    eventViewModels.forEach((key, model) {
      model.fetchEventsAlertsFromApi(
          '', key == 'all' ? '' : key, fromDate, toDate, '');
    });

    _controller = VideoPlayerController.networkUrl(
        Uri.parse('http://103.31.82.31/images/appvideo.mp4'))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _controller?.setLooping(true);
            _controller?.play();
          });
        }
      });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _scrollController?.dispose();
    _controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              // _buildCardHeader(
              //     'Vehicle Status', selectedView, ['Graph View',],
              //         (value) {
              //       setState(() {
              //         selectedView = value ?? '';
              //         isGraphView = value == 'Graph View';
              //       });
              //     }),
              const SizedBox(height: 10),
              _buildVehicleStatusCard(),
              const SizedBox(height: 10),
              _buildCardHeader('Region Data', selectedDuration, [
                'Today',
                'yesterday',
                'Last 3 days',
                'Last 7 days'
              ], (value) {
                setState(() => selectedDuration = value ?? '');
              }),
              const SizedBox(height: 10),
              _buildRegionDataCard(),
              const SizedBox(height: 10),
              _buildCardHeader(
                  'Alerts', selectedAlertsView, ['Graph View', 'Table View'],
                      (value) {
                    setState(() {
                      selectedAlertsView = value ?? '';
                      isAlertsGraphView = value == 'Graph View';
                    });
                  }),
              const SizedBox(height: 10),
              _buildAlertsCard(),
              const SizedBox(height: 10),
              Card(
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  series: <CartesianSeries<RetentionData, String>>[
                    StackedColumnSeries<RetentionData, String>(
                      dataSource: data1,
                      xValueMapper: (RetentionData data, _) => data.month,
                      yValueMapper: (RetentionData data, _) => data.firstTimeBuyers,
                      color: Colors.orange,
                      name: 'First-Time Buyers',
                    ),
                    StackedColumnSeries<RetentionData, String>(
                      dataSource: data1,
                      xValueMapper: (RetentionData data, _) => data.month,
                      yValueMapper: (RetentionData data, _) => data.loyalCustomers,
                      color: Colors.black,
                      name: 'Loyal Customers',
                    ),
                  ],
                ),
              )
              ,
              _buildWarningCard(),
              const SizedBox(height: 10),
              _buildExpenseCard(),
              const SizedBox(height: 10),
              _buildMaintenanceCard(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(String title, String value, List<String> items,
      Function(String?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
        gradient: LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFFCA28)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w500)),
            DropdownButton<String>(
              value: value,
              underline: const SizedBox.shrink(),
              isDense: true,
              alignment: Alignment.centerRight,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 14),
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              iconSize: 35,
              items: items
                  .map((item) =>
                  DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleStatusCard() {
    return ChangeNotifierProvider<DeviceViewViewModel>.value(
      value: deviceViewViewModel,
      child: Consumer<DeviceViewViewModel>(
        builder: (context, value, _) {
          final status = value.getDeviceModelListResponse.status;
          if (status == Status.LOADING || status == Status.ERROR) {
            return const SizedBox(
                height: 250,
                child: Center(child: CircularProgressIndicator()));
          } else if (status == Status.COMPLETED) {
            groupList.clear();
            devicesList.clear();
            groupList.addAll(value.getDeviceModelListResponse.data ?? []);
            for (var element in groupList) {
              devicesList.addAll(element.items ?? []);
            }
            setDeviceStatusCounts(devicesList);
            vehicleStatusData = [
              _ChartData('Running', runningCount),
              _ChartData('Stopped', stoppedCount),
              _ChartData('Idle', idleCount),
              _ChartData('Offline', offlineCount),
            ];
            return isGraphView
                ? _buildGraphView()
                : _buildVehicleStatusTable();
          }
          return Container();
        },
      ),
    );
  }

  Widget _buildGraphView() {
    return SfCircularChart(
      annotations: [
        CircularChartAnnotation(
          widget: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ]),
            child: Text("Total\n${devicesList.length}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                    height: 1.4)),
          ),
        ),
      ],
      onDataLabelRender: (DataLabelRenderArgs args) {
        final status = vehicleStatusData[args.pointIndex].x;
        args.textStyle = TextStyle(
          color: vehicleStatusColors[{
            'Running': 0,
            'Stopped': 1,
            'Idle': 2,
            'Offline': 3
          }[status] ??
              4],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        );
      },
      series: <DoughnutSeries<_ChartData, String>>[
        DoughnutSeries<_ChartData, String>(
          dataSource: vehicleStatusData,
          xValueMapper: (_ChartData data, _) => data.x,
          yValueMapper: (_ChartData data, _) => data.y,
          pointColorMapper: (_ChartData data, index) =>
          vehicleStatusColors[index % vehicleStatusColors.length],
          radius: '65%',
          innerRadius: '60%',
          cornerStyle: CornerStyle.bothFlat,
          explode: true,
          explodeOffset: '5%',
          explodeAll: true,
          dataLabelMapper: (_ChartData data, _) => '${data.y}\n${data.x}',
          dataLabelSettings: const DataLabelSettings(
              isVisible: true, labelPosition: ChartDataLabelPosition.outside),
        ),
      ],
    );
  }





  Widget _buildVehicleStatusTable() {
    final gradients = _getVehicleStatusGradients();
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTableHeader(),
          const SizedBox(height: 8),
          ...vehicleStatusData.asMap().entries.map(
                  (entry) => _buildTableRow(entry.key, entry.value, gradients)),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF0288D1), Color(0xFF26A69A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: const Row(
        children: [
          Expanded(
              flex: 2,
              child: Text('Status',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white))),
          Expanded(
              flex: 1,
              child: Text('Count',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                  textAlign: TextAlign.center)),
          Expanded(
              flex: 1,
              child: Text('Indicator',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                  textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildTableRow(
      int index, _ChartData data, List<LinearGradient> gradients)
  {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 7))
        ],
      ),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                      gradient: gradients[index % gradients.length],
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(data.x,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)))),
          Expanded(
              flex: 1,
              child: Text(data.y.toString(),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                  textAlign: TextAlign.center)),
          Expanded(
              flex: 1,
              child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: gradients[index % gradients.length]))),
        ],
      ),
    );
  }

  Widget _buildRegionDataCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 2000,
            child: SfCartesianChart(
              isTransposed: true,
              margin: const EdgeInsets.only(left: 12),
              plotAreaBorderWidth: 0,
              plotAreaBorderColor: Colors.transparent,
              primaryXAxis: const CategoryAxis(
                plotOffset: 15,
                labelPlacement: LabelPlacement.onTicks,
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                majorGridLines: MajorGridLines(width: 0),
                axisLine: AxisLine(width: 0),
                labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
              ),
              primaryYAxis: const NumericAxis(
                majorGridLines: MajorGridLines(
                    width: 0.5, color: Colors.grey, dashArray: [4, 4]),
                axisLine: AxisLine(width: 0),
                majorTickLines: MajorTickLines(size: 0),
                minorTickLines: MinorTickLines(width: 0),
                labelStyle: TextStyle(fontSize: 12, color: Colors.grey),
                minimum: 0,
                maximum: 100,
                interval: 20,
              ),
              series: [
                BarSeries<ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  spacing: 0.3,
                  width: 0.55,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  gradient: const LinearGradient(
                      colors: [Color(0xFF26A69A), Color(0xFF4DB6AC)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter),
                  dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      labelAlignment: ChartDataLabelAlignment.outer),
                  enableTooltip: true,
                  animationDuration: 1000,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsCard() {
    return Card(
      shape: AppColors.cardBorderShape,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: MultiProvider(
        providers: [
          for (var type in eventViewModels.keys)
            ChangeNotifierProvider<EventViewModel>.value(
              value: eventViewModels[type] ?? EventViewModel(),
              key: Key(type),
            ),
        ],
        child: Builder(
          builder: (context) {
            final alertRowsData = _buildAlertRows();
            return isAlertsGraphView
                ? _buildAlertsGraphView()
                : _buildAlertsTableView(alertRowsData['rows'] as List<Widget>);
          },
        ),
      ),
    );
  }

  Widget _buildAlertsGraphView() {
    final gradients = _getAlertGradients();
    // Ensure alertData is populated dynamically from _buildAlertRows
    final alertRowsData = _buildAlertRows();
    alertData = alertRowsData['data'] as List<_AlertChartData>;

    return SizedBox(
      height: 280, // Slightly reduced for a cleaner fit
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pie Chart with Subtle Animation
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 800), // Softer animation
                curve: Curves.easeIn,
                child: SfCircularChart(
                  backgroundColor: Colors.transparent,
                  title: ChartTitle(
                    text: 'Alerts (Today)',
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  legend: Legend(isVisible: false),
                  series: <CircularSeries<_AlertChartData, String>>[
                    PieSeries<_AlertChartData, String>(
                      dataSource: alertData,
                      xValueMapper: (_AlertChartData data, _) => data.label,
                      yValueMapper: (_AlertChartData data, _) => data.count.toDouble(),
                      pointColorMapper: (_, int index) => gradients[index % gradients.length].colors[0],
                      dataLabelMapper: (_AlertChartData data, _) => data.count > 0 ? '${data.count}' : '',
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.inside,
                        textStyle: TextStyle(
                          fontSize: 10, // Slightly smaller for readability
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      animationDuration: 1200,
                      explode: false, // Removed explode for simplicity
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Scrollable Labels on the Right
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.grey[200]!, width: 0.5)), // Lighter border
              ),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(alertData.length, (index) {
                      return AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 600), // Synchronized animation
                        curve: Curves.easeIn,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: gradients[index % gradients.length].colors[0],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  alertData[index].label,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black87,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${alertData[index].count}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAlertsTableView(List<Widget> rows) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text('Alerts (Today)',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold)),
        ),
        const Divider(),
        ...rows,
      ],
    );
  }

  Map<String, dynamic> _buildAlertRows() {
    const alerts = [
      {
        'type': 'all',
        'icon': Icons.notifications_active_outlined,
        'label': 'Total Alerts',
      },
      {
        'type': 'overspeed',
        'icon': Icons.speed,
        'label': 'Overspeed',
      },
      {
        'type': 'idle_duration',
        'icon': Icons.pause,
        'label': 'Excess Idle',
      },
      {
        'type': 'geofence',
        'icon': Icons.fence_outlined,
        'label': 'Geofence',
      },
      {
        'type': 'excess_drive',
        'icon': Icons.drive_eta,
        'label': 'Excess Driving',
      },
      {
        'type': 'custom',
        'icon': Icons.key,
        'label': 'Ignition \non/off',
      },
      {
        'type': 'stop_duration',
        'icon': Icons.local_parking_outlined,
        'label': 'Parked',
      },
    ];

    List<Widget> rows = [];
    alertData.clear();

    for (var alert in alerts) {
      final type = alert['type'] as String;
      final eventModel = eventViewModels[type] ?? EventViewModel();
      final count = eventModel.eventsAlertsResponse.data?.items?.total ?? 0;
      debugPrint('TableView - ${alert['label']}: $count');
      alertData.add(_AlertChartData(alert['label'] as String, count,
          alert['icon'] as IconData));
    }

    rows.add(Row(children: [_buildAlertItem(alerts[0], 2, true, false)]));
    for (int i = 1; i < alerts.length; i += 2) {
      rows.add(Row(
        children: [
          _buildAlertItem(alerts[i], 1, false, i == alerts.length - 1),
          if (i + 1 < alerts.length)
            _buildAlertItem(alerts[i + 1], 1, false, i + 1 == alerts.length - 1)
          else
            const Expanded(flex: 1, child: SizedBox()),
        ],
      ));
    }

    return {'rows': rows, 'data': alertData};
  }

  Widget _buildAlertItem(
      Map<String, dynamic> alert, int flex, bool isFirst, bool isLast)
  {
    final eventModel =
        eventViewModels[alert['type'] as String] ?? EventViewModel();
    final gradients =
    _getAlertGradients(); // Get the gradients used in the graph
    final alertIndex = [
      'all', // Total Alerts
      'overspeed',
      'idle_duration',
      'geofence',
      'excess_drive',
      'custom',
      'stop_duration'
    ].indexOf(alert['type'] as String);

    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.only(
            left: 8,
            right: isFirst ? 8 : 4,
            top: isFirst ? 0 : 8,
            bottom: isLast ? 8 : 0),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, RoutesName.eventsScreen,
                arguments: EventsInitialData(
                    deviceID: '',
                    eventType: alert['type'] as String,
                    fromDate: '',
                    toDate: '',
                    pageNumber: ''));
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: gradients[alertIndex %
                  gradients.length], // Use gradient from _getAlertGradients
              borderRadius: AppColors.StatusDshboardBarborderRadius,
            ),
            height: 50,
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Icon(alert['icon'] as IconData,
                        color: Colors.white, size: 28)),
                Expanded(
                    flex: 2,
                    child: Text(alert['label'] as String,
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold))),
                Expanded(
                  child: ChangeNotifierProvider<EventViewModel>.value(
                    value: eventModel,
                    child: Consumer<EventViewModel>(
                      builder: (context, value, _) {
                        final status = value.eventsAlertsResponse.status;
                        if (status == Status.LOADING) {
                          return const CircleAvatar(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator()));
                        }
                        if (status == Status.ERROR) {
                          return const CircleAvatar(
                              child: Text('n/a',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)));
                        }
                        final total =
                            value.eventsAlertsResponse.data?.items?.total ?? 0;
                        return CircleAvatar(
                            child: Text(total.toString(),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWarningCard() {
    return Card(
      shape: AppColors.cardBorderShape,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text('!انتباہ',
                style: TextStyle(
                    color: Color(0xFFE57373), fontWeight: FontWeight.bold)),
            Divider(height: 5),
            Text(
                'ٹریکر ڈیوائس موٹر انشورنس کے متبادل نہیں ہے اور نا ہی چوری کو روکنے کا آلہ ہے، کمپنی گاڑی چوری کی صورت میں زمہ دار نہیں ہوگی۔',
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }


  Widget _buildExpenseCard() {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, RoutesName.viewExpenseScreen,
          arguments: {'vehicleId': ''}),
      child: Card(
        shape: AppColors.cardBorderShape,
        margin: const EdgeInsets.symmetric(horizontal: 15),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  CircleAvatar(
                      maxRadius: 16,
                      backgroundColor: Color(0xFF42A5F5),
                      child: Icon(Icons.attach_money_outlined)),
                  VerticalDivider(width: 6),
                  Text('Vehicle Expenses',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              ChangeNotifierProvider<ExpenseRecordViewModel>.value(
                value: expenseViewModel,
                child: Consumer<ExpenseRecordViewModel>(
                    builder: (context, viewModel, _) =>
                        Text('Rs.${viewModel.calculateTotalAmount()}')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceCard() {
    return InkWell(
      onTap: () =>
          Navigator.pushNamed(context, RoutesName.viewMaintenanceSchedule),
      child: Card(
        shape: AppColors.cardBorderShape,
        margin: const EdgeInsets.symmetric(horizontal: 15),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  CircleAvatar(
                      maxRadius: 16,
                      backgroundColor: Color(0xFFE57373),
                      child: Icon(Icons.car_repair)),
                  VerticalDivider(width: 6),
                  Text('Upcoming Maintenance',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  CircleAvatar(
                    maxRadius: 16,
                    child: ChangeNotifierProvider<
                        VehicleMaintenanceViewModel>.value(
                      value: maintenanceViewModel,
                      child: Consumer<VehicleMaintenanceViewModel>(
                          builder: (context, viewModel, _) => Text(
                              viewModel.maintenanceList.length.toString())),
                    ),
                  ),
                  const SizedBox(width: 3),
                  InkWell(
                    onTap: () => Navigator.pushNamed(
                        context, RoutesName.addVehicleMaintenanceScreen),
                    child: const CircleAvatar(maxRadius: 16, child: Text('+')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}

class _ChartData {
  _ChartData(this.x, this.y);
  final String x;
  final int y;
}

class _AlertChartData {
  _AlertChartData(this.label, this.count, [IconData? alert]);
  final String label;
  final int count;
}
class RetentionData {
  final String month;
  final int firstTimeBuyers;
  final int loyalCustomers;

  RetentionData(this.month, this.firstTimeBuyers, this.loyalCustomers);
}
