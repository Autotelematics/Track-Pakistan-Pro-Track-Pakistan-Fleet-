import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/data/models/vehicle_data.dart';

class VehicleRepository {
  Future<VehicleData> fetchVehicleData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return VehicleData(
      statuses: [
        StatusData(title: "Offline", count: 104, color: AppColors.blueCyan),
        StatusData(title: "Running", count: 80, color: AppColors.green),
        StatusData(title: "Stopped", count: 20, color: AppColors.red),
        StatusData(title: "Idle", count: 5, color: AppColors.yellow),
        StatusData(title: "No Data", count: 200, color: AppColors.grey),
        StatusData(title: "Expired", count: 150, color: AppColors.purple),
      ],
      vehicles: [
        Vehicle(
          title: "AAT-829",
          speed: "0",
          update: "11:10:2023 09:23:45 PM",
          address: "گلشنِ اقبال، بلاک 7، نزد سفاری پارک، کراچی",
          image:
          "https://cdn.pixabay.com/photo/2013/07/13/11/50/car-158795_1280.png",
          status: "Running",
        ),
        Vehicle(
          title: "ABT-859",
          speed: "0",
          update: "11:10:2023 09:23:45 PM",
          address: "گلشنِ اقبال، بلاک 7، نزد سفاری پارک، کراچی",
          image:
          "https://cdn.pixabay.com/photo/2017/04/06/16/57/car-2208807_1280.png",
          status: "Stopped",
        ),
        Vehicle(
          title: "ABT-859",
          speed: "0",
          update: "11:10:2023 09:23:45 PM",
          address:
          "گلشنِ اقبال بلاک 13، مین یونیورسٹی روڈ، نزدیک بیت المکرم مسجد، کراچی، پاکستان",
          image:
          "https://cdn.pixabay.com/photo/2013/07/13/11/48/bmw-158703_1280.png",
          status: "Idle",
        ),
        Vehicle(
          title: "ABT-859",
          speed: "0",
          update: "11:10:2023 09:23:45 PM",
          address:
          "نارتھ ناظم آباد بلاک H، مدینہ مارکیٹ کے قریب، شاہراہِ نورجہاں، کراچی، سندھ، پاکستان",
          image:
          "https://cdn.pixabay.com/photo/2012/04/13/21/05/car-33633_1280.png",
          status: "Offline",
        ),
        Vehicle(
          title: "ABT-859",
          speed: "0",
          update: "11:10:2023 09:23:45 PM",
          address:
          "نارتھ ناظم آباد بلاک H، مدینہ مارکیٹ کے قریب، شاہراہِ نورجہاں، کراچی، سندھ، پاکستان",
          image:
          "https://cdn.pixabay.com/photo/2013/07/13/11/48/bmw-158703_1280.png",
          status: "NoData",
        ),
        Vehicle(
          title: "ABT-859",
          speed: "0",
          update: "11:10:2023 09:23:45 PM",
          address:
          "نارتھ ناظم آباد بلاک H، مدینہ مارکیٹ کے قریب، شاہراہِ نورجہاں، کراچی، سندھ، پاکستان",
          image:
          "https://cdn.pixabay.com/photo/2023/09/26/19/51/bmw-8278129_1280.png",
          status: "Running",
        ),
      ],
    );
  }
}