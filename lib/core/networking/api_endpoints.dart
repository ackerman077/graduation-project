import '../config/environment_config.dart';

class ApiEndpoints {
  static String get baseUrl => EnvironmentConfig.apiBaseUrl;

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';

  static const String getAllGovernrates = '/governrate/index';

  static const String getAllCities = '/city/index';
  static const String getCitiesByGovernrate = '/city/show/{id}';

  static const String getAllSpecializations = '/specialization/index';
  static const String showSpecialization = '/specialization/show/{id}';

  static const String getAllDoctors = '/doctor/index';
  static const String showDoctor = '/doctor/show/{id}';
  static const String filterDoctors = '/doctor/doctor-filter';
  static const String searchDoctors = '/doctor/doctor-search';

  static const String getAllAppointments = '/appointment/index';
  static const String storeAppointment = '/appointment/store';

  static const String getUserProfile = '/user/profile';
  static const String updateProfile = '/user/update';

  static const String getHomePage = '/home/index';

  static String buildUrl(String endpoint, {Map<String, dynamic>? pathParams}) {
    String url = endpoint;
    if (pathParams != null) {
      pathParams.forEach((key, value) {
        url = url.replaceAll('{$key}', value.toString());
      });
    }
    return url;
  }
}
