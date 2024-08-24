import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {

  // RETRIEVING ACCOUNT
  static Future<Map<String, String>> retrieveSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? '';
    String password = prefs.getString('password') ?? '';
    return {'email': email, 'password': password};
  }

  // SAVING ACCOUNT
  static Future<void> saveCredentials(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }
}