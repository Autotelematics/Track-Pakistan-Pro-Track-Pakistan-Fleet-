import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/providers/dashboard_provider.dart';
import 'package:trackerapp/widgets/dashboard_widgets/alert_grid.dart';
import 'package:trackerapp/widgets/dashboard_widgets/distance_travelled_card.dart';
import 'package:trackerapp/widgets/dashboard_widgets/fleet_alerts_card.dart';
import 'package:trackerapp/widgets/dashboard_widgets/header_widget.dart';
import 'package:trackerapp/widgets/dashboard_widgets/maintenance_card.dart';
import 'package:trackerapp/widgets/get_verticle_space.dart';
class NewDashboard extends StatelessWidget {
  const NewDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  ElevatedButton(
                    onPressed: () => provider.fetchData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (provider.dashboardData != null) {
            final data = provider.dashboardData!;
            return Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderWidget(data: data),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        AlertGrid(data: data),
                        MaintenanceCard(data: data),
                        DistanceTravelledCard(data: data),
                        FleetAlertsCard(data: data),
                        verticalSpace(height: 5.h),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}