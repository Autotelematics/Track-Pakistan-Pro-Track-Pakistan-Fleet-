import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/data/models/dashboard_data.dart';
import 'package:trackerapp/data/models/get_dashboard_history_model.dart';
import 'package:trackerapp/data/models/get_dashboard_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:http/http.dart' as http;

class DashboardRepository {
  //Fetch Dashboard data From Api
  Future<GetDashboardModel?> getDashboardData({required String token}) async {
    final endpointPath = AppUrl.getDashboardEp.split('?').first;
    final url = Uri.parse('${AppUrl.baseURL}$endpointPath').replace(
      queryParameters: {
        'user_api_hash': token,
      },
    );
    final headers = {"Content-Type": "application/json"};
    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        return GetDashboardModel.fromJson(jsonDecode(response.body));
      } else {
        log('Error fetching business profiles: ${response.body}');
        return null;
      }
    } on TimeoutException {
      log('Timeout fetching dashboard data');
      return null;
    } catch (error) {
      log('UnExpected Error fetching business profiles: ${error.toString()}');
      return null;
    }
  }

  Future<DashboardData> fetchDashboardData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return DashboardData(
      chartData: [
        ChartData(
          color: AppColors.green,
          value: 50.0,
          label: "Running (50)",
          percent: "17%",
        ),
        ChartData(
          color: AppColors.yellow,
          value: 120.0,
          label: "Idle (120)",
          percent: "40%",
        ),
        ChartData(
          color: AppColors.red,
          value: 80.0,
          label: "Stopped (80)",
          percent: "27%",
        ),
        ChartData(
          color: AppColors.grey,
          value: 50.0,
          label: "Not Connected (50)",
          percent: "16%",
        ),
      ],
      alerts: [
        AlertData(
          svgPath: 'assets/svgs/overspeed.svg',
          name: 'Overspeed',
          unit: 'Times',
          value: '6',
          bgColor: const Color(0xFFFFC107),
        ),
        AlertData(
          svgPath: 'assets/svgs/stop.svg',
          name: 'Stop Duration',
          unit: 'Times',
          value: '4',
          bgColor: const Color(0xFFEF5350),
        ),
        AlertData(
          svgPath: 'assets/svgs/idle.svg',
          name: 'Idle',
          unit: 'Times',
          value: '3',
          bgColor: const Color(0xFFFF9800),
        ),
        AlertData(
          svgPath: 'assets/svgs/geofence.svg',
          name: 'Geofencing (In/Out)',
          unit: 'Times',
          value: '8',
          bgColor: const Color(0xFF2196F3),
        ),
        AlertData(
          svgPath: 'assets/svgs/running.svg',
          name: 'Running Duration',
          unit: 'Mins',
          value: '120',
          bgColor: const Color(0xFFEF5350),
        ),
        AlertData(
          svgPath: 'assets/svgs/fuel.svg',
          name: 'Fuel',
          unit: 'Times',
          value: '2',
          bgColor: const Color(0xFF009688),
        ),
      ],
      barValues: [65, 48, 56, 55, 90],
      barDays: ['Dec 2', 'Dec 3', 'Dec 4', 'Dec 5', 'Dec 6'],
      dummyAlertData: [
        DummyAlertData(label: 'BA C AB 0123', value: 24),
        DummyAlertData(label: 'B AB 0123', value: 2),
        DummyAlertData(label: 'G AB 0123', value: 40),
        DummyAlertData(label: 'BA 1 GHA 3456', value: 20),
        DummyAlertData(label: 'BA 1 GHA 3456', value: 24),
      ],
      expenseList: [
        ExpenseData(label: 'BA C AB 0123', amount: 12000.00),
        ExpenseData(label: 'B AB 0123', amount: 11000.00),
        ExpenseData(label: 'G AB 0123', amount: 10000.00),
        ExpenseData(label: 'BA 1 GHA 3456', amount: 9000.00),
        ExpenseData(label: 'BA 1 GHA 3456', amount: 500.00),
      ],
      maintenanceDue: "6",
      maintenanceOverdue: "256",
      totalDistance: "3000 km",
      averageDistance: "956.27 km",
      totalVehicles: "300",
    );
  }

  //get dashboard History
  Future<GetDashboardHistoryModel?> getDashboardHistoryData({required String token})
  async {
    final endpointPath = AppUrl.getDashboardHistoryEp.split('?').first;
    final url = Uri.parse('${AppUrl.baseURL}$endpointPath').replace(
      queryParameters: {
        'user_api_hash': token,
      },
    );
    final headers = {"Content-Type": "application/json"};
    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        return GetDashboardHistoryModel.fromJson(jsonDecode(response.body));
      } else {
        log('Error fetching business profiles: ${response.body}');
        return null;
      }
    } on TimeoutException {
      log('Timeout fetching dashboard history');
      return null;
    } catch (error) {
      log('UnExpected Error fetching business profiles: ${error.toString()}');
      return null;
    }
  }

}
