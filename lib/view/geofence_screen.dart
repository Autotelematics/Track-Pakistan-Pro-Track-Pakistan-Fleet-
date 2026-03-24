import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/get_geofence_provider.dart';
import 'package:trackerapp/utils/top_curve_bezier.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/custom_text_field.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class GeofenceScreen extends StatefulWidget {
  const GeofenceScreen({super.key});

  @override
  State<GeofenceScreen> createState() => _GeofenceScreenState();
}

class _GeofenceScreenState extends State<GeofenceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<GeofenceProvider>(context, listen: false);
      if (provider.model == null) {
        provider.fetchGeofence(isRefresh: true, context: context);
      }
    });
  }

  void _onSearchChanged() {
    final provider = Provider.of<GeofenceProvider>(context, listen: false);
    provider.setSearchQuery(_searchController.text);
  }

  Future<void> _onRefresh() async {
    await Provider.of<GeofenceProvider>(context, listen: false)
        .fetchGeofence(isRefresh: true, context: context);
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 8,
        padding: EdgeInsets.zero,
        itemBuilder: (_, __) => Container(
          margin: EdgeInsets.only(bottom: 1.5.h),
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(colors: [theme.cardColor, theme.cardColor])
              : AppColors.mainGradient,
        ),
        child: SizedBox(
          height: 100.h,
          width: 100.w,
          child: Column(
            children: [
              verticalSpace(height: 7.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: isDark ? onSurface : AppColors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Flexible(child: Container()),
                    Text(
                      "Geofences",
                      style: AppStyles.boldTextStyle(context).copyWith(
                          color: isDark ? onSurface : AppColors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600),
                    ),
                    horizontalSpace(width: 15.w),
                    Flexible(child: Container()),
                  ],
                ),
              ),
              verticalSpace(height: 2.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: CustomTextField(
                  controller: _searchController,
                  labelText: "Search Notification",
                  borderRadius: 15.px,
                  fillColor: AppColors.white,
                  suffixIcon: Icons.search_outlined,
                ),
              ),
              verticalSpace(height: 2.h),
              Expanded(
                child: ClipPath(
                  clipper: TopCurveClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? LinearGradient(colors: [
                              theme.scaffoldBackgroundColor,
                              theme.scaffoldBackgroundColor
                            ])
                          : LinearGradient(
                              colors: [Colors.white, Colors.grey.shade100],
                            ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Column(
                      children: [
                        verticalSpace(height: 5.h),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: Consumer<GeofenceProvider>(
                              builder: (context, provider, child) {
                                if (provider.isLoading &&
                                    provider.model == null) {
                                  return _buildShimmer();
                                }
                                if (provider.errorMessage != null &&
                                    provider.model == null) {
                                  return Center(
                                      child: Text(provider.errorMessage!));
                                }
                                final items = provider.filteredGeofence;
                                if (items.isEmpty) {
                                  return Center(
                                    child: Text(
                                      _searchController.text.isNotEmpty
                                          ? "No geofences match your search"
                                          : "No geofences found",
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    final geofence = items[index];
                                    final color = Color(int.parse(geofence
                                        .polygonColor
                                        .replaceAll('#', '0xFF')));

                                    return Container(
                                      margin: EdgeInsets.only(bottom: 1.5.h),
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDark
                                                ? Colors.black.withValues(alpha: 0.4)
                                                : Colors.black
                                                    .withValues(alpha: 0.08),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          radius: 22,
                                          backgroundColor:
                                              color.withValues(alpha: 0.2),
                                          child: Icon(
                                            geofence.type == 'circle'
                                                ? Icons.circle_outlined
                                                : Icons.pentagon_outlined,
                                            color: color,
                                          ),
                                        ),
                                        title: Text(
                                          geofence.name,
                                          style: AppStyles.regularTextStyle(
                                                  context)
                                              .copyWith(
                                            color: onSurface,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${geofence.type.capitalize()} • ${geofence.type == 'circle' ? 'Radius: ${geofence.radius?.toInt()}m' : '${geofence.points.length} points'}',
                                          style:
                                              AppStyles.lightTextStyle(context)
                                                  .copyWith(
                                            color: onSurface.withValues(alpha: 0.7),
                                          ),
                                        ),
                                        trailing: Switch(
                                          value: geofence.active,
                                          activeThumbColor:
                                              ConstantColor.primaryColor,
                                          onChanged: provider.isLoading
                                              ? null
                                              : (val) async {
                                                  final success = await provider
                                                      .toggleGeofenceActive(
                                                          geofence.id);
                                                  if (context.mounted &&
                                                      !success) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              "Failed to update status")),
                                                    );
                                                  }
                                                },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
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

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
