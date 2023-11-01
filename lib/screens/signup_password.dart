import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:proyecto_flutter/widget/rep_textfiled.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SignUpPasswordScreen extends StatefulWidget {
  const SignUpPasswordScreen({Key? key}) : super(key: key);

  @override
  State<SignUpPasswordScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpPasswordScreen> {
  final TextEditingController controller = TextEditingController();
  bool success = false;

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
              Success(controller: controller, success: success),
              SizedBox(height: 10),
              Success2(),
              SizedBox(height: 10),
              FlutterPwValidator(
                defaultColor: Colors.grey.shade300,
                controller: controller,
                successColor: Colors.green.shade700,
                minLength: 8,
                uppercaseCharCount: 2,
                numericCharCount: 3,
                specialCharCount: 1,
                normalCharCount: 3,
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
              SubmitButton()
            ],
          ),
        ),
      ),
    );
  }
}

class Success extends StatelessWidget {
  const Success({
    Key? key,
    required this.controller,
    required this.success,
  }) : super(key: key);

  final TextEditingController controller;
  final bool success;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RepTextFiled(controller: controller,
        icon: LineIcons.alternateUnlock, suficon: Icon(LineIcons.eyeSlash), text: "Contraseña",
      ),
    );
  }
}

class Success2 extends StatelessWidget {
  const Success2({
    Key? key,
  }) : super(key: key);

   @override
  Widget build(BuildContext context) {
    return FadeIn(
      delay: Duration(milliseconds: 1500),
      child: RepTextFiled(icon: LineIcons.alternateUnlock, suficon: Icon(LineIcons.eyeSlash), text: "Confirma tu contraseña"));
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
    return Container(
      child: SizedBox(
        width: double.infinity,
        height: 200,
        child: success
            ? Lottie.asset(
                "assets/json/animation.json",
              )
            : Lottie.asset("assets/json/animation_lnt9yuim.json"),
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 600),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 100),
        width: gWidth,
        height: gHeight / 15,
        child: ElevatedButton(
          onPressed: () {
            Get.offAll(SubmitButton());
          },
          child: Text("Regístrate", style: TextStyle(fontSize: 25),
          ),
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            backgroundColor: MaterialStateProperty.all(buttonColor),
          ),
        ),
      ),
    );
  }
}

/* class ConfirmPasswordTextFiled extends StatelessWidget {
  const ConfirmPasswordTextFiled({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 2300),
      child: RepTextFiled(
        icon: LineIcons.alternateUnlock,
        text: "Confirma la contraseña",
        suficon: Icon(LineIcons.eyeSlash),
      ),
    );
  }
}

class PasswordTextFiled extends StatelessWidget {
  const PasswordTextFiled({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 2300),
      child: RepTextFiled(
        icon: LineIcons.alternateUnlock,
        text: "Contraseña",
        suficon: Icon(LineIcons.eyeSlash),
      ),
    );
  }
}
 */
class PasswordText extends StatelessWidget {
  const PasswordText({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInLeft(
      delay: Duration(milliseconds: 1800),
      child: Container(
        margin: EdgeInsets.only(top: 5, right: 260),
        width: gWidth,
        height: gHeight / 18,
          child: Text(
            "Crea tu contraseña",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20
            ),
          ),
        
      ),
    );
  }
}

