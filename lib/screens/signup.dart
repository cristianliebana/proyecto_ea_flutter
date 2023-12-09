import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/login.dart';
import 'package:proyecto_flutter/screens/signup_password.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:proyecto_flutter/utils/theme_provider.dart';
import 'package:proyecto_flutter/widget/rep_textfiled.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({Key? key}) : super(key: key);
  final SignUpController signUpController = SignUpController();

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      leading: _buildAppBarBackButton(context),
    );
  }

  Widget _buildAppBarBackButton(BuildContext context) {
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
          Get.to(LoginScreen());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: Container(
            margin: EdgeInsets.only(left: 15, right: 15, top: 0),
            child: Column(
              children: [
                TopImage(),
                SignUpText(),
                EmailTextFiled(signUpController: signUpController),
                SizedBox(height: 10),
                NameTextFiled(signUpController: signUpController),
                SizedBox(height: 10),
                UsernameTextFiled(signUpController: signUpController),
                SizedBox(height: 25),
                BottomText(),
                SizedBox(height: 25),
                ContinueButton(signUpController: signUpController)
              ],
            ),
          ),
        ));
  }
}

class SignUpController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  void signup(BuildContext context) async {
    String? username = usernameController.text;
    String? fullname = fullnameController.text;
    String? email = emailController.text;

    Map<String, dynamic> userData = {
      'username': username,
      'fullname': fullname,
      'email': email,
    };

    if (username == "" || fullname == "" || email == "") {
      Get.snackbar('Error', 'Tienes que rellenar todos los campos',
          snackPosition: SnackPosition.BOTTOM);
    } else {
      ApiResponse response = await UserService.usernameExists(username);
      bool usernameExists = response.data['usernameExists'];

      ApiResponse response2 = await UserService.emailExists(email);
      bool emailExists = response2.data['emailExists'];

      if (usernameExists && emailExists) {
        Get.snackbar('Error', 'El nombre de usuario y el email no existen',
            snackPosition: SnackPosition.BOTTOM);
      } else if (usernameExists) {
        Get.snackbar('Error', 'El nombre de usuario ya existe',
            snackPosition: SnackPosition.BOTTOM);
      } else if (emailExists) {
        Get.snackbar('Error', 'El email ya existe',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.to(SignUpPasswordScreen(userData: userData));
        print(userData);
      }
    }
  }
}

class ContinueButton extends StatelessWidget {
  final SignUpController signUpController;

  ContinueButton({
    required this.signUpController,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 25),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 100),
        width: gWidth,
        height: gHeight / 15,
        child: ElevatedButton(
          onPressed: () {
            signUpController.signup(context);
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
                  Theme.of(context).colorScheme.onPrimary)),
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
      delay: Duration(milliseconds: 50),
      child: Container(
          width: gWidth,
          height: gHeight / 21,
          child: Center(
            child: RichText(
              text: TextSpan(
                  text: "Al registrarte, estas aceptando los",
                  style: TextStyle(
                    color: Theme.of(context).canvasColor,
                  ),
                  children: [
                    TextSpan(
                      text: " Terminos y condiciones",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  ]),
            ),
          )),
    );
  }
}

class UsernameTextFiled extends StatelessWidget {
  final SignUpController signUpController;

  UsernameTextFiled({
    required this.signUpController,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
        delay: Duration(milliseconds: 75),
        child: RepTextFiled(
            icon: LineIcons.userTag,
            text: "Nombre de usuario",
            controller: signUpController.usernameController));
  }
}

class NameTextFiled extends StatelessWidget {
  final SignUpController signUpController;

  NameTextFiled({
    required this.signUpController,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
        delay: Duration(milliseconds: 75),
        child: RepTextFiled(
          icon: LineIcons.user,
          text: "Nombre completo",
          controller: signUpController.fullnameController,
        ));
  }
}

class EmailTextFiled extends StatelessWidget {
  final SignUpController signUpController;

  EmailTextFiled({
    required this.signUpController,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
        delay: Duration(milliseconds: 100),
        child: RepTextFiled(
          icon: LineIcons.at,
          text: "Correo electrónico",
          controller: signUpController.emailController,
        ));
  }
}

class SignUpText extends StatelessWidget {
  const SignUpText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 125),
      child: Container(
          margin: EdgeInsets.only(right: 270),
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
      delay: Duration(milliseconds: 150),
      child: Container(
        width: gWidth,
        height: gHeight / 2.85,
        child: Image.asset(topImage),
      ),
    );
  }
}
