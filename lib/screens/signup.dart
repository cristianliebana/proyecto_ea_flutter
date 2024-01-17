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
      Get.snackbar('Error', 'rellenar'.tr, snackPosition: SnackPosition.BOTTOM);
    } else {
      ApiResponse response = await UserService.usernameExists(username);
      bool usernameExists = response.data['usernameExists'];

      ApiResponse response2 = await UserService.emailExists(email);
      bool emailExists = response2.data['emailExists'];

      if (usernameExists && emailExists) {
        Get.snackbar('Error', 'noExisten'.tr,
            snackPosition: SnackPosition.BOTTOM);
      } else if (usernameExists) {
        Get.snackbar('Error', 'yaExiste1'.tr,
            snackPosition: SnackPosition.BOTTOM);
      } else if (emailExists) {
        Get.snackbar('Error', 'yaExiste2'.tr,
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
            'continuar'.tr,
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
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showTermsDialog(context);
      },
      child: FadeInDown(
        delay: Duration(milliseconds: 50),
        child: Container(
          width: gWidth,
          height: gHeight / 21,
          child: Center(
            child: RichText(
              text: TextSpan(
                text: 'aceptarTerms'.tr,
                style: TextStyle(
                  color: Theme.of(context).canvasColor,
                ),
                children: [
                  TextSpan(
                    text: 'terms'.tr,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('Términos y Condiciones'.tr),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido a la aplicación KM-0 MARKET. Antes de comenzar a utilizar nuestros servicios, te solicitamos que leas detenidamente estos Términos y Condiciones. Al registrarte y utilizar nuestra aplicación, aceptas cumplir con estos términos y todas las leyes y regulaciones aplicables. Si no estás de acuerdo con alguna parte de estos términos, te rogamos que no utilices nuestra aplicación.',
            ),
            SizedBox(height: 10),
            Text(
              '1. Registro de la Cuenta:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              '1.1 Para utilizar nuestra aplicación, debes registrarte proporcionando información precisa y actualizada.',
            ),
            Text(
              '1.2 Eres responsable de mantener la confidencialidad de tu información de inicio de sesión y de todas las actividades que ocurran bajo tu cuenta.',
            ),
            SizedBox(height: 10),
            Text(
              '2. Uso del Servicio:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              '2.1 Otorgamos a los usuarios el derecho no exclusivo, no transferible y limitado para utilizar la aplicación de acuerdo con estos términos.',
            ),
            Text(
              '2.2 No se permite realizar actividades ilegales, difamatorias, acosadoras o que violen los derechos de propiedad intelectual de terceros.',
            ),
            SizedBox(height: 10),
            Text(
              '3. Privacidad:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              '3.1 La información recopilada por nuestra aplicación se rige por nuestra Política de Privacidad, que puedes revisar en [enlace a la política de privacidad].',
            ),
            Text(
              '3.2 Utilizamos cookies y tecnologías similares para mejorar la experiencia del usuario. Consulta nuestra Política de Cookies para obtener más información.',
            ),
            SizedBox(height: 10),
            Text(
              '4. Propiedad Intelectual:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              '4.1 Todos los derechos de propiedad intelectual sobre la aplicación y su contenido pertenecen a KM-0 MARKET.',
            ),
            Text(
              '4.2 No tienes permiso para reproducir, distribuir o modificar el contenido de la aplicación sin nuestro consentimiento expreso.',
            ),
            SizedBox(height: 10),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Cerrar el diálogo
            },
            child: Text('Aceptar'),
          ),
        ],
      ),
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
            text: 'nombreUsuario'.tr,
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
          text: 'nombreCompleto'.tr,
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
          text: 'correo'.tr,
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
            child: Text('register'.tr,
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
