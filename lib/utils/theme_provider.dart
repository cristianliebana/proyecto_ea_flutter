import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends GetxController {
  RxBool _isDarkMode = false.obs;

  bool get isDarkMode => _isDarkMode.value;

  Future<void> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode.value = prefs.getBool('isDarkMode') ?? false;
  }

  ThemeData getTheme() {
    return _isDarkMode.value ? _darkTheme : _lightTheme;
  }

  void toggleTheme() async {
    _isDarkMode.toggle();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode.value);
  }

  static final ThemeData _lightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFFFFCEA),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFFFFCEA),
      onPrimary: Color(0xFF486D28),
    ),
    primaryColor: Colors.black,
    secondaryHeaderColor: Colors.grey,
    shadowColor: const Color.fromARGB(255, 99, 99, 99),
    dividerColor: const Color(0xFF486D28),
    canvasColor: const Color(0xFF737373),
    focusColor: Colors.green.shade700,
    disabledColor: Colors.red,
    cardColor: const Color(0xFF486D28),
  );

  static final ThemeData _darkTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFF486D28),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF486D28),
      onPrimary: Color(0xFFFFFCEA),
    ),
    primaryColor: const Color(0xFFFFFCEA),
    secondaryHeaderColor: Colors.grey[300],
    shadowColor: const Color(0xFFFFFCEA),
    /*const Color.fromARGB(255, 168, 168, 168),*/
    // dividerColor: const Color(0xFF4D4B43),
    dividerColor: const Color.fromARGB(255, 85, 13, 8),
    canvasColor: Colors.grey[300],
    focusColor: const Color(0xFFFFFCEA),
    disabledColor: const Color.fromARGB(255, 85, 13, 8),
    cardColor: Color.fromARGB(255, 52, 78, 29),
  );
}
