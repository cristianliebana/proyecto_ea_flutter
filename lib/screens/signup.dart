import 'dart:convert';
import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/signup_password.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:proyecto_flutter/widget/rep_textfiled.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SignUpController signUpController = SignUpController();
  File? _imageFile;
  String? _imageUrl;

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) _imageFile = File(pickedFile.path);
    });
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      // Manejar el caso cuando _imageFile es nulo
      return;
    }

    final url = Uri.parse('https://api.cloudinary.com/v1_1/dfwsx27vx/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'xcsa2ndz';

    if (kIsWeb) {
      // En Flutter web, manejamos el envío del archivo de una manera diferente
      final bytes = await _imageFile!.readAsBytes();
      request.files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: 'file.jpg'));
    } else {
      // En dispositivos móviles, utilizamos el método fromPath como antes
      request.files
          .add(await http.MultipartFile.fromPath('file', _imageFile!.path));
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        setState(() {
          final url = jsonMap['url'];
          _imageUrl = url;
        });
      } else {
        // Manejar errores de red o de la API
        print('Error en la carga de la imagen: ${response.reasonPhrase}');
      }
    } catch (error) {
      // Manejar errores generales
      print('Error en la carga de la imagen: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(15),
                width: gWidth,
                height: gHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TopImage(),
                    SignUpText(),
                    SizedBox(height: 10),
                    EmailTextFiled(signUpController: signUpController),
                    SizedBox(height: 10),
                    NameTextFiled(signUpController: signUpController),
                    SizedBox(height: 10),
                    UsernameTextFiled(signUpController: signUpController),
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.camera),
                      child: const Text('Abre la cámara'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _uploadImage,
                      child: const Text('Subelo a cloudinary'),
                    ),
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      child: const Text('Selecciona una foto de la galería'),
                    ),
                    if (_imageFile != null) ...[
                      Image.network(_imageFile!.path),
                      ElevatedButton(
                        onPressed: _uploadImage,
                        child: const Text('Subelo a cloudinary'),
                      ),
                    ],
                    if (_imageUrl != null) ...[
                      Image.network(_imageUrl!),
                      Text("Cloudinary URL: $_imageUrl",
                          style: const TextStyle(fontSize: 20)),
                      const Padding(
                          padding:
                              EdgeInsets.only(left: 20, top: 60, bottom: 100)),
                    ],
                    SizedBox(height: 25),
                    BottomText(),
                    SizedBox(height: 25),
                    ContinueButton(signUpController: signUpController)
                  ],
                ),
              ),
            )));
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
        Get.offAll(SignUpPasswordScreen(userData: userData));
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
            style: TextStyle(fontSize: 25),
          ),
          style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              backgroundColor: MaterialStateProperty.all(buttonColor)),
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
                    color: text2Color,
                  ),
                  children: [
                    TextSpan(
                      text: " Terminos y condiciones",
                      style: TextStyle(
                        color: text1Color,
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
          text: "Nombre Completo",
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

class TopImage extends StatelessWidget {
  const TopImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      delay: Duration(milliseconds: 150),
      child: Container(
          width: gWidth,
          height: gHeight / 2.85,
          child: Image.asset('assets/images/logo.jpeg')),
    );
  }
}
