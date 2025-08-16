import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:getwidget/getwidget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackerapp/repository/change_password_repository.dart';
import 'package:trackerapp/res/colors.dart';
import 'package:trackerapp/res/components/submitbutton.dart';
import 'package:trackerapp/utils/routes/routes_name.dart';
import 'package:trackerapp/utils/utils.dart';
import 'package:trackerapp/view/home.dart';
import 'package:trackerapp/view_model/expnese_record_view_model.dart';
import 'package:trackerapp/view_model/services/usersessiondata.dart';
import 'package:trackerapp/view_model/userlogin_view_model.dart';
import 'package:trackerapp/view_model/vehicle_maintenance_view_model.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  FlutterTts ftts = FlutterTts();
  SharedPreferences? sp;
  bool currentCheckBoxValue = false;
  double? fuelprice = 200;
  String? userID = 'User ID';
  bool _hasFetched = false;

  Future<bool> getSharedPreferenceInstance() async {
    sp = await SharedPreferences.getInstance();
    currentCheckBoxValue = sp!.getBool('playAlertSounds') ?? false;
    userID = sp!.getString('userid');
    fuelprice = sp!.getDouble('fuelPrice');
    return currentCheckBoxValue;
  }

  Future<void> setFuelPrice(BuildContext context) {
    final fuelPriceController = TextEditingController();
    FocusNode fuelFocusNode = FocusNode();
    return showDialog(
      useSafeArea: true,
      barrierDismissible: true,
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Set Fuel Price'),
                        InkWell(
                          child: const Icon(Icons.close),
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: fuelPriceController,
                      focusNode: fuelFocusNode,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        disabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        labelText: "Current Fuel Cost per Liter",
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xff000000),
                        ),
                        filled: true,
                        fillColor: Color(0xfff2f2f3),
                        isDense: false,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        prefixIcon: Icon(
                          Icons.price_change_outlined,
                          color: Color(0xff212435),
                          size: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SubmitButton(
                      title: 'Set Fuel Price',
                      onPresse: () async {
                        if (double.parse(fuelPriceController.text) < 200 ||
                            double.parse(fuelPriceController.text) > 1000) {
                          Utils.toastMessage(
                              'Please enter value from 200 to 1000 range');
                          fuelPriceController.clear();
                          fuelFocusNode.requestFocus();
                          return;
                        }
                        final SharedPreferences sp =
                        await SharedPreferences.getInstance();
                        sp.setDouble('fuelPrice',
                            double.parse(fuelPriceController.text));
                        await getSharedPreferenceInstance();
                        setState(() {});
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> changePassword(BuildContext context) async {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    FocusNode passwordFocusNode = FocusNode();

    final userLoginViewModel = Provider.of<UserLoginViewModel>(context, listen: false);
    final changePasswordRepository = ChangePasswordRepository();
    Future<String> userApiKey = userLoginViewModel.getUserApiHashString();

    return showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Change Password'),
                        InkWell(
                          child: const Icon(Icons.close),
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    TextField(
                      controller: passwordController,
                      focusNode: passwordFocusNode,
                      autofocus: true,
                      decoration: const InputDecoration(
                        disabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        labelText: "Password",
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xff000000),
                        ),
                        filled: true,
                        fillColor: Color(0xfff2f2f3),
                        isDense: false,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        prefixIcon: Icon(
                          Icons.price_change_outlined,
                          color: Color(0xff212435),
                          size: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: confirmPasswordController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        disabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        labelText: "Confirm Password",
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xff000000),
                        ),
                        filled: true,
                        fillColor: Color(0xfff2f2f3),
                        isDense: false,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        prefixIcon: Icon(
                          Icons.price_change_outlined,
                          color: Color(0xff212435),
                          size: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SubmitButton(
                      title: 'Change Password',
                      onPresse: () async {
                        String userApiKeyString = await userApiKey;
                        if (passwordController.text.isEmpty ||
                            confirmPasswordController.text.isEmpty) {
                          Utils.flushBarErrorMessage(
                              'Please enter password', context);
                          return;
                        }
                        if (passwordController.text !=
                            confirmPasswordController.text) {
                          passwordController.clear();
                          confirmPasswordController.clear();
                          passwordFocusNode.requestFocus();
                          Utils.flushBarErrorMessage(
                              'Confirmation Password does not match', context);
                          return;
                        }
                        changePasswordRepository
                            .changePasswordFromApi(
                            userApiKeyString, passwordController.text)
                            .then((value) {
                          if (value.status == 1) {
                            Utils.toastMessage('Password has been changed');
                            Future.delayed(
                              const Duration(seconds: 1),
                                  () {
                                navBarIndex = 0;
                                userLoginViewModel
                                    .userSessionRemove()
                                    .then((value) {
                                  Provider.of<UserSessionData>(context, listen: false)
                                      .checkusersession(context);
                                });
                              },
                            );
                          } else {
                            Utils.flushBarErrorMessage(
                                value.message.toString(), context);
                          }
                        }).onError((error, stackTrace) {
                          Utils.flushBarErrorMessage(
                              'Password cannot be changed at this moment',
                              context);
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Removed Provider.of calls from initState to avoid ProviderNotFoundException
    getSharedPreferenceInstance().then((value) {
      setState(() {
        currentCheckBoxValue = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => UserSessionData()),
        ChangeNotifierProvider(create: (_) => UserLoginViewModel()),
        ChangeNotifierProvider(create: (_) => VehicleMaintenanceViewModel()),
        ChangeNotifierProvider(create: (_) => ExpenseRecordViewModel()),
      ],
      child: SafeArea(
        child: Consumer2<VehicleMaintenanceViewModel, ExpenseRecordViewModel>(
          builder: (context, vehicleMaintenanceViewModel, expenseRecordViewModel, child) {
            // Fetch data only once after providers are available
            if (!_hasFetched) {
              _hasFetched = true;
              expenseRecordViewModel.fetchExpenseRecordsForVehicle('');
              vehicleMaintenanceViewModel.fetchVehicleMaintenanceList('');
            }
            return DecoratedBox(
              decoration: AppColors.appScreenBackgroundImage,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: Text(
                    'Settings',
                    style: AppColors.appTitleTextStyle,
                  ),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  centerTitle: false,
                ),
                body: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(height: 0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 30,
                            width: MediaQuery.of(context).size.width,
                            color: AppColors.buttonColor,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.person),
                                    Text(
                                      'Profile',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width - 10,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Card(
                                  shape: AppColors.cardBorderShape,
                                  child: ListTile(
                                    contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                    leading: const CircleAvatar(
                                      backgroundColor:
                                      Color.fromARGB(247, 6, 84, 117),
                                      radius: 16,
                                      child: Icon(size: 18, Icons.person),
                                    ),
                                    title: Text(
                                      userID.toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    trailing: GFButton(
                                      onPressed: () {
                                        navBarIndex = 0;
                                        Provider.of<UserLoginViewModel>(context, listen: false)
                                            .userSessionRemove()
                                            .then((value) {
                                          Provider.of<UserSessionData>(context, listen: false)
                                              .checkusersession(context);
                                        });
                                      },
                                      text: "Logout",
                                      textStyle:
                                      AppColors.settingPageButtonTextStyle,
                                      color: AppColors.buttonColor,
                                      shape: GFButtonShape.pills,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Card(
                                  shape: AppColors.cardBorderShape,
                                  child: ListTile(
                                    contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                    leading: const CircleAvatar(
                                      backgroundColor:
                                      Color.fromARGB(247, 11, 105, 6),
                                      radius: 16,
                                      child: Icon(size: 18, Icons.key),
                                    ),
                                    title: const Text(
                                      'Password',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    trailing: GFButton(
                                      onPressed: () => changePassword(context),
                                      text: 'Change',
                                      textStyle:
                                      AppColors.settingPageButtonTextStyle,
                                      color: AppColors.buttonColor,
                                      shape: GFButtonShape.pills,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            color: AppColors.buttonColor,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.settings),
                                      Text(
                                        'Tools',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width - 10,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Card(
                                  shape: AppColors.cardBorderShape,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, RoutesName.geoFenceList);
                                    },
                                    child: ListTile(
                                      contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 8.0),
                                      leading: const CircleAvatar(
                                        backgroundColor:
                                        Color.fromARGB(247, 5, 93, 152),
                                        radius: 16,
                                        child: Icon(size: 18, Icons.fence),
                                      ),
                                      title: Text(
                                        'Geofecne Settings', // Typo retained from old version
                                        style: AppColors.settingTextstyle,
                                      ),
                                      trailing: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(Icons.arrow_forward),
                                      ),
                                    ),
                                  ),
                                ),
                                Card(
                                  shape: AppColors.cardBorderShape,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, RoutesName.alertsTypeList);
                                    },
                                    child: ListTile(
                                      contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 8.0),
                                      leading: const CircleAvatar(
                                        backgroundColor:
                                        Color.fromARGB(247, 91, 4, 153),
                                        radius: 16,
                                        child: Icon(size: 18, Icons.notifications),
                                      ),
                                      title: Text(
                                        'Alerts Settings',
                                        style: AppColors.settingTextstyle,
                                      ),
                                      trailing: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(Icons.arrow_forward),
                                      ),
                                    ),
                                  ),
                                ),
                                Card(
                                  shape: AppColors.cardBorderShape,
                                  child: ListTile(
                                    contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                    leading: const CircleAvatar(
                                      backgroundColor:
                                      Color.fromARGB(247, 144, 6, 132),
                                      radius: 16,
                                      child: Icon(size: 18, Icons.speaker),
                                    ),
                                    title: Text(
                                      'Play Alerts Announcement',
                                      style: AppColors.settingTextstyle,
                                    ),
                                    trailing: SizedBox(
                                      width: 50,
                                      child: Checkbox(
                                        activeColor: AppColors.buttonColor,
                                        onChanged: (checkboxValue) async {
                                          setState(() {
                                            currentCheckBoxValue = checkboxValue ?? false;
                                          });
                                          sp!.setBool('playAlertSounds', currentCheckBoxValue);
                                        },
                                        value: currentCheckBoxValue,
                                      ),
                                    ),
                                  ),
                                ),
                                Card(
                                  shape: AppColors.cardBorderShape,
                                  child: ListTile(
                                    contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                    leading: const CircleAvatar(
                                      backgroundColor:
                                      Color.fromARGB(247, 182, 63, 8),
                                      radius: 16,
                                      child: Icon(size: 18, Icons.gas_meter_outlined),
                                    ),
                                    title: Text(
                                      'Fuel Cost : Rs.$fuelprice/l',
                                      style: AppColors.settingTextstyle,
                                    ),
                                    trailing: GFButton(
                                      onPressed: () => setFuelPrice(context),
                                      text: "Set Price",
                                      textStyle:
                                      AppColors.settingPageButtonTextStyle,
                                      color: AppColors.buttonColor,
                                      shape: GFButtonShape.pills,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, RoutesName.viewExpenseScreen,
                                        arguments: {'vehicleId': ''});
                                  },
                                  child: Card(
                                    shape: AppColors.cardBorderShape,
                                    margin: const EdgeInsets.symmetric(horizontal: 5),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const CircleAvatar(
                                                maxRadius: 16,
                                                backgroundColor: Colors.blueAccent,
                                                child: Icon(
                                                    Icons.attach_money_outlined,
                                                    size: 18),
                                              ),
                                              const VerticalDivider(width: 24),
                                              Text(
                                                'Vehicle Expenses',
                                                style: AppColors.settingTextstyle,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Consumer<ExpenseRecordViewModel>(
                                                builder: (context, viewModel, _) {
                                                  double totalAmount =
                                                  viewModel.calculateTotalAmount();
                                                  return Text('Rs.$totalAmount');
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, RoutesName.viewMaintenanceSchedule);
                                  },
                                  child: Card(
                                    shape: AppColors.cardBorderShape,
                                    margin: const EdgeInsets.symmetric(horizontal: 5),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                maxRadius: 16,
                                                backgroundColor: Colors.red[800],
                                                child: const Icon(
                                                  Icons.car_repair,
                                                  size: 18,
                                                ),
                                              ),
                                              const VerticalDivider(width: 24),
                                              Text(
                                                'Maintenance',
                                                style: AppColors.settingTextstyle,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    maxRadius: 16,
                                                    child: Consumer<
                                                        VehicleMaintenanceViewModel>(
                                                      builder:
                                                          (context, viewModel, _) {
                                                        return Text(viewModel
                                                            .maintenanceList.length
                                                            .toString());
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(width: 3),
                                                  InkWell(
                                                    onTap: () => Navigator.pushNamed(
                                                        context,
                                                        RoutesName
                                                            .addVehicleMaintenanceScreen),
                                                    child: const CircleAvatar(
                                                        maxRadius: 16,
                                                        child: Text('+')),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: SubmitButton(
                                    title: 'Play',
                                    onPresse: () async {
                                      await ftts.setLanguage("en-US");
                                      await ftts.setSpeechRate(0.6);
                                      await ftts.setVolume(1.0);
                                      await ftts.setPitch(1);
                                      var result = await ftts.speak("Vehicle-Ignition-Turned-Off");
                                      if (result == 1) {
                                        // speaking
                                      } else {
                                        // not speaking
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}