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
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  return GestureDetector(
    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
    child: Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(screenWidth * 0.03), // Responsive margin
          child: Column(
            children: [
              Animation(success: success),
              SizedBox(height: screenHeight * 0.02), // Adjusted spacing
              PasswordText(),
              PasswordTextFiled(
                controller: controller,
                success: success,
                signUpController: signUpController,
              ),
              SizedBox(height: screenHeight * 0.015), // Adjusted spacing
              ConfirmPasswordTextFiled(signUpController: signUpController),
              SizedBox(height: screenHeight * 0.015), // Adjusted spacing
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
                width: screenWidth * 0.8, // Adjusted width
                height: screenHeight * 0.15, // Adjusted height
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
              SizedBox(height: screenHeight * 0.1), // Adjusted spacing
              ContinueButton(
              signUpController: signUpController,
              success: success,
              ),
            ],
          ),
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
  final double defaultRating = 3.5;

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
      Get.snackbar('Error', 'noCoinciden'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    } else {
      try {
        Get.to(SignUpImageScreen(registrationData: registrationData));
      } catch (error) {
        Get.snackbar('Error', 'registroFallido'.tr,
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }
}

class SpanishStrings implements FlutterPwValidatorStrings {
  @override
  final String atLeast = 'atLeast'.tr;
  @override
  final String uppercaseLetters = 'uppercaseLetters'.tr;
  @override
  final String numericCharacters = 'numericCharacters'.tr;
  @override
  final String specialCharacters = 'specialCharacters'.tr;
  @override
  final String lowercaseLetters = 'lowercaseLetters'.tr;
  @override
  final String normalLetters = 'normalLetters'.tr;
}

class ContinueButton extends StatelessWidget {
  final SignUpPasswordController signUpController;
  final bool success;

  ContinueButton({required this.signUpController, required this.success});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return FadeInDown(
      delay: Duration(milliseconds: 100),
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.2), // Responsive horizontal margin
        width: screenWidth * 0.6, // Responsive width, 60% of the screen width
        height:
            screenHeight * 0.06, // Responsive height, 6% of the screen height
        child: ElevatedButton(
          onPressed: () {
            if (!success) {
              Get.snackbar('Error', 'requisitos'.tr,
                  snackPosition: SnackPosition.BOTTOM);
            } else {
              signUpController.signUp(context);
            }
          },
          child: Text(
            'continuar'.tr,
            style: TextStyle(
              fontSize: screenHeight * 0.03, // Responsive font size
              color: Theme.of(context).colorScheme.primary,
            ),
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
        controller: signUpController
            .passwordController, // Controller for password confirmation
        icon: LineIcons.alternateUnlock, // Icon for the password field
        text: 'confirmaContraseña'.tr, // Localized text for 'Confirm Password'
        suficon: IconButton(
          icon: Icon(obscureText ? LineIcons.eyeSlash : LineIcons.eye),
          onPressed: () {
            setState(() {
              obscureText = !obscureText; // Toggle password visibility
            });
          },
        ),
        obscureText: obscureText, // Controls visibility of the password
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
      child: RepTextFiled(
        controller2: signUpController.password1Controller,
        controller: widget.controller,
        icon: LineIcons.alternateUnlock,
        text: 'contraseña'.tr,
        suficon: IconButton(
          icon: Icon(obscureText ? LineIcons.eyeSlash : LineIcons.eye),
          onPressed: () {
            setState(() {
              obscureText = !obscureText;
            });
          },
        ),
        obscureText: obscureText,
      ),
    );
  }
}

class PasswordText extends StatelessWidget {
  const PasswordText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return FadeInDown(
      delay: Duration(milliseconds: 125),
      child: Container(
        margin: EdgeInsets.only(
            top: 10, right: screenWidth * 0.7), // Responsive margin
        width: screenWidth / 4, // Responsive width
        height: screenHeight / 18, // Responsive height
        child: FittedBox(
          fit:
              BoxFit.scaleDown, // Ensures text scales down to fit the container
          child: Text(
            'register'.tr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
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
    double screenHeight = MediaQuery.of(context).size.height;

    return FadeInDown(
      delay: Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        height: screenHeight *
            0.25, // 25% of screen height, adjust this value as needed
        child: success
            ? Lottie.asset("assets/json/animation.json")
            : Lottie.asset("assets/json/animation_lnt9yuim.json"),
      ),
    );
  }
}
