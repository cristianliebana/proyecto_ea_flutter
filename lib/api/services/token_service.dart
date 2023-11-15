import 'package:proyecto_flutter/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class TokenService {
  static Future<String?> getToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (error) {
      return null;
    }
  }

  static Future<void> saveToken(String token) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);
    } catch (error) {
      print('Error al guardar el token: $error');
    }
  }

  static Future<void> removeToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('token');
      Get.to(LoginScreen());
    } catch (error) {
      print('Error al remover el token: $error');
    }
  }

  static Future<bool> loggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      Get.to(LoginScreen());
      return false;
    }

    return true;
  }
}
