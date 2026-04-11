import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/white_labeling/contacts.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactGrid extends StatelessWidget {
  const ContactGrid({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> contactTiles = [];
    final l10n = context.l10n;

    // Phone
    if (CompanyInfo.companyPhone.trim().isNotEmpty) {
      contactTiles.add(
        _ContactTile(
          icon: Icons.call,
          label: l10n.callLabel,
          color: Colors.green,
          onTap: () => _launchUrl('tel:${CompanyInfo.companyPhone}'),
        ),
      );
    }

    // Email
    if (CompanyInfo.companyGmail.trim().isNotEmpty) {
      contactTiles.add(
        _ContactTile(
          icon: Icons.email_outlined,
          label: l10n.emailLabel,
          color: Colors.blue,
          onTap: () => _launchUrl('mailto:${CompanyInfo.companyGmail}'),
        ),
      );
    }

    // Website
    if (CompanyInfo.website.trim().isNotEmpty) {
      contactTiles.add(
        _ContactTile(
          icon: Icons.language,
          label: l10n.websiteLabel,
          color: Colors.purple,
          onTap: () => _launchUrl(CompanyInfo.website),
        ),
      );
    }

    // WhatsApp
    if (CompanyInfo.whatsApp.trim().isNotEmpty) {
      contactTiles.add(
        _ContactTile(
          icon: FontAwesomeIcons.whatsapp,
          label: l10n.whatsAppLabel,
          color: Colors.green[700]!,
          onTap: () => _launchUrl('https://wa.me/${CompanyInfo.whatsApp}'),
        ),
      );
    }

    // Facebook
    if (CompanyInfo.facebook.trim().isNotEmpty) {
      contactTiles.add(
        _ContactTile(
          icon: Icons.facebook,
          label: l10n.facebookLabel,
          color: Colors.indigo,
          onTap: () => _launchUrl(CompanyInfo.facebook),
        ),
      );
    }

    // Instagram
    if (CompanyInfo.instagram.trim().isNotEmpty) {
      contactTiles.add(
        _ContactTile(
          icon: FontAwesomeIcons.instagram,
          label: l10n.instagramLabel,
          color: Colors.pinkAccent,
          onTap: () => _launchUrl(CompanyInfo.instagram),
        ),
      );
    }

    if (contactTiles.isEmpty) {
      return Column(
        children: [
          verticalSpace(height: 2.h),
          Text(
            l10n.noContactInformationAvailable,
            style: AppStyles.lightTextStyle(context).copyWith(fontSize: 14.sp),
          ),
          verticalSpace(height: 2.h),
        ],
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 5.w,
      runSpacing: 1.6.h,
      children: contactTiles,
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 22.w,
        child: Column(
          children: [
            Container(
              width: 13.w,
              height: 13.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.22 : 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon,
                  size: 19.sp,
                  color: isDark ? Colors.white.withValues(alpha: .9) : color),
            ),
            verticalSpace(height: 0.8.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: 13.2.sp,
                color: onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
