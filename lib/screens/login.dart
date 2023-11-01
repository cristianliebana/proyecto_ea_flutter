import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:proyecto_flutter/widget/rep_textfiled.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
            //LoginText(),
            SizedBox(height: 10),
            EmailTextFiled(),
            SizedBox(height: 20),
            PasswordTextFiled(),
            ForgotText(),
            SizedBox(height: 15),
            LoginButton(),
            SizedBox(height: 20),
            OrText(),
            GoogleLoginButton(),
            RegisterText()
          ],
          ),
      ),
    )
    );
  }
}

class RegisterText extends StatelessWidget {
  const RegisterText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: gWidth,
          height: gHeight/32,
          child: Center(
            child: RichText(
              text: TextSpan(
                text: "¿No tienes una cuenta? ",
                style: TextStyle(color: text2Color, fontSize: 18),
                children: [
                  TextSpan(
                    text: "Regístrate",
                    style: TextStyle(decoration: TextDecoration.underline ,color: text1Color,fontWeight: FontWeight.bold, fontSize: 20,),
                    
                  )
                ]
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 600),
      child: Container(
        height: gHeight/6,
        child: IconButton(
          icon: Image.asset('assets/images/google3.png'),
          iconSize: gHeight/10,
          onPressed: () {},
          ),
      ),
    );
  }
}

class OrText extends StatelessWidget {
  const OrText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 1000),
      child: Container(
        width: gWidth,
        child: Center(child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(width: 75, height: 0.5,color: text2Color),
            Text(
              " Otros métodos de autenticación ",           
              style: TextStyle(color: text2Color, fontSize: 20, fontWeight: FontWeight.bold),),
            Container(width: 75,height: 0.5,color: text2Color),
          ],
        ), ) ,
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 1400),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal:100),
        width: gWidth,
        height: gHeight/15,
        child: ElevatedButton(
          onPressed:(){
            Get.offAll(LoginScreen());
          },
          child: Text("Iniciar Sesión", style: TextStyle(fontSize: 25 ),),
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

class ForgotText extends StatelessWidget {
  const ForgotText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 1800),
      child: GestureDetector(
        onTap: (){},
        child: Container(
          margin: EdgeInsets.symmetric(horizontal:100),
          width: gWidth,
          height: gHeight/20,
          child:Center(
          child:Text (
            "¿Has olvidado tu contraseña?",
            style: TextStyle(color: buttonColor, fontSize: 15)))),
      ),
    );
  }
}

class PasswordTextFiled extends StatelessWidget {
  const PasswordTextFiled({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 2300),
      child: RepTextFiled(
        icon: LineIcons.alternateUnlock,
        text: "Password", 
        suficon: Icon(LineIcons.eyeSlash),
        ),
    );
  }
}

class EmailTextFiled extends StatelessWidget {
  const EmailTextFiled({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      delay: Duration(milliseconds: 2900),
      child: RepTextFiled(icon: LineIcons.at, suficon: null, text: "Email"));
  }
}

class LoginText extends StatelessWidget {
  const LoginText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 3200),
      child: Container(
        margin: EdgeInsets.only(top: 10,right: 270),
        width: gWidth/4,
        height: gHeight/18,
        color: Colors.red,
        child : FittedBox(
          child: Text(
            "Login",
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
      delay: Duration(milliseconds: 3400),
      child: Container(width: gWidth,
      height: gHeight/2.85,
      child: Image.asset('assets/images/logo.jpeg')),
    );
  }
}


