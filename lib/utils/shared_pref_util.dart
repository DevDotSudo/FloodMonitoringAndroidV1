import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefUtil {
  static const String _keyEmail = 'email';
  static const String _keyPassword = 'password';
  static const String _keyIsGoogleSignIn = 'is_google_sign_in';
  static const String _isFilledUp = 'is-filled-up';

  Future<void> saveLoginCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
    await prefs.setBool(_keyIsGoogleSignIn, false);
  }

  Future<void> saveFillup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFilledUp, true);
  }

  Future<bool?> isFillup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFilledUp);
  }

  Future<bool?> clearFillup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_isFilledUp, false);
  }
  
  Future<void> saveGoogleSignIn(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.remove(_keyPassword);
    await prefs.setBool(_keyIsGoogleSignIn, true);
  }

  Future<Map<String, dynamic>> getLoginCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(_keyEmail),
      'password': prefs.getString(_keyPassword),
      'isGoogleSignIn': prefs.getBool(_keyIsGoogleSignIn) ?? false,
    };
  }

  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPassword);
    await prefs.remove(_keyIsGoogleSignIn);
  }
}
