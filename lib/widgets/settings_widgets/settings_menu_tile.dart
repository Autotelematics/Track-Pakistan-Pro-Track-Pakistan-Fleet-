import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/app/theme/popups.dart';
import 'package:trackerapp/providers/language_provider.dart';
import 'package:trackerapp/providers/settings_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/utils/logout_popup.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';
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
              case SettingsItemId.myAccount:
                _showMyAccountSheet(context);
                break;
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

  Future<void> _showMyAccountSheet(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final l10n = context.l10n;

    String readValue(String key) => MySharedPreferences.getString(key).trim();
    String withUnlimited(String value) =>
        value.isEmpty || value.toLowerCase() == 'null' ? l10n.unlimited : value;
    String withDash(String value) => value.isEmpty ? '-' : value;

    final email = withDash(readValue(userEmailKey));
    final name = withDash(readValue(userNameKey));
    final phone = withDash(readValue(userPhoneNumberKey));
    final deviceLimit = withUnlimited(readValue(userDevicesLimitKey));
    final expiry = withUnlimited(readValue(userExpirationDateKey));

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(5.w, 1.2.h, 5.w, 1.6.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 11.w,
                      height: .45.h,
                      decoration: BoxDecoration(
                        color: onSurface.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.2.h),
                  Row(
                    children: [
                      Container(
                        width: 11.w,
                        height: 11.w,
                        decoration: BoxDecoration(
                          color: AppColors.blueCyan
                              .withValues(alpha: isDark ? .20 : .12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.account_circle_rounded,
                          color: AppColors.blueCyan,
                          size: 19.sp,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          l10n.myAccount,
                          style: AppStyles.boldTextStyle(context).copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.4.h),
                  _accountInfoTile(
                    context,
                    label: l10n.loginEmail,
                    value: email,
                  ),
                  SizedBox(height: .9.h),
                  _accountInfoTile(
                    context,
                    label: l10n.nameLabel,
                    value: name,
                  ),
                  SizedBox(height: .9.h),
                  _accountInfoTile(
                    context,
                    label: l10n.phoneNumberLabel,
                    value: phone,
                  ),
                  SizedBox(height: .9.h),
                  _accountInfoTile(
                    context,
                    label: l10n.deviceLimit,
                    value: deviceLimit,
                  ),
                  SizedBox(height: .9.h),
                  _accountInfoTile(
                    context,
                    label: l10n.accountExpiry,
                    value: expiry,
                  ),
                  SizedBox(height: 1.4.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _accountInfoTile(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 3.8.w, vertical: 1.15.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: .05)
            : const Color(0xFFF6F8FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 12.4.sp,
              color: onSurface.withValues(alpha: .62),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: .25.h),
          Text(
            value,
            style: AppStyles.semiboldTextStyle(context).copyWith(
              fontSize: 13.8.sp,
              color: onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
