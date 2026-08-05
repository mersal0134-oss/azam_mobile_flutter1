import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static Future<String?> get baseUrl async => (await SharedPreferences.getInstance()).getString('baseUrl');
  static Future<String?> get apiToken async => (await SharedPreferences.getInstance()).getString('apiToken');
  static Future<void> setBaseUrl(String v) async => (await SharedPreferences.getInstance()).setString('baseUrl', v);
  static Future<void> setApiToken(String v) async => (await SharedPreferences.getInstance()).setString('apiToken', v);
}
