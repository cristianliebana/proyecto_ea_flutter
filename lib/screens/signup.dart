import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:proyecto_flutter/widget/rep_textfiled.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

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
            TopImage(),
            SignUpText(),
            SizedBox(height: 10),
            EmailTextFiled(),
            SizedBox(height: 10),
            NameTextFiled(),
            SizedBox(height: 25),
            BottomText(),
            SizedBox(height: 25),
            ContinueButton()
          ],
          ),
      ),
    )
    );
  }
}

class ContinueButton extends StatelessWidget {
  const ContinueButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 600),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal:100),
        width: gWidth,
        height: gHeight/15,
        child: ElevatedButton(
          onPressed:(){
            Get.offAll(SignUpScreen());
          },
          child: Text("Continuar", style: TextStyle(fontSize: 25 ),),
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius:BorderRadius.circular(15),
                 ),
                 ),
                 backgroundColor: MaterialStateProperty.all(buttonColor)
          ), 
          ),
      ),
    );
  }
}

class BottomText extends StatelessWidget {
  const BottomText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 900),
      child: Container(
        width: gWidth,
        height: gHeight/21,
        child: Center(
        child: RichText(
          text: TextSpan(
            text: "Al registrarte, estas aceptando los",
            style: TextStyle(
              color: text2Color,
            ),
            children: [
            TextSpan(
            text: " Terminos y condiciones",
            style: TextStyle(
              color: text1Color,
            ),)
            ]
          ),
        ),)
      ),
    );
  }
}

class NameTextFiled extends StatelessWidget {
  const NameTextFiled({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      delay: Duration(milliseconds: 1200),
      child: RepTextFiled(icon: LineIcons.user, suficon: null, text: "Nombre Completo"));
  }
}

class EmailTextFiled extends StatelessWidget {
  const EmailTextFiled({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      delay: Duration(milliseconds: 1500),
      child: RepTextFiled(icon: LineIcons.at, suficon: null, text: "Email"));
  }
}

class SignUpText extends StatelessWidget {
  const SignUpText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInLeft(
      delay: Duration(milliseconds: 1800),
      child: Container(
        margin: EdgeInsets.only(top: 10,right: 270),
        width: gWidth/4,
        height: gHeight/18,
        child : FittedBox(
          child: Text(
            "Regístrate",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )
          ),
        )
      ),
    );
  }
}

class TopImage extends StatelessWidget {
  const TopImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 2100),
      child: Container(width: gWidth,
      height: gHeight/2.85,
      child: Image.asset('assets/images/logo.jpeg')),
    );
  }
}