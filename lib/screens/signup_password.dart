import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/Resource/Strings.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/login.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:proyecto_flutter/widget/rep_textfiled.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:lottie/lottie.dart';

// Color(0xFFFFFCEA)
class SignUpPasswordScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  SignUpPasswordScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<SignUpPasswordScreen> createState() =>
      _SignUpScreenState(userData: userData);
}

class _SignUpScreenState extends State<SignUpPasswordScreen> {
  final TextEditingController controller = TextEditingController();
  bool success = false;
  final SignUpPasswordController signUpController;

  Map<String, dynamic> userData;

  _SignUpScreenState({required this.userData})
      : signUpController = SignUpPasswordController(userData: userData);

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
              Animation(success: success),
              SizedBox(height: 50),
              PasswordText(),
              PasswordTextFiled(
                  controller: controller,
                  success: success,
                  signUpController: signUpController),
              SizedBox(height: 10),
              ConfirmPasswordTextFiled(signUpController: signUpController),
              SizedBox(height: 10),
              FlutterPwValidator(
                defaultColor: Colors.grey.shade300,
                controller: controller,
                successColor: Colors.green.shade700,
                minLength: 8,
                uppercaseCharCount: 1,
                numericCharCount: 3,
                specialCharCount: 1,
                lowercaseCharCount: 3,
                strings: SpanishStrings(),
                width: 400,
                height: 150,
                onSuccess: () {
                  setState(() {
                    success = true;
                  });
                },
                onFail: () {
                  setState(() {
                    success = false;
                  });
                },
              ),
              SizedBox(height: 40),
              SubmitButton(
                signUpController: signUpController,
                success: success,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpPasswordController extends GetxController {
  final Map<String, dynamic> userData;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController password1Controller = TextEditingController();
  final String defaultRole = 'cliente';
  final int defaultRating = 0;

  SignUpPasswordController({required this.userData});

  void signUp(BuildContext context) async {
    String? username = userData['username'];
    String? fullname = userData['fullname'];
    String? email = userData['email'];
    String? password = passwordController.text;
    String? password1 = password1Controller.text;

    Map<String, dynamic> registrationData = {
      'username': username,
      'fullname': fullname,
      'email': email,
      'password': password,
      'rol': defaultRole,
      'rating': defaultRating,
    };
    print(password);
    print(password1);

    if (password != password1) {
      Get.snackbar('Error', 'Las contraseñas no coinciden',
          snackPosition: SnackPosition.BOTTOM);
      return;
    } else {
      try {
        ApiResponse response = await UserService.registerUser(registrationData);
        print(registrationData);

        Get.defaultDialog(
          title: "Cuenta creada",
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
                      Text("¡Bienvenido a Km0Market!"),
                    ],
                  ),
                ),
              ),
            ),
          ),
          radius: 10.0,
          confirm: ElevatedButton(
            onPressed: () {
              Get.offAll(LoginScreen());
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
      } catch (error) {
        Get.snackbar('Error', 'Ocurrió un error al registrar el usuario',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }
}

class SpanishStrings implements FlutterPwValidatorStrings {
  @override
  final String atLeast = 'Al menos - caracteres';
  @override
  final String uppercaseLetters = '- Letras mayúsculas';
  @override
  final String numericCharacters = '- Números';
  @override
  final String specialCharacters = '- Caracteres especiales';
  @override
  final String lowercaseLetters = '- Letras minúsculas';
  @override
  final String normalLetters = '- Letras normales';
}

class SubmitButton extends StatelessWidget {
  final SignUpPasswordController signUpController;
  final bool success;

  SubmitButton({required this.signUpController, required this.success});

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 100),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 100),
        width: gWidth,
        height: gHeight / 15,
        child: ElevatedButton(
          onPressed: () {
            if (success == false) {
              Get.snackbar('Error', 'No cumples con los requisitos',
                  snackPosition: SnackPosition.BOTTOM);
            } else {
              signUpController.signUp(context);
            }
          },
          child: Text(
            "Regístrate",
            style: TextStyle(fontSize: 25),
          ),
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            backgroundColor: MaterialStateProperty.all(buttonColor),
          ),
        ),
      ),
    );
  }
}

class ConfirmPasswordTextFiled extends StatefulWidget {
  final SignUpPasswordController signUpController;

  ConfirmPasswordTextFiled({
    required this.signUpController,
  });

  @override
  _ConfirmPasswordTextFiledState createState() =>
      _ConfirmPasswordTextFiledState(signUpController: signUpController);
}

class _ConfirmPasswordTextFiledState extends State<ConfirmPasswordTextFiled> {
  bool obscureText = true;

  final SignUpPasswordController signUpController;

  _ConfirmPasswordTextFiledState({
    required this.signUpController,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 200),
      child: RepTextFiled(
        controller: signUpController.passwordController,
        icon: LineIcons.alternateUnlock,
        text: "Confirma tu contraseña",
        suficon: Icon(obscureText ? LineIcons.eyeSlash : LineIcons.eye),
        obscureText: obscureText,
        onToggleVisibility: () {
          setState(() {
            obscureText = !obscureText;
          });
        },
      ),
    );
  }
}

class PasswordTextFiled extends StatefulWidget {
  const PasswordTextFiled({
    Key? key,
    required this.controller,
    required this.success,
    required this.signUpController,
  }) : super(key: key);

  final TextEditingController controller;
  final bool success;
  final SignUpPasswordController signUpController;

  @override
  _PasswordTextFiledState createState() =>
      _PasswordTextFiledState(signUpController: signUpController);
}

class _PasswordTextFiledState extends State<PasswordTextFiled> {
  bool obscureText = true;
  final SignUpPasswordController signUpController;

  _PasswordTextFiledState({required this.signUpController});

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 150),
      child: Container(
        child: RepTextFiled(
          controller2: signUpController.password1Controller,
          controller: widget.controller,
          icon: LineIcons.alternateUnlock,
          text: "Contraseña",
          suficon: Icon(obscureText ? LineIcons.eyeSlash : LineIcons.eye),
          obscureText: obscureText,
          onToggleVisibility: () {
            setState(() {
              obscureText = !obscureText;
            });
          },
        ),
      ),
    );
  }
}

class PasswordText extends StatelessWidget {
  const PasswordText({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 125),
      child: Container(
          margin: EdgeInsets.only(top: 10, right: 270),
          width: gWidth / 4,
          height: gHeight / 18,
          child: FittedBox(
            child: Text("Regístrate",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                )),
          )),
    );
  }
}

class Animation extends StatelessWidget {
  const Animation({
    Key? key,
    required this.success,
  }) : super(key: key);

  final bool success;

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 200),
      child: Container(
        child: SizedBox(
          width: double.infinity,
          height: 200,
          child: success
              ? Lottie.asset(
                  "assets/json/animation.json",
                )
              : Lottie.asset("assets/json/animation_lnt9yuim.json"),
        ),
      ),
    );
  }
}
