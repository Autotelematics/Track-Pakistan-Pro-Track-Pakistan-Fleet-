import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:trackerapp/data/globalsharedveriables.dart';
import 'package:trackerapp/models/vehicle_maintancne_model.dart';
import 'package:trackerapp/res/colors.dart';
import 'package:trackerapp/view_model/vehicle_maintenance_view_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class AddVehicleMaintenanceScreen extends StatefulWidget {
  const AddVehicleMaintenanceScreen({super.key});

  @override
  _AddVehicleMaintenanceScreenState createState() =>
      _AddVehicleMaintenanceScreenState();
}

class _AddVehicleMaintenanceScreenState
    extends State<AddVehicleMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _maintenanceDateController = TextEditingController();
  final _maintenanceTimeController = TextEditingController();
  final _maintenanceTypeController = TextEditingController();
  final _maintenanceDescriptionController = TextEditingController();
  final _maintenanceVehicleNameController = TextEditingController();
  VehicleMaintenanceViewModel vehicleMaintenanceViewModel =
  VehicleMaintenanceViewModel();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  String? selectedMaintenanceOption;
  String? selectedVehicleOption;
  List<String> maintenanceOptions = [
    'Oil Change',
    'Oil Filter Change',
    'Air Filter Change',
    'Timing Belt',
    'Greasing',
    'Engine Tuning',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    const initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification(
      DateTime scheduledDateTime,
      String vehicleName,
      String description,
      )
  async {
    // Calculate the notification time 5 minutes before the given time
    final notificationTime =
    scheduledDateTime.subtract(const Duration(minutes: 5));

    // Create the notification details
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'This channel is used for maintenance notifications',
      importance: Importance.high,
      priority: Priority.high,
      fullScreenIntent: true,
    );

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Show immediate confirmation notification
    await flutterLocalNotificationsPlugin.show(
      12345,
      "Maintenance Scheduled",
      "Maintenance schedule has been set",
      platformChannelSpecifics,
      payload: 'data',
    );

    // Schedule the reminder notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Maintenance Reminder',
      'Vehicle: $vehicleName\nDescription: $description\nTime: ${scheduledDateTime.toString()}',
      tz.TZDateTime.from(notificationTime, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, uiLocalNotificationDateInterpretation:UILocalNotificationDateInterpretation.wallClockTime ,
    );
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _maintenanceDateController.text =
            DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        _maintenanceTimeController.text = pickedTime.format(context);
      });
    }
  }

  Future<void> _saveMaintenance() async {
    if (_formKey.currentState!.validate()) {
      final maintenance = VehicleMaintenance(
        maintenanceDate: DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        ),
        maintenanceType: selectedMaintenanceOption.toString(),
        maintenanceDescription: _maintenanceDescriptionController.text,
        maintenanceVehicleId: '', // Fill this with the appropriate vehicle ID
        maintenanceVehicleName: selectedVehicleOption.toString(),
      );

      try {
        await vehicleMaintenanceViewModel.addVehicleMaintenance(maintenance);
        // Schedule the local notification
        await _scheduleNotification(
          maintenance.maintenanceDate,
          maintenance.maintenanceVehicleName,
          maintenance.maintenanceDescription,
        );

        Navigator.pop(context);
      } catch (error) {
        // Handle error
        // print('Error while saving maintenance schedule' + error.toString());
      }
    }
  }

  @override
  void dispose() {
    _maintenanceDateController.dispose();
    _maintenanceTimeController.dispose();
    _maintenanceTypeController.dispose();
    _maintenanceDescriptionController.dispose();
    _maintenanceVehicleNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DecoratedBox(
        decoration: AppColors.appScreenBackgroundImage,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'Add Maintenance Schedule',
              style: AppColors.appTitleTextStyle,
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            centerTitle: false,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text('Add maintenance schedule with reminder'),
                    TextFormField(
                      controller: _maintenanceDateController,
                      onTap: _selectDate,
                      decoration: const InputDecoration(
                        labelText: 'Maintenance Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                      readOnly: true,
                    ),
                    TextFormField(
                      controller: _maintenanceTimeController,
                      onTap: _selectTime,
                      decoration: const InputDecoration(
                        labelText: 'Maintenance Time',
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please select a time';
                        }
                        return null;
                      },
                      readOnly: true,
                    ),
                    DropdownButtonFormField<String>(
                      items: maintenanceOptions.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedMaintenanceOption = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select an option',
                      ),
                    ),
                    TextFormField(
                      controller: _maintenanceDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Maintenance Description',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the maintenance description';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      items: vehicleNames.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedVehicleOption = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select Vehicle',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GFButton(
                          textColor: Colors.black87,
                          color: AppColors.buttonColor,
                          onPressed: _saveMaintenance,
                          text: "Save",
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GFButton(
                          textColor: Colors.black87,
                          color: AppColors.buttonColor,
                          onPressed: () => Navigator.pop(context),
                          text: "Close",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}