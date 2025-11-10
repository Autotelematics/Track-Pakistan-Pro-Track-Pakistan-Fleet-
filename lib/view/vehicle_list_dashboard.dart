import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/providers/vehicle_list_provider.dart';
import 'package:trackerapp/widgets/filter_widget.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/filter_button.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/search_bar.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/status_box.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/vehicle_card.dart';

class NewVehicleListDashBoard extends StatefulWidget {
  const NewVehicleListDashBoard({super.key});

  @override
  State<NewVehicleListDashBoard> createState() =>
      _NewVehicleListDashBoardState();
}

class _NewVehicleListDashBoardState extends State<NewVehicleListDashBoard> {
  late final VehicleListProvider _provider;
  @override
  void initState() {
    super.initState();
    _provider = Provider.of<VehicleListProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final cardColor = theme.cardColor;
    final primary = theme.colorScheme.primary;
    final outline = theme.colorScheme.outline;

    return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body:
            Consumer<VehicleListProvider>(builder: (context, provider, child) {
          return Stack(
            children: [
              // Main Content
              _buildMainContent(
                  context, theme, onSurface, cardColor, primary, outline),
              // Filter Overlay
              CommonFilterOverlay(
                  isFilterOpen: _provider.isFilterOpen,
                  onClose: _provider.toggleFilter,
                  onApply: () {},
                  filterItems: _provider.filterItems,
                  cardColor: cardColor,
                  primary: primary,
                  onSurface: onSurface)
            ],
          );
        }));
  }

  // MAIN CONTENT
  Widget _buildMainContent(
    BuildContext context,
    ThemeData theme,
    Color onSurface,
    Color cardColor,
    Color primary,
    Color outline,
  ) {
    return Consumer<VehicleListProvider>(
      builder: (context, provider, child) {
        // Loading
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error
        if (provider.error != null) {
          return _buildErrorState(provider, context);
        }

        // No Data
        if (provider.vehicleData == null) {
          return const Center(child: Text('No data available'));
        }

        final data = provider.vehicleData!;

        return Column(
          children: [
            verticalSpace(height: 6.h),

            // Status Boxes Row
            _buildStatusBoxes(data, onSurface, cardColor),

            verticalSpace(height: 1.h),

            // Search + Filter Row
            _buildSearchAndFilterRow(primary, onSurface, outline),

            // Vehicle List
            _buildVehicleList(provider, theme),
          ],
        );
      },
    );
  }

  // STATUS BOXES
  Widget _buildStatusBoxes(dynamic data, Color onSurface, Color cardColor) {
    return SizedBox(
      height: 7.7.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
        itemCount: data.statuses.length,
        itemBuilder: (context, index) => StatusBox(
          status: data.statuses[index],
          onSurface: onSurface,
          cardColor: cardColor,
        ),
      ),
    );
  }

  // SEARCH + FILTER ROW
  Widget _buildSearchAndFilterRow(
      Color primary, Color onSurface, Color outline) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Row(
        children: [
          Expanded(
            child: SearchFiled(
              primary: primary,
              onSurface: onSurface,
              outline: outline,
            ),
          ),
          horizontalSpace(width: 3.w),
          FilterButton(
            onSurface: onSurface,
            primary: primary,
          ),
        ],
      ),
    );
  }

  // VEHICLE LIST
  Widget _buildVehicleList(VehicleListProvider provider, ThemeData theme) {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 3.w,vertical: 0),
        itemCount: provider.filteredVehicles.length,
        itemBuilder: (_, i) => VehicleCard(
          vehicle: provider.filteredVehicles[i],
          theme: theme,
        ),
      ),
    );
  }

  // ERROR STATE
  Widget _buildErrorState(VehicleListProvider provider, BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${provider.error}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            verticalSpace(height: 2.h),
            ElevatedButton(
              onPressed: provider.fetchData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
