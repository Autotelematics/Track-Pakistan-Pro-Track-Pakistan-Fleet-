class AppUrl{
  ///BaseUrl
  static var baseURL = 'https://world.autotel.pk/api';
  static var baseImgURL = 'https://world.autotel.pk/';

  ///Apis EndPoints
 static String loginEp ="/login?";
 static String getDashboardEp ="/get_dashboard?";
 static String getDashboardHistoryEp ="/get_dashboard_history?";
 static String getDeviceListEp="/get_devices_list?user_api_hash=";
 static String getDeviceGroupEp="/get_device_group?user_api_hash=";
 static String getDeviceHistoryEp="/single_vehicle_history?user_api_hash=";
 static String getDeviceLiveTrackingEp="/live_tracking?user_api_hash=";
 static String getDeviceReportsEp="/get_reports_types?user_api_hash=";
 static String generateReportsEp="/generate_report?user_api_hash=";
 static String changePasswordEp="/change_password?user_api_hash=";
 static String getDeviceStatusEp="/get_status?user_api_hash=";
 static String geofenceEp="/get_geofences?user_api_hash=";
 static String changeActiveGeofenceEp="/change_active_geofence?user_api_hash=";
 static String addDriverUserEp="/add_user_driver?user_api_hash=";
 static String editDriverUserEp="/edit_user_driver?user_api_hash=";
 static String getDriverUserEp="/get_user_drivers?user_api_hash=";
 static String addDeviceToDriverEp="/Adddevicetodriver?user_api_hash=";
 static String getDeviceCommandsEp="/get_device_commands?user_api_hash=";
 static String sendDeviceCommandsEp="/send_gprs_command?user_api_hash=";


  static String alertsEp = '/get_alert_list?user_api_hash=';
 static String deleteEp = '/delete_alert?user_api_hash=';





}