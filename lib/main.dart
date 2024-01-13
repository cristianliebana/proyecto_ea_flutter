import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proyecto_flutter/LocaleString.dart';
import 'package:proyecto_flutter/bindings/map_Bindings.dart';
import 'package:proyecto_flutter/firebase_options.dart';
import 'package:proyecto_flutter/screens/login.dart';
import 'package:proyecto_flutter/screens/map.dart';
import 'package:proyecto_flutter/utils/theme_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'dart:html' as html;

// ignore: unused_import
import 'package:proyecto_flutter/widget/language_controller.dart';

void main() async {
  Get.put(ThemeProvider());
  Get.put(MapPageController());
  await Get.find<ThemeProvider>().loadTheme();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '237252769614-0cloeot1ejqj1viu44ceneheerpm4df8.apps.googleusercontent.com',
  );
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
        title: 'Km0Market',
        theme: themeProvider.getTheme(),
        home:  SplashScreen(),
        initialBinding: MapPageBinding(),
        translations: LocaleString(),
        locale: const Locale('es'),

      );
    });
  }
}

class SplashScreen extends StatelessWidget {
   SplashScreen({super.key});
  
  final List locale =[
    {'name': 'Español', 'locale': Locale('es')},
    {'name': 'English', 'locale': Locale('en')},
  ];
  updateLanguage(Locale locale){
    Get.back();
    Get.updateLocale(locale);
  }

  buildLanguageDialog(BuildContext context){
    showDialog(context: context,
        builder: (builder){
           return AlertDialog(
             title: Text('Choose Your Language'),
             content: Container(
               width: double.maxFinite,
               child: ListView.separated(
                 shrinkWrap: true,
                   itemBuilder: (context,index){
                     return Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: GestureDetector(child: Text(locale[index]['name']),onTap: (){
                         print(locale[index]['name']);
                         updateLanguage(locale[index]['locale']);
                       },),
                     );
                   }, separatorBuilder: (context,index){
                     return Divider(
                       color: Colors.blue,
                     );
               }, itemCount: locale.length
               ),
             ),
           );
        }
    );
  }




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
