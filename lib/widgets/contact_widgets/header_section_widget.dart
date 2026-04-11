import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/view/setting_screens/manager_chat_screen.dart';

class HeaderSection extends StatelessWidget {
  final bool isDark;
  const HeaderSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final titleColor = AppColors.white;
    final subtitleColor = AppColors.white.withValues(alpha: 0.78);
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 5.w, right: 5.w, bottom: 1.4.h),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 5.8.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: titleColor,
                        size: 20.sp,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22.w),
                    child: Text(
                      l10n.companySupport,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.boldTextStyle(context).copyWith(
                        color: titleColor,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManagerChatScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF16A34A),
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.2.w,
                          vertical: 0.8.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                          side: const BorderSide(
                            color: Color(0xFF86EFAC),
                          ),
                        ),
                      ),
                      icon: Icon(
                        Icons.chat_bubble_rounded,
                        size: 16.sp,
                      ),
                      label: Text(
                        l10n.liveChat,
                        style: AppStyles.semiboldTextStyle(context).copyWith(
                          color: Colors.white,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              l10n.contactCompanyDetails,
              style: AppStyles.regularTextStyle(context).copyWith(
                color: subtitleColor,
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
