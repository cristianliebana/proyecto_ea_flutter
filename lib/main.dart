import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proyecto_flutter/bindings/map_Bindings.dart';
import 'package:proyecto_flutter/screens/login.dart';
import 'package:proyecto_flutter/screens/map.dart';
import 'package:proyecto_flutter/utils/theme_provider.dart';

void main() async {
  Get.put(ThemeProvider());
  Get.put(MapPageController());
  await Get.find<ThemeProvider>().loadTheme();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ThemeProvider themeProvider = Get.find<ThemeProvider>();
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'KM0 MARKET',
        theme: themeProvider.getTheme(),
        home: const SplashScreen(),
        initialBinding: MapPageBinding(),
      );
    });
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = Get.find<ThemeProvider>();

    String splashImage = themeProvider.isDarkMode
        ? 'assets/images/logo2.png'
        : 'assets/images/logo.jpeg';
    return AnimatedSplashScreen(
      splash: Center(
        child: Image.asset(splashImage),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      nextScreen: LoginScreen(),
      splashIconSize: 500,
      duration: 1000,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
    );
  }
}
