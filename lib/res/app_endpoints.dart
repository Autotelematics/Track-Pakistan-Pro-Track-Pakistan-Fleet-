class AppUrl {
  ///BaseUrl
  static var baseURL = 'https://world.autotel.pk/api';
  static var baseImgURL = 'https://world.autotel.pk/';

  ///Apis EndPoints
  static String loginEp = "/login?";
  static String getDashboardEp = "/get_dashboard?";
  static String getAdminStatusEp = "/admin/get_admin_status?user_api_hash=";
  static String getAdminUserListEp =
      "/admin/get_admin_user_list?user_api_hash=";
  static String getAdminUsersWithTokensEp =
      "/admin/get_admin_users_with_tokens?user_api_hash=";
  static String setAdminUserStatusEp =
      "/admin/set_admin_user_status?user_api_hash=";
  static String adminLoginAsEp = "/admin/login_as?user_api_hash=";
  static String sendPushNotificationEp = "/send_push_notification?";
  static String getDashboardHistoryEp = "/get_dashboard_history?";
  static String getDeviceListEp = "/get_devices_list?user_api_hash=";
  static String getDeviceGroupEp = "/get_device_group?user_api_hash=";
  static String getDeviceHistoryEp = "/single_vehicle_history?user_api_hash=";
  static String getDeviceLiveTrackingEp = "/live_tracking?user_api_hash=";
  static String getDeviceReportsEp = "/get_reports_types?user_api_hash=";
  static String generateReportsEp = "/generate_report?user_api_hash=";
  static String changePasswordEp = "/change_password?user_api_hash=";
  static String getDeviceStatusEp = "/get_status?user_api_hash=";
  static String geofenceEp = "/get_geofences?user_api_hash=";
  static String changeActiveGeofenceEp =
      "/change_active_geofence?user_api_hash=";
  static String addDriverUserEp = "/add_user_driver?user_api_hash=";
  static String editDriverUserEp = "/edit_user_driver?user_api_hash=";
  static String deleteDriverUserEp = "/destroy_user_driver?user_api_hash=";
  static String getDriverUserEp = "/get_user_drivers?user_api_hash=";
  static String addDeviceToDriverEp = "/Adddevicetodriver?user_api_hash=";
  static String setDeviceDriverEp = "/set_device_driver?user_api_hash=";
  static String getVehicleDriverEp = "/get_vehicle_driver?user_api_hash=";
  static String getDeviceCommandsEp = "/get_device_commands?user_api_hash=";
  static String sendDeviceCommandsEp = "/send_gprs_command?user_api_hash=";
  static String getCompanyDetailsEp = "/get_company_details?user_api_hash=";
  static String updateDeviceDataEp = "/device/update-data";
  static String deviceExpensesListEp = "/device-expenses/list";
  static String deviceExpensesCreateEp = "/device-expenses/create";
  static String deviceExpensesUpdateEp = "/device-expenses/update";
  static String deviceExpensesDeleteEp = "/device-expenses/delete";
  static String deviceExpensesTypesEp = "/device-expenses/types";
  static String deviceExpensesSuppliersEp = "/device-expenses/suppliers";
  static String deviceServicesEp = "/service-api";
  static String deviceServicesCreateEp = "/services";
  static String getTasksListEp = "/get_tasks_list";
  static String createTaskEp = "/tasks/create";
  static String updateTaskEp = "/tasks/update";
  static String deleteTaskEp = "/tasks/delete";
  static String assignTaskEp = "/tasks/assign";
  static String managerChatThreadEp = "/manager-chat/thread";
  static String managerChatCreateThreadEp = "/manager-chat/thread/create";
  static String addressAutocompleteEp = "/address/autocomplete";
  static String geoAddressEp = "/geo_address";

  static String alertsEp = '/get_alert_list?user_api_hash=';
  static String deleteEp = '/delete_alert?user_api_hash=';
  static String getAlertSettingEp = '/get_alert_setting?user_api_hash=';
  static String syncAlertSettingEp = '/sync_alert_setting?user_api_hash=';
  static String syncAlertActiveEp = '/sync_alert_active?user_api_hash=';
  static String syncAlertAnnouncementEp =
      '/sync_alert_announcement?user_api_hash=';
  static String vehiclePerformanceEp = '/vehicle_performance?';
  static String driverPerformanceEp = '/driver_performance?';
  static String submitFcmTokenEp = '/fcm_token';
  static String deleteFcmTokenEp = '/delete_fcm_token';
}
