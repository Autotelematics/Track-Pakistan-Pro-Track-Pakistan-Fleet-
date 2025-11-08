import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Provider;

class MaintenanceProvider extends ChangeNotifier {
  String? selectedVehicle;
  DateTime? maintenanceDate;
  TimeOfDay? maintenanceTime;
  String description = "";

  final List<String> vehicles = [
    "Honda Civic",
    "Toyota Corolla",
    "Suzuki Alto",
    "Kia Sportage",
  ];

  void selectVehicle(String value) {
    selectedVehicle = value;
    notifyListeners();
  }

  void setDate(DateTime date) {
    maintenanceDate = date;
    notifyListeners();
  }

  void setTime(TimeOfDay time) {
    maintenanceTime = time;
    notifyListeners();
  }

  void setDescription(String text) {
    description = text;
    notifyListeners();
  }
 //Date Picker
  Future<void> pickDate(BuildContext context)
  async {
    final provider = Provider.of<MaintenanceProvider>(context, listen: false);
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.maintenanceDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) provider.setDate(picked);
  }
  //Time Picker
  Future<void> pickTime(BuildContext context)
  async {
    final provider = Provider.of<MaintenanceProvider>(context, listen: false);
    final picked = await showTimePicker(
      context: context,
      initialTime:
      provider.maintenanceTime ?? TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (picked != null) provider.setTime(picked);
  }

  void reset() {
    selectedVehicle = null;
    maintenanceDate = null;
    maintenanceTime = null;
    description = "";
    notifyListeners();
  }
}
