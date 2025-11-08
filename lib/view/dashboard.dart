// lib/view/dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_widgets/alert_grid.dart';
import '../widgets/dashboard_widgets/distance_travelled_card.dart';
import '../widgets/dashboard_widgets/fleet_alerts_card.dart';
import '../widgets/dashboard_widgets/header_widget.dart';
import '../widgets/dashboard_widgets/maintenance_card.dart';
import '../widgets/get_vertical_space.dart';

class NewDashboard extends StatelessWidget {
  const NewDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          // Loading State
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error State
          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${provider.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    verticalSpace(height: 2.h),
                    ElevatedButton(
                      onPressed: provider.fetchData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // No Data
          if (provider.dashboardData == null) {
            return const Center(
              child: Text('No data available'),
            );
          }

          // Success State
          final data = provider.dashboardData!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              HeaderWidget(data: data),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AlertGrid(data: data),
                      verticalSpace(height: 2.h),
                      MaintenanceCard(data: data),
                      verticalSpace(height: 2.h),
                      DistanceTravelledCard(data: data),
                      verticalSpace(height: 2.h),
                      FleetAlertsCard(data: data),
                      verticalSpace(height: 5.h),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}