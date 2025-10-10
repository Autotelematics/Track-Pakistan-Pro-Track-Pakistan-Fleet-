import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool playAlerts = false;
  double fuelPrice = 200;
  String userID = "User ID";

  void _showSimpleDialog(BuildContext context, String title, Widget child) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (_) => Theme(
        data: theme.copyWith(dialogBackgroundColor: theme.cardColor),
        child: Dialog(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface)),
                  InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: theme.colorScheme.onSurface)),
                ],
              ),
              const SizedBox(height: 10),
              child,
            ]),
          ),
        ),
      ),
    );
  }

  void _showFuelPriceDialog(BuildContext context) {
    final controller = TextEditingController();
    _showSimpleDialog(
      context,
      "Set Fuel Price",
      Column(
        children: [
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Current Fuel Cost per Liter",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 10),
          // SubmitButton(
          //   title: "Set Fuel Price",
          //   onPresse: () {
          //     final value = double.tryParse(controller.text);
          //     if (value != null) {
          //       setState(() => fuelPrice = value);
          //     }
          //     Navigator.pop(context);
          //   },
          // ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    _showSimpleDialog(
      context,
      "Change Password",
      Column(
        children: [
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Password",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: confirmController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Confirm Password",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          // SubmitButton(
          //   title: "Change Password",
          //   onPresse: () => Navigator.pop(context),
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
            style: TextStyle(color: onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: onSurface,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _sectionHeader(theme, Icons.person, "Profile"),
            _profileCard(context, theme),
            _passwordCard(context, theme),
            _sectionHeader(theme, Icons.settings, "Tools"),
            _simpleCard(
              theme,
              icon: Icons.fence,
              color: Colors.blue,
              title: "Geofence Settings",
            ),
            _simpleCard(
              theme,
              icon: Icons.notifications,
              color: Colors.purple,
              title: "Alerts Settings",
            ),
            _alertsCard(theme),
            _fuelCard(context, theme),
            _simpleCard(
              theme,
              icon: Icons.attach_money_outlined,
              color: Colors.green,
              title: "Vehicle Expenses",
            ),
            _simpleCard(
              theme,
              icon: Icons.car_repair,
              color: Colors.red,
              title: "Maintenance",
            ),
            _themeToggleCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, IconData icon, String title) => Container(
    width: double.infinity,
    color: AppColors.buttonColor,
    padding: const EdgeInsets.all(5),
    child: Row(children: [
      Icon(icon, color: theme.colorScheme.onPrimary),
      const SizedBox(width: 8),
      Text(title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimary))
    ]),
  );

  Widget _profileCard(BuildContext context, ThemeData theme) => Card(
    shape: AppStyles.cardBorderShape,
    child: ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color.fromARGB(247, 6, 84, 117),
        child: Icon(Icons.person, size: 18, color: Colors.white),
      ),
      title: Text(userID, style: TextStyle(color: theme.colorScheme.onSurface)),
      trailing: GFButton(
        onPressed: () {},
        text: "Logout",
        textStyle: AppStyles.settingPageButtonTextStyle
            .copyWith(color: theme.colorScheme.onSurface),
        color: AppColors.buttonColor,
        shape: GFButtonShape.pills,
        size: 20,
      ),
    ),
  );

  Widget _passwordCard(BuildContext context, ThemeData theme) => Card(
    shape: AppStyles.cardBorderShape,
    child: ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color.fromARGB(247, 11, 105, 6),
        child: Icon(Icons.key, size: 18, color: Colors.white),
      ),
      title: Text("Password",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
      trailing: GFButton(
        onPressed: () => _showChangePasswordDialog(context),
        text: "Change",
        textStyle: AppStyles.settingPageButtonTextStyle
            .copyWith(color: theme.colorScheme.onSurface),
        color: AppColors.buttonColor,
        shape: GFButtonShape.pills,
        size: 20,
      ),
    ),
  );

  Widget _simpleCard(ThemeData theme,
      {required IconData icon,
        required Color color,
        required String title}) =>
      Card(
        shape: AppStyles.cardBorderShape,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          title: Text(title,
              style: AppStyles.settingTextstyle
                  .copyWith(color: theme.colorScheme.onSurface)),
          trailing: Icon(Icons.arrow_forward,
              color: theme.colorScheme.onSurface.withOpacity(0.5)),
        ),
      );

  Widget _alertsCard(ThemeData theme) => Card(
    shape: AppStyles.cardBorderShape,
    child: ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color.fromARGB(247, 144, 6, 132),
        child: Icon(Icons.speaker, size: 18, color: Colors.white),
      ),
      title: Text("Play Alerts Announcement",
          style: AppStyles.settingTextstyle
              .copyWith(color: theme.colorScheme.onSurface)),
      trailing: Checkbox(
        value: playAlerts,
        onChanged: (v) => setState(() => playAlerts = v ?? false),
      ),
    ),
  );

  Widget _fuelCard(BuildContext context, ThemeData theme) => Card(
    shape: AppStyles.cardBorderShape,
    child: ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color.fromARGB(247, 182, 63, 8),
        child: Icon(Icons.gas_meter_outlined,
            size: 18, color: Colors.white),
      ),
      title: Text("Fuel Cost : Rs.$fuelPrice/l",
          style: AppStyles.settingTextstyle
              .copyWith(color: theme.colorScheme.onSurface)),
      trailing: GFButton(
        onPressed: () => _showFuelPriceDialog(context),
        text: "Set Price",
        textStyle: AppStyles.settingPageButtonTextStyle
            .copyWith(color: theme.colorScheme.onSurface),
        color: AppColors.buttonColor,
        shape: GFButtonShape.pills,
        size: 20,
      ),
    ),
  );

  Widget _themeToggleCard(ThemeData theme) => Card(
    shape: AppStyles.cardBorderShape,
    child: ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.black,
        child: Icon(Icons.color_lens, size: 18, color: Colors.white),
      ),
      title: Text("Theme",
          style: AppStyles.settingTextstyle
              .copyWith(color: theme.colorScheme.onSurface)),
      trailing: Switch(
        value: false,
        onChanged: (_) {},
      ),
    ),
  );
}
