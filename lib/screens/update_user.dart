import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/profile.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:proyecto_flutter/widget/rep_textfiled.dart';

class UpdateScreen extends StatefulWidget {
  UpdateScreen({Key? key}) : super(key: key);
  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  Map<String, dynamic> userData = {};
  final UpdateController updateController = UpdateController();
  @override
  void initState() {
    super.initState();
    obtenerDatosUsuario();
  }

  Future<void> obtenerDatosUsuario() async {
    ApiResponse response = await UserService.getUserById();
    setState(() {
      userData = response.data;
      print(userData);
      updateController.usernameController.text = userData['username'];
      updateController.fullnameController.text = userData['fullname'];
      updateController.emailController.text = userData['email'];
      updateController.passwordController.text = userData['password'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: Container(
            margin: EdgeInsets.all(15),
            width: gWidth,
            height: gHeight,
            child: Column(
              children: [
                SizedBox(height: 50),
                ProfileImage(),
                SizedBox(height: 20),
                UpdateText(),
                FullnameTextFiled(updateController: updateController),
                SizedBox(height: 10),
                UsernameTextFiled(updateController: updateController),
                SizedBox(height: 20),
                UpdateButton(updateController: updateController)
              ],
            ),
          ),
        ));
  }
}

class UpdateController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void updateUser(BuildContext context) async {
    String? username = usernameController.text;
    String? fullname = fullnameController.text;
    String? email = emailController.text;
    String? password = passwordController.text;

    Map<String, dynamic> userData = {
      'username': username,
      'fullname': fullname,
      'email': email,
      'password': password,
    };
    ApiResponse response = await UserService.updateUser(userData);
    //print(userData);
    Get.defaultDialog(
      title: "¡Felicidades!",
      backgroundColor: Color(0xFFFFFCEA),
      content: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Color(0xFFFFFCEA),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFCEA),
              ),
              child: Column(
                children: [
                  Lottie.asset(
                    "assets/json/check3.json",
                    width: 100,
                    height: 100,
                    repeat: false,
                  ),
                  SizedBox(height: 20),
                  Text("¡Has actualizado tu perfil!"),
                ],
              ),
            ),
          ),
        ),
      ),
      radius: 10.0,
      confirm: ElevatedButton(
        onPressed: () {
          Get.offAll(ProfilePage());
        },
        child: Text("Aceptar"),
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          backgroundColor: MaterialStateProperty.all(buttonColor),
        ),
      ),
    );
  }
}

class UpdateButton extends StatelessWidget {
  final UpdateController updateController;

  UpdateButton({
    required this.updateController,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 150),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 100),
        width: gWidth,
        height: gHeight / 15,
        child: ElevatedButton(
          onPressed: () {
            updateController.updateUser(context);
          },
          child: Text(
            "Guardar cambios",
            style: TextStyle(fontSize: 25),
          ),
          style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              backgroundColor: MaterialStateProperty.all(buttonColor)),
        ),
      ),
    );
  }
}

class UsernameTextFiled extends StatelessWidget {
  final UpdateController updateController;

  UsernameTextFiled({
    required this.updateController,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
        delay: Duration(milliseconds: 225),
        child: RepTextFiled(
            icon: LineIcons.userTag,
            text: "Nombre de usuario",
            controller: updateController.usernameController));
  }
}

class FullnameTextFiled extends StatelessWidget {
  final UpdateController updateController;

  FullnameTextFiled({
    required this.updateController,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
        delay: Duration(milliseconds: 225),
        child: RepTextFiled(
            icon: LineIcons.user,
            text: "Nombre completo",
            controller: updateController.fullnameController));
  }
}

class UpdateText extends StatelessWidget {
  const UpdateText({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 125),
      child: Container(
          margin: EdgeInsets.only(top: 10, left: 40),
          width: gWidth,
          height: gHeight / 25,
          child: SizedBox(
            child: Text("Actualizar perfil",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                )),
          )),
    );
  }
}

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 175,
      height: 175,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: const Image(image: AssetImage('assets/images/profile.png')),
      ),
    );
  }
}
