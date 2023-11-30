import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proyecto_flutter/bindings/map_Bindings.dart';
import 'package:proyecto_flutter/screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KM0 MARKET',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFFFCEA),
      ),
      home: const SplashScreen(),
      initialBinding: MapPageBinding(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Image.asset('assets/images/logo.jpeg'),
      ),
      backgroundColor: Color(0xFFFFFCEA),
      nextScreen: LoginScreen(),
      splashIconSize: 500,
      duration: 1000,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
    );
  }
}
