import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {

  final List<Map<String, dynamic>> settingsItems = [
    {'icon': Icons.person_outline, 'title': 'Profile'},
    {'icon': Icons.key_outlined, 'title': 'Password'},
    {'icon': Icons.badge_outlined, 'title': 'Drivers'},
    {'icon': Icons.fence_outlined, 'title': 'Geofence Settings'},
    // {'icon': Icons.notifications_none, 'title': 'Alerts Settings'},
    {'icon': Icons.speaker_outlined, 'title': 'Play Alerts Announcement'},
    // {'icon': Icons.attach_money_outlined, 'title': 'Vehicle Expenses'},
    // {'icon': Icons.build_outlined, 'title': 'Maintenance'},
    {'icon': Icons.palette_outlined, 'title': 'Appearance'},
    {'icon': Icons.logout_outlined, 'title': 'LogOut'},
  ];

}
