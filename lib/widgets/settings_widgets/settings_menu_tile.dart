import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackerapp/app/theme/popups.dart';
import 'package:trackerapp/providers/language_provider.dart';
import 'package:trackerapp/providers/settings_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/utils/logout_popup.dart';
import 'package:trackerapp/view/alerts_setting_screen.dart';
import 'package:trackerapp/view/setting_screens/appearance_screen.dart';
import 'package:trackerapp/view/setting_screens/contact_us_screen.dart';
import 'package:trackerapp/widgets/settings_widgets/settings_menu_list.dart';

class SettingsMenuList extends StatelessWidget {
  const SettingsMenuList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SettingsProvider>();
    final settingsItems = provider.visibleSettingsItems;
    final l10n = context.l10n;
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: settingsItems.length,
      itemBuilder: (context, index) {
        final item = settingsItems[index];
        return SettingsMenuTile(
          icon: item.icon,
          title: item.titleBuilder(l10n),
          cardColor: theme.cardColor,
          onSurface: theme.colorScheme.onSurface,
          switchValue: item.id == SettingsItemId.playAlertsAnnouncement
              ? provider.playAlertsAnnouncement
              : null,
          onSwitchChanged: item.id == SettingsItemId.playAlertsAnnouncement
              ? provider.setPlayAlertsAnnouncement
              : null,
          onTap: () async {
            switch (item.id) {
              case SettingsItemId.appearance:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => AppearanceScreen(),
                  ),
                );
                break;
              case SettingsItemId.alertSetting:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        const AlertSettingsScreen(),
                  ),
                );
                break;
              case SettingsItemId.password:
                showCustomPopup(
                  context: context,
                  title: l10n.changePassword,
                  subtitle: l10n.changePasswordSubtitle,
                  btnText: l10n.change,
                  imagePath: "assets/images/logout.png",
                );
                break;
              case SettingsItemId.support:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ContactScreen(),
                  ),
                );
                break;
              case SettingsItemId.drivers:
                showDriverActionPopup(context);
                break;
              case SettingsItemId.language:
                await _showLanguageSheet(context);
                break;
              case SettingsItemId.playAlertsAnnouncement:
                break;
            }
          },
        );
      },
    );
  }

  Future<void> _showLanguageSheet(BuildContext context) async {
    final provider = context.read<LanguageProvider>();
    final l10n = context.l10n;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final options = [
          (const Locale('en'), l10n.english),
          (const Locale('ur'), l10n.urdu),
          (const Locale('ar'), l10n.arabic),
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.selectLanguage,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ...options.map((option) {
                  final locale = option.$1;
                  final label = option.$2;
                  final selected =
                      provider.locale.languageCode == locale.languageCode;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(label),
                    trailing: selected
                        ? Icon(
                            Icons.check_rounded,
                            color: Theme.of(sheetContext).colorScheme.primary,
                          )
                        : null,
                    onTap: () async {
                      await provider.setLocale(locale);
                      if (!sheetContext.mounted) return;
                      Navigator.pop(sheetContext);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
