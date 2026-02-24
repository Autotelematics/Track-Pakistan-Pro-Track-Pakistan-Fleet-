import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
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

    // Phone
    if (CompanyInfo.companyPhone.trim().isNotEmpty) {
      contactTiles.add(
        _ContactTile(
          icon: Icons.call,
          label: "Call",
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
          label: "Email",
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
          label: "Website",
          color: Colors.purple,
          onTap: () => _launchUrl(CompanyInfo.website),
        ),
      );
    }

    // WhatsApp
    if (CompanyInfo.whatsApp.trim().isNotEmpty) {
      contactTiles.add(
        _ContactTile(
          icon: Icons.chat,
          label: "WhatsApp",
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
          label: "Facebook",
          color: Colors.indigo,
          onTap: () => _launchUrl(CompanyInfo.facebook),
        ),
      );
    }

    // Instagram
    if (CompanyInfo.instagram.trim().isNotEmpty) {
      contactTiles.add(
        _ContactTile(
          icon: Icons.camera_alt,
          label: "Instagram",
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
            "No contact information available",
            style: AppStyles.lightTextStyle(context),
          ),
          verticalSpace(height: 2.h),
        ],
      );
    }

    return Wrap(
      spacing: 4.w,
      runSpacing: 2.5.h,
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26.w,
        padding: EdgeInsets.symmetric(vertical: 2.3.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.grey[300]!,
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24.sp, color: isDark ? Colors.white70 : color),
            verticalSpace(height: 1.2.h),
            Text(
              label,
              style: AppStyles.regularTextStyle(context).copyWith(fontSize: 16.sp),
            ),
          ],
        ),
      ),
    );
  }
}