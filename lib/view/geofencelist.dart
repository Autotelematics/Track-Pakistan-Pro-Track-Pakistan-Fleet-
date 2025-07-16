import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackerapp/data/response/status.dart';
import 'package:trackerapp/res/colors.dart';
import 'package:trackerapp/utils/utils.dart';
import 'package:trackerapp/view_model/geofence_view_view_model.dart';

class GeoFenceListScreen extends StatefulWidget {
  const GeoFenceListScreen({super.key});

  @override
  State<GeoFenceListScreen> createState() => _GeoFenceListScreenState();
}

class _GeoFenceListScreenState extends State<GeoFenceListScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GeoFenceViewViewModel>(
      create: (_) => GeoFenceViewViewModel()..fetchGeoFenceFromApi(),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Geofence List',
              style: AppColors.appTitleTextStyle,
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            centerTitle: false,
          ),
          body: Consumer<GeoFenceViewViewModel>(
            builder: (context, value, child) {
              if (kDebugMode) {
                print('Consumer rebuilt with status: ${value.geoFenceListResponse.status}');
              }
              switch (value.geoFenceListResponse.status) {
                case Status.LOADING:
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage('assets/images/loading.gif'),
                          width: 100,
                          height: 100,
                        ),
                        SizedBox(height: 5),
                        Text('Loading...'),
                      ],
                    ),
                  );
                case Status.ERROR:
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 100,
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Don't have the permission to delete",
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => value.fetchGeoFenceFromApi(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                case Status.COMPLETED:
                  if (value.geoFenceListResponse.data!.items.geofences.isEmpty) {
                    return const Center(child: Text('No geofences found'));
                  }
                  return ListView.builder(
                    itemCount: value.geoFenceListResponse.data!.items.geofences.length,
                    itemBuilder: (context, index) {
                      final geofence = value.geoFenceListResponse.data!.items.geofences[index];
                      return Card(
                        key: ValueKey(geofence.id),
                        child: ListTile(
                          title: Text(
                            geofence.name.toString(),
                            style: AppColors.settingTextstyle,
                          ),
                          leading: SizedBox(
                            width: 50,
                            child: Checkbox(
                              activeColor: AppColors.buttonColor,
                              value: geofence.active == 1,
                              onChanged: (activationStatus) async {
                                if (activationStatus != null) {
                                  Utils.toastMessage('Updating status...');
                                  await value.changeGeoFenceStatusFromAPI(
                                    geofence.id.toString(),
                                    activationStatus ? 1 : 0,
                                  );
                                }
                              },
                            ),
                          ),
                          trailing: InkWell(
                            child: const Icon(Icons.delete, color: Colors.red),
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Geofence'),
                                  content: Text('Are you sure you want to delete ${geofence.name}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await value.deleteGeoFenceFromAPI(geofence.id.toString());
                              }
                            },
                          ),
                          subtitle: Text(geofence.createdAt),
                        ),
                      );
                    },
                  );
                default:
                  return const SizedBox();
              }
            },
          ),
        ),
      ),
    );
  }
}