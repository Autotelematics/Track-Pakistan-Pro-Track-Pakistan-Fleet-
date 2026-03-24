import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/alert_settings_provider.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/custom_button.dart';

class AlertSettingsScreen extends StatefulWidget {
  const AlertSettingsScreen({super.key});

  @override
  State<AlertSettingsScreen> createState() => _AlertSettingsScreenState();
}

class _AlertSettingsScreenState extends State<AlertSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AlertSettingsProvider>().fetchUserAlertSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Alert Setting"),
        elevation: 0,
        backgroundColor:
            isDark ? theme.scaffoldBackgroundColor : AppColors.blueCyan,
      ),
      body: Consumer<AlertSettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child:
                  CircularProgressIndicator(color: ConstantColor.primaryColor),
            );
          }
          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: AppStyles.regularTextStyle(context).copyWith(
                  color: onSurface.withValues(alpha: .75),
                ),
              ),
            );
          }
          if (provider.alertItems.isEmpty) {
            return Center(
              child: Text(
                "No alerts found",
                style: AppStyles.regularTextStyle(context).copyWith(
                  color: onSurface.withValues(alpha: .75),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 10.h),
            itemCount: provider.alertItems.length,
            itemBuilder: (context, index) {
              final item = provider.alertItems[index];
              return _tile(
                context,
                item.name,
                item.assigned,
                () => provider.toggleAlertItem(index),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 1.2.h),
        child: Consumer<AlertSettingsProvider>(
          builder: (context, provider, child) {
            return provider.isSyncing
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                    text: "Save",
                    onPressed: () async {
                      final ok = await provider.syncUserAlertSettings();
                      if (!mounted) return;
                      if (ok) Navigator.of(this.context).pop();
                    },
                  );
          },
        ),
      ),
    );
  }

  Widget _tile(
      BuildContext context, String title, bool value, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return AnimatedContainer(
      duration: Duration(seconds: 9),
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.cardColor,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
        ],
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
          style: AppStyles.regularTextStyle(context).copyWith(color: onSurface),
        ),
        trailing: Checkbox(
          value: value,
          activeColor: theme.primaryColor,
          onChanged: (_) => onTap(),
        ),
      ),
    );
  }
}
