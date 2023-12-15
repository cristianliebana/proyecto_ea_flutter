import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:proyecto_flutter/api/services/token_service.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/home.dart';
import 'package:proyecto_flutter/screens/signup.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:proyecto_flutter/utils/theme_provider.dart';
import 'package:proyecto_flutter/widget/rep_textfiled.dart';
import 'package:proyecto_flutter/widget/socket_manager.dart';
import 'package:proyecto_flutter/widget/version.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);
  final LoginController loginController = LoginController();

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
                EmailTextFiled(loginController: loginController),
                SizedBox(height: 20),
                PasswordTextFiled(loginController: loginController),
                ForgotText(),
                SizedBox(height: 15),
                LoginButton(loginController: loginController),
                SizedBox(height: 20),
                OrText(),
                GoogleLoginButton(),
                RegisterText(),
                SizedBox(height: 5),
                const AppVersionText(),
              ],
            ),
          ),
        ));
  }
}

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login(BuildContext context) async {
    String? email = emailController.text;
    String? password = passwordController.text;

    Map<String, dynamic> userData = {
      'email': email,
      'password': password,
    };

    ApiResponse response = await UserService.loginUser(userData);
    print(userData);
    if (response.statusCode == 200) {
      String? token = response.data['token'];
      print(token);
      if (token != null) {
        await TokenService.saveToken(token);
        SocketManager();
        Get.offAll(() => HomePage());
      } else {
        print('No se recibió un token en la respuesta');
      }
    } else {
      Get.snackbar('Error', 'Correo o contraseña incorrectos',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}

class RegisterText extends StatelessWidget {
  const RegisterText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      child: Container(
        width: gWidth,
        height: gHeight / 32,
        child: Center(
          child: RichText(
            text: TextSpan(
              text: "¿No tienes una cuenta? ",
              style:
                  TextStyle(color: Theme.of(context).canvasColor, fontSize: 18),
              children: [
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {
                      Get.off(() => SignUpScreen());
                    },
                    child: Text(
                      "Regístrate",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
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
      delay: Duration(milliseconds: 100),
      child: Container(
        height: gHeight / 6,
        child: IconButton(
          icon: Image.asset('assets/images/google3.png'),
          iconSize: gHeight / 10,
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
      delay: Duration(milliseconds: 125),
      child: Container(
        width: gWidth,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  width: 75, height: 0.5, color: Theme.of(context).canvasColor),
              Text(
                " Otros métodos de autenticación ",
                style: TextStyle(
                    color: Theme.of(context).canvasColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                  width: 75, height: 0.5, color: Theme.of(context).canvasColor),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final LoginController loginController;

  LoginButton({
    required this.loginController,
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
            loginController.login(context);
          },
          child: Text(
            "Iniciar Sesión",
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
                  Theme.of(context).colorScheme.onPrimary)),
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
      delay: Duration(milliseconds: 175),
      child: GestureDetector(
        onTap: () {},
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 100),
            width: gWidth,
            height: gHeight / 20,
            child: Center(
                child: Text("¿Has olvidado tu contraseña?",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 15)))),
      ),
    );
  }
}

class PasswordTextFiled extends StatefulWidget {
  final LoginController loginController;

  PasswordTextFiled({
    required this.loginController,
  });

  @override
  _PasswordTextFiledState createState() =>
      _PasswordTextFiledState(loginController: loginController);
}

class _PasswordTextFiledState extends State<PasswordTextFiled> {
  bool obscureText = true;

  final LoginController loginController;

  _PasswordTextFiledState({
    required this.loginController,
  });
  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 200),
      child: RepTextFiled(
        controller: loginController.passwordController,
        icon: LineIcons.alternateUnlock,
        text: "Contraseña",
        suficon: Icon(obscureText
            ? LineIcons.eyeSlash
            : LineIcons.eye), // Cambia el icono según la visibilidad
        obscureText: obscureText,
        onToggleVisibility: () {
          // Cambia la visibilidad de la contraseña cuando se hace clic en el icono
          setState(() {
            obscureText = !obscureText;
          });
        },
      ),
    );
  }
}

class EmailTextFiled extends StatelessWidget {
  final LoginController loginController;

  EmailTextFiled({
    required this.loginController,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
        delay: Duration(milliseconds: 225),
        child: RepTextFiled(
            icon: LineIcons.at,
            text: "Correo electrónico",
            controller: loginController.emailController));
  }
}

class TopImage extends StatelessWidget {
  const TopImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = Get.find<ThemeProvider>();

    // Elegir la imagen según el tema actual
    String topImage = themeProvider.isDarkMode
        ? 'assets/images/logo2.png'
        : 'assets/images/logo.jpeg';

    return FadeInDown(
      delay: Duration(milliseconds: 275),
      child: Container(
        width: gWidth,
        height: gHeight / 2.85,
        child: Image.asset(topImage),
      ),
    );
  }
}