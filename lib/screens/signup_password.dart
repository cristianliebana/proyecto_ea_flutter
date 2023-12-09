import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/Resource/Strings.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:proyecto_flutter/screens/signup_image.dart';
import 'package:proyecto_flutter/screens/signup.dart';
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

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      leading: _buildAppBarBackButton(),
    );
  }

  Widget _buildAppBarBackButton() {
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).colorScheme.primary,
        ),
        onPressed: () {
          Get.to(SignUpScreen());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Container(
          margin: EdgeInsets.all(15),
          width: gWidth,
          height: gHeight,
          child: Column(
            children: [
              Animation(success: success),
              SizedBox(height: 40),
              PasswordText(),
              PasswordTextFiled(
                  controller: controller,
                  success: success,
                  signUpController: signUpController),
              SizedBox(height: 10),
              ConfirmPasswordTextFiled(signUpController: signUpController),
              SizedBox(height: 15),
              FlutterPwValidator(
                defaultColor: Colors.grey.shade300,
                controller: controller,
                successColor: Theme.of(context).focusColor,
                failureColor: Theme.of(context).disabledColor,
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
              ContinueButton(
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
        Get.to(SignUpImageScreen(registrationData: registrationData));
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

class ContinueButton extends StatelessWidget {
  final SignUpPasswordController signUpController;
  final bool success;

  ContinueButton({required this.signUpController, required this.success});

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
            "Continuar",
            style: TextStyle(
                fontSize: 25, color: Theme.of(context).colorScheme.primary),
          ),
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            backgroundColor: MaterialStateProperty.all(
                Theme.of(context).colorScheme.onPrimary),
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
                    color: Theme.of(context).primaryColor)),
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
