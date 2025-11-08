import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/contact_us_provider.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
class ContactGrid extends StatelessWidget {
  const ContactGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ContactProvider>(context);
    return Wrap(
      spacing: 4.w,
      runSpacing: 2.5.h,
      children: [
        _ContactTile(provider: provider, index: 0, icon: Icons.call, label: "Call", color: Colors.green),
        _ContactTile(provider: provider, index: 1, icon: Icons.email_outlined, label: "Email", color: Colors.blue),
        _ContactTile(provider: provider, index: 2, icon: Icons.language, label: "Website", color: Colors.purple),
        _ContactTile(provider: provider, index: 4, icon: Icons.facebook, label: "Facebook", color: Colors.indigo),
        _ContactTile(provider: provider, index: 5, icon: Icons.camera_alt, label: "Instagram", color: Colors.pinkAccent),
      ],
    );
  }
}
class _ContactTile extends StatelessWidget {
  final ContactProvider provider;
  final int index;
  final IconData icon;
  final String label;
  final Color color;

  const _ContactTile({
    required this.provider,
    required this.index,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = provider.selectedIndex == index;

    return GestureDetector(
      onTap: () => selected ? provider.clearSelection() : provider.selectIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        width: 26.w,
        padding: EdgeInsets.symmetric(vertical: 2.3.h),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(isDark ? 0.2 : 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : (isDark ? Colors.white24 : Colors.grey[300])!,
            width: selected ? 2 : 1.2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24.sp, color: selected ? color : (isDark ? Colors.white70 : color)),
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