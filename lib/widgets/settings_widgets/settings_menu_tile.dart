import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackerapp/app/theme/popups.dart';
import 'package:trackerapp/providers/settings_provider.dart';
import 'package:trackerapp/utils/logout_popup.dart';
import 'package:trackerapp/utils/shared_preference.dart';
import 'package:trackerapp/view/add_maintenance_screen.dart';
import 'package:trackerapp/view/alerts_setting_screen.dart';
import 'package:trackerapp/view/setting_screens/appearance_screen.dart';
import 'package:trackerapp/view/setting_screens/contact_us_screen.dart';
import 'package:trackerapp/view/geofence_screen.dart';
import 'package:trackerapp/view/auth_screens/login_screen.dart';
import 'package:trackerapp/view/vehicle_expense_screen.dart';
import 'package:trackerapp/widgets/settings_widgets/settings_menu_list.dart';
class SettingsMenuList extends StatelessWidget {
  const SettingsMenuList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SettingsProvider>();
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: provider.settingsItems.length,
      itemBuilder: (context, index) {
        final item = provider.settingsItems[index];
        return SettingsMenuTile(
          icon: item['icon'],
          title: item['title'],
          cardColor: theme.cardColor,
          onSurface: theme.colorScheme.onSurface,
          onTap: () {
            if (item["title"] == "Appearance") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => AppearanceScreen()));
            } else if (item["title"] == "Alerts Settings") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          AlertSettingsScreen()));
            } else if (item["title"] == "Password") {
              showCustomPopup(
                context: context,
                title: "Change Password",
                subtitle: "Enter old and new password to change it",
                btnText: "Change",
                imagePath: "assets/images/logout.png",
              );
            } else if (item["title"] == "Maintenance") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          AddMaintenanceScreen()));
            } else if (item["title"] == "Vehicle Expenses") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          VehicleExpenseScreen()));
            } else if (item["title"] == "Profile") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => ContactScreen()));
            } else if (item["title"] == "LogOut") {
              showCustomPopup(
                context: context,
                title: "Logout",
                subtitle: "Are you sure you want to logout?",
                btnText: "Logout",
                imagePath: "assets/images/logout.png",
                onConfirm: () async {
                  await MySharedPreferences.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              );
            } else if (item["title"] == "Geofence Settings") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => GeofenceScreen()));
            }else if (item["title"] == "Drivers") {
              showDriverActionPopup(context);
              // showAddDriverPopup(context);
            }

          },
        );
      },
    );
  }
}

