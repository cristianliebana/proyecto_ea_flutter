// language_controller.dart

import 'dart:ui';

import 'package:get/get.dart';

class LanguageController extends GetxController {
  final Rx<Locale?> _locale = Rx<Locale?>(Get.locale);

  Locale? get locale => _locale.value;

  void changeLanguage(Locale newLocale) {
    _locale.value = newLocale;
    Get.updateLocale(newLocale);
  }
}

final LanguageController languageController = LanguageController();
