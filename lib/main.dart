import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto_flutter/screens/login.dart';
import 'package:proyecto_flutter/screens/signup.dart';
import 'package:proyecto_flutter/screens/signup_password.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PROYECTO EA',
        theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFFFCEA),
      ),
      home: SignUpPasswordScreen(),
      
    );
  }
}