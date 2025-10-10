import 'package:flutter/material.dart';

class VehicleEventsScreen extends StatefulWidget {
  const VehicleEventsScreen({super.key});

  @override
  State<VehicleEventsScreen> createState() => _VehicleEventsScreenState();
}

class _VehicleEventsScreenState extends State<VehicleEventsScreen> {
  String? _selectedVehicle;
  String? _selectedAlertType = "All";

  final List<String> vehicles = [
    "Car A",
    "Car B",
    "Car C",
  ];

  final List<String> alertTypes = [
    "All",
    "Overspeed",
    "Geofence",
    "Idle",
  ];

  final List<Map<String, dynamic>> dummyAlerts = [
    {
      "id": 1,
      "deviceName": "Car A",
      "message": "Overspeed detected at 120km/h",
      "time": DateTime.now().subtract(const Duration(minutes: 10)),
    },
    {
      "id": 2,
      "deviceName": "Car B",
      "message": "Entered Geofence Area",
      "time": DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      "id": 3,
      "deviceName": "Car C",
      "message": "Idle for 25 minutes",
      "time": DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      "id": 3,
      "deviceName": "Car C",
      "message": "Idle for 25 minutes",
      "time": DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      "id": 3,
      "deviceName": "Car C",
      "message": "Idle for 25 minutes",
      "time": DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      "id": 3,
      "deviceName": "Car C",
      "message": "Idle for 25 minutes",
      "time": DateTime.now().subtract(const Duration(hours: 2)),
    },
  ];

  void _applyFilters() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Filters applied (dummy only)", style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedVehicle = null;
      _selectedAlertType = "All";
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final cardColor = theme.cardColor;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: dummyAlerts.isEmpty
                ? Center(child: Text("No alerts available", style: TextStyle(color: onSurface)))
                : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: dummyAlerts.length,
              itemBuilder: (context, index) {
                final alert = dummyAlerts[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Card(
                    color: cardColor,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.notifications,
                          color: Colors.red),
                      title: Text(alert["deviceName"], style: TextStyle(color: onSurface)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(alert["message"],
                              style: TextStyle(color: Colors.red)),
                          const SizedBox(height: 4),
                          Text(alert["time"].toString(),
                              style: theme.textTheme.bodySmall?.copyWith(color: onSurface.withOpacity(0.7))),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, color: onSurface.withOpacity(0.5)),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "Tapped ${alert["message"]} (dummy)",
                                  style: TextStyle(color: onSurface))),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}