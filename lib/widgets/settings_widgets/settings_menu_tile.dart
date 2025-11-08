import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackerapp/providers/settings_provider.dart';
import 'package:trackerapp/utils/logout_popup.dart';
import 'package:trackerapp/view/add_maintenance_screen.dart';
import 'package:trackerapp/view/alerts_setting_screen.dart';
import 'package:trackerapp/view/appearance_screen.dart';
import 'package:trackerapp/view/contact_us_screen.dart';
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
            if(item["title"]=="Appearance"){
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>
              AppearanceScreen()
              ));
            }else if(item["title"]=="Alerts Settings"){
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>
                  AlertSettingsScreen()
              ));
            }
            else if(item["title"]=="Password"){
              showCustomPopup(
                context: context,
                title: "Change Password",
                subtitle: "Are you sure you want to change your password?",
                imagePath: "assets/images/change_passwod.png",
                btnText: "Yes, Change",
                onConfirm: () {
                },
              );
            }else if(item["title"]=="Maintenance"){
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>
                  AddMaintenanceScreen()
              ));
            }else if(item["title"]=="Vehicle Expenses"){
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>
                  VehicleExpenseScreen()
              ));
            }else if(item["title"]=="Profile"){
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>
                  ContactScreen()
              ));
            }else if(item["title"]=="LogOut"){
              showCustomPopup(
                context: context,
                title: "Comeback Soon!",
                subtitle: "Are You Sure You Want to Logout?",
                imagePath: "assets/images/logout.png",
                btnText: "Yes, Logout",
                onConfirm: () {
                },
              );

            }
          },
        );
      },
    );
  }
}
