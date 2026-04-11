import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/dashboard_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class SettingsHeader extends StatefulWidget {
  const SettingsHeader({super.key});

  @override
  State<SettingsHeader> createState() => _SettingsHeaderState();
}

class _SettingsHeaderState extends State<SettingsHeader> {
  final ImagePicker _imagePicker = ImagePicker();
  String _profileImagePath = "";

  Future<void> _showGalleryPermissionHelp() async {
    if (!mounted) return;
    final l10n = context.l10n;
    final platform = Platform.isIOS ? "iPhone Settings" : "App Settings";
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.galleryPermissionRequired),
          content: Text(
            l10n.galleryPermissionMessage(platform),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    final savedPath = MySharedPreferences.getString(profileImagePathKey);
    if (savedPath.isEmpty) return;

    final file = File(savedPath);
    if (!await file.exists()) {
      await MySharedPreferences.removeKey(profileImagePathKey);
      if (!mounted) return;
      setState(() => _profileImagePath = "");
      return;
    }

    if (!mounted) return;
    setState(() => _profileImagePath = savedPath);
  }

  Future<void> _pickProfileImage() async {
    try {
      final selected = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        // Avoid requesting full EXIF metadata permission on iOS.
        requestFullMetadata: false,
      );
      if (selected == null) return;

      await MySharedPreferences.setString(profileImagePathKey, selected.path);
      if (!mounted) return;
      setState(() => _profileImagePath = selected.path);
    } on MissingPluginException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Image picker not initialized. Please restart the app once.",
          ),
        ),
      );
    } on PlatformException catch (e) {
      final code = e.code.toLowerCase();
      final denied = code.contains("denied") || code.contains("permission");
      if (denied) {
        await _showGalleryPermissionHelp();
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Unable to open gallery (${e.code}). Please try again.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final hasImage = _profileImagePath.isNotEmpty;
    final userEmailFromApi = context.select<DashboardProvider, String>(
      (provider) => provider.dashboardModel?.userEmail ?? "",
    );
    final storedUserName = MySharedPreferences.getString(userNameKey).trim();
    final storedUserEmail = MySharedPreferences.getString(userEmailKey).trim();
    final userEmail = userEmailFromApi.trim().isNotEmpty
        ? userEmailFromApi.trim()
        : storedUserEmail;
    final greetingName = storedUserName.isNotEmpty ? storedUserName : userEmail;
    final l10n = context.l10n;
    final greeting =
        greetingName.isNotEmpty ? l10n.hiUser(greetingName) : l10n.hi;

    return Column(
      children: [
        verticalSpace(height: 0.0.h),
        InkWell(
          onTap: _pickProfileImage,
          borderRadius: BorderRadius.circular(99),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 11.2.h,
                width: 11.2.h,
                padding: EdgeInsets.all(.5.h),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isDark
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFFFFD970), Color(0xFFFFB55B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: isDark ? theme.cardColor : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? .32 : .14),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2.2,
                      color: isDark
                          ? Colors.white.withValues(alpha: .14)
                          : Colors.white.withValues(alpha: .85),
                    ),
                    color: isDark
                        ? Colors.white.withValues(alpha: .06)
                        : Colors.white.withValues(alpha: .3),
                    image: hasImage
                        ? DecorationImage(
                            image: FileImage(File(_profileImagePath)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: hasImage
                      ? null
                      : Icon(
                          Icons.person_rounded,
                          size: 34.sp,
                          color: isDark
                              ? Colors.white.withValues(alpha: .9)
                              : AppColors.white,
                        ),
                ),
              ),
              Positioned(
                right: -.2.w,
                bottom: -.2.w,
                child: InkWell(
                  onTap: _pickProfileImage,
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    width: 8.2.w,
                    height: 8.2.w,
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? theme.scaffoldBackgroundColor
                            : Colors.white.withValues(alpha: .95),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 15.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        verticalSpace(height: 1.0.h),
        Text(
          l10n.settings,
          style: AppStyles.regularTextStyle(context).copyWith(
            fontSize: 19.sp,
            color: isDark ? onSurface : AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          greeting,
          style: AppStyles.lightTextStyle(context).copyWith(
            color:
                (isDark ? onSurface : AppColors.white).withValues(alpha: 0.74),
            fontSize: 14.sp,
          ),
        ),
        verticalSpace(height: 0.4.h),
      ],
    );
  }
}
