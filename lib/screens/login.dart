import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:proyecto_flutter/api/services/auth_service.dart';
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

  final List locale = [
    {'name': 'Español', 'locale': Locale('es')},
    {'name': 'English', 'locale': Locale('en')},
  ];

  void updateLanguage(Locale locale) {
    Get.back();
    Get.updateLocale(locale);
  }

  void buildLanguageDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
            title: Text('Choose Your Language'),
            content: Container(
              width: double.maxFinite,
              child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Text(locale[index]['name']),
                        onTap: () {
                          print(locale[index]['name']);
                          updateLanguage(locale[index]['locale']);
                        },
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(color: Colors.blue);
                  },
                  itemCount: locale.length),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Use proportions of screen width/height for margins and spacings
    double verticalSpacing = screenHeight * 0.02; // 2% of screen height for vertical spacing
    EdgeInsets screenMargin = EdgeInsets.all(screenWidth * 0.04); // 4% of screen width for margin

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Container(
          margin: screenMargin,
          width: screenWidth,
          height: screenHeight,
          child: SingleChildScrollView( // Added to make the screen scrollable
            child: Column(
              children: [
                TopImage(),
                //LoginText(),
                SizedBox(height: verticalSpacing),
                EmailTextFiled(loginController: loginController),
                SizedBox(height: verticalSpacing * 2),
                PasswordTextFiled(loginController: loginController),
                ForgotText(),
                SizedBox(height: verticalSpacing),
                LoginButton(loginController: loginController),
                SizedBox(height: verticalSpacing * 2),
                OrText(),
                GoogleLoginButton(),
                RegisterText(),
                //SizedBox(height: verticalSpacing * 2),
                IconButton(
                  icon: Icon(Icons.language), // Use any icon you wish
                  onPressed: () => buildLanguageDialog(context),
                ),
                SizedBox(height: verticalSpacing),
                const AppVersionText(),
              ],
            ),
          ),
        ),
      ),
    );
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
        print('token'.tr);
      }
    } else {
      Get.snackbar('Error', 'incorrecto'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}

class RegisterText extends StatelessWidget {
  const RegisterText({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Adjusted scale for text sizes
    double primaryTextSize = screenWidth / 480 * 18; // Smaller scale for primary text
    double linkTextSize = screenWidth / 480 * 20; // Slightly larger scale for link text

    return FadeInDown(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8), // Add some vertical padding
        child: Center(
          child: RichText(
            text: TextSpan(
              text: 'sin_cuenta'.tr,
              style: TextStyle(
                color: Theme.of(context).canvasColor,
                fontSize: primaryTextSize, // Adjusted text size
              ),
              children: [
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {
                      Get.off(() => SignUpScreen());
                    },
                    child: Text(
                      'register'.tr,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: linkTextSize, // Adjusted text size for link
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
  const GoogleLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Adjusted size for the button
    double buttonHeight = screenHeight * 0.16; // 16% of screen height
    double buttonIconSize = screenHeight * 0.1; // 10% of screen height

    return FadeInDown(
      delay: Duration(milliseconds: 100),
      child: Container(
        height: buttonHeight,
        child: IconButton(
          icon: Image.asset('assets/images/google3.png'),
          iconSize: buttonIconSize,
          onPressed: () async {
            try {
              final user = await AuthService.signInWithGoogle();
              if (user != null) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomePage()));
              }
            } on FirebaseAuthException catch (error) {
              print(error.message);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                error.message ?? "Something went wrong",
              )));
            } catch (error) {
              print(error);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                error.toString(),
              )));
            }
          },
        ),
      ),
    );
  }
}


class OrText extends StatelessWidget {
  const OrText({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double textSize = screenWidth / 480 * 20; // Adjusted scale for text size
    double lineLength = screenWidth * 0.15; // Line length as a percentage of screen width

    return FadeInDown(
      delay: Duration(milliseconds: 125),
      child: Container(
        width: screenWidth, // Use the full width of the screen
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: lineLength, height: 0.5, color: Theme.of(context).canvasColor),
              Text(
                'authMethods'.tr,
                style: TextStyle(
                  color: Theme.of(context).canvasColor,
                  fontSize: textSize, // Adjusted text size
                  fontWeight: FontWeight.bold),
              ),
              Container(width: lineLength, height: 0.5, color: Theme.of(context).canvasColor),
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
    // Calculate the width and height of the screen
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Scale down the button width and text size
    double buttonWidthScale = screenWidth * 0.6; // 60% of screen width
    double buttonTextScale = screenWidth / 480; // Smaller base for text size scaling

    // Adjust the button height if necessary
    double buttonHeight = screenHeight / 20; // Smaller height proportion

    return FadeInDown(
      delay: Duration(milliseconds: 150),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1), // 10% of screen width for margin
        width: buttonWidthScale,
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: () {
            loginController.login(context);
          },
          child: Text(
            'login'.tr,
            style: TextStyle(
              fontSize: 20 * buttonTextScale, // Adjusted text size
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

class ForgotText extends StatelessWidget {
  const ForgotText({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double textSize = screenWidth / 480 * 15; // Adjusted scale for text size

    // Adjust margins to be proportional to screen width
    double horizontalMargin = screenWidth * 0.2; // 20% of screen width for margin

    return FadeInDown(
      delay: Duration(milliseconds: 175),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: horizontalMargin), // Adjusted margin
          width: screenWidth, // Use the full width of the screen
          height: screenWidth / 20, // Height proportional to screen width
          child: Center(
            child: Text(
              'forgetPassword'.tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: textSize, // Adjusted text size
              ),
            ),
          ),
        ),
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
        text: 'contraseña'.tr,
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
            text: 'correo'.tr,
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