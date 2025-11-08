import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/providers/contact_us_provider.dart';
import 'package:trackerapp/utils/top_curve_bezier.dart';
import 'package:trackerapp/widgets/contact_widgets/address_footer_widget.dart';
import 'package:trackerapp/widgets/contact_widgets/contact_grid_widget.dart';
import 'package:trackerapp/widgets/contact_widgets/explore_section_widget.dart';
import 'package:trackerapp/widgets/contact_widgets/header_section_widget.dart';
import 'package:trackerapp/widgets/contact_widgets/hero_section_widget.dart';
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});
  static const String companyName = "autotelematics Pvt. Ltd";
  static const String companyAddress =
      "A-512, 5th Floor, Saima Trade Towers, I.I Chundrigar Road, Karachi, Pakistan";
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return ChangeNotifierProvider(
      create: (_) => ContactProvider(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
              colors: [Color(0xFF1A1A1A), Color(0xFF121212)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
                : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.purple, AppColors.blueCyanWithOpacity],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HeaderSection(isDark: isDark),
              Expanded(
                child: ClipPath(
                  clipper: TopCurveClipper(),
                  child: Container(
                    color: theme.scaffoldBackgroundColor,
                    padding: EdgeInsets.only(left: 6.w, right: 6.w, top: 4.h, bottom: 2.h),
                    child: const SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          HeroSection(),
                          ContactGrid(),
                          ExploreSection(),
                          AddressFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}