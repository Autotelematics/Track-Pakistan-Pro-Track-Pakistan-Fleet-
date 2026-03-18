import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackerapp/app/theme/popups.dart';
import 'package:trackerapp/providers/settings_provider.dart';
import 'package:trackerapp/utils/logout_popup.dart';
import 'package:trackerapp/view/add_maintenance_screen.dart';
import 'package:trackerapp/view/alerts_setting_screen.dart';
import 'package:trackerapp/view/setting_screens/appearance_screen.dart';
import 'package:trackerapp/view/setting_screens/contact_us_screen.dart';
import 'package:trackerapp/view/vehicle_expense_screen.dart';
import 'package:trackerapp/widgets/settings_widgets/settings_menu_list.dart';

class SettingsMenuList extends StatelessWidget {
  const SettingsMenuList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SettingsProvider>();
    final settingsItems = provider.visibleSettingsItems;
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: settingsItems.length,
      itemBuilder: (context, index) {
        final item = settingsItems[index];
        return SettingsMenuTile(
          icon: item['icon'],
          title: item['title'],
          cardColor: theme.cardColor,
          onSurface: theme.colorScheme.onSurface,
          switchValue: item["title"] == "Play Alerts Announcement"
              ? provider.playAlertsAnnouncement
              : null,
          onSwitchChanged: item["title"] == "Play Alerts Announcement"
              ? provider.setPlayAlertsAnnouncement
              : null,
          onTap: () {
            if (item["title"] == "Appearance") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => AppearanceScreen()));
            } else if (item["title"] == "Alert Setting" ||
                item["title"] == "Alerts Settings") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          const AlertSettingsScreen()));
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
            } else if (item["title"] == "Support") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => ContactScreen()));
            } else if (item["title"] == "Drivers") {
              showDriverActionPopup(context);
              // showAddDriverPopup(context);
            }
          },
        );
      },
    );
  }
}
