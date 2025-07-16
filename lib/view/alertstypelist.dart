import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackerapp/data/response/status.dart';
import 'package:trackerapp/res/colors.dart';
import 'package:trackerapp/utils/utils.dart';
import 'package:trackerapp/view_model/alerts_list_view_model.dart';
class AlertsTypeListScreen extends StatefulWidget {
  const AlertsTypeListScreen({super.key});
  @override
  State<AlertsTypeListScreen> createState() => _AlertsTypeListScreenState();
}
class _AlertsTypeListScreenState extends State<AlertsTypeListScreen> {
  bool _hasFetched = false;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AlertsListViewModel>(
      create: (_) => AlertsListViewModel(),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Alerts Settings',
              style: AppColors.appTitleTextStyle,
            ),
            elevation: 0,
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            centerTitle: false,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20), // Align with old GeoFenceListScreen structure
              Consumer<AlertsListViewModel>(
                builder: (context, value, _) {
                  // Fetch data only once after provider is available
                  if (!_hasFetched) {
                    _hasFetched = true;
                    value.fetchAlertsTypeListFromAPI();
                  }
                  switch (value.alertsListResponse.status) {
                    case Status.LOADING:
                      return Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Image(
                                  image: AssetImage('assets/images/loading.gif'),
                                  width: 100,
                                  height: 100),
                              SizedBox(height: 5),
                              Text('Loading...'),
                            ],
                          ),
                        ),
                      );
                    case Status.ERROR:
                      return Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Image(
                                  image: AssetImage('assets/images/loading.gif'),
                                  width: 100,
                                  height: 100),
                              SizedBox(height: 5),
                              Text(AppColors.errorMessage),
                            ],
                          ),
                        ),
                      );
                    case Status.COMPLETED:
                      if (value.alertsListResponse.data?.items?.alerts.isEmpty ?? true) {
                        return const Expanded(
                          child: Center(
                            child: Text('No alerts available'),
                          ),
                        );
                      }
                      return Expanded(
                        child: ListView.builder(
                          itemCount: value.alertsListResponse.data!.items?.alerts.length,
                          itemBuilder: (context, index) {
                            final alert = value.alertsListResponse.data!.items?.alerts[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: Card(
                                shape: AppColors.cardBorderShape,
                                child: ListTile(
                                  title: Text(
                                    alert?.name.toString()??"",
                                    style: AppColors.settingTextstyle,
                                  ),
                                  trailing: SizedBox(
                                    width: 50, // Align with GeoFenceListScreen
                                    child: Checkbox(
                                      activeColor: AppColors.buttonColor,
                                      value: alert?.active == 1,
                                      onChanged: (checkboxValue) async {
                                        Utils.toastMessage('Updating...');
                                        await Future.delayed(const Duration(milliseconds: 100));
                                        if (checkboxValue == true) {
                                          value.changeAlertActivation(
                                              alert?.id.toString()??"", 'true');
                                        } else {
                                          value.changeAlertActivation(
                                              alert?.id.toString()??"", 'false');
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    default:
                      return const Expanded(child: Text('Something went wrong'));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}