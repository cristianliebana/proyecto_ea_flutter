import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:proyecto_flutter/api/services/cloudinary_service.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/login.dart';
import 'package:proyecto_flutter/screens/signup.dart';
import 'package:proyecto_flutter/screens/signup_password.dart';
import 'package:proyecto_flutter/utils/constants.dart';

class SignUpImageScreen extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  SignUpImageScreen({Key? key, required this.registrationData})
      : super(key: key);

  @override
  _SignUpImageScreenState createState() => _SignUpImageScreenState();
}

class _SignUpImageScreenState extends State<SignUpImageScreen> {
  late SignUpImageController signUpController;

  @override
  void initState() {
    super.initState();
    signUpController = SignUpImageController(
      registrationData: widget.registrationData,
      state: this,
    );
  }

  XFile? _imageFile;
  String? _imageUrl;
  String? getImageUrl() {
    return _imageUrl;
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _uploadImage() async {
    try {
      if (_imageFile == null) {
        // Manejar el caso cuando _imageFile es nulo
        print('Error: _imageFile es nulo.');
        return;
      }

      // Crear una instancia de CloudinaryServices
      final cloudinaryServices = CloudinaryServices();

      // Subir la imagen a Cloudinary usando CloudinaryServices
      final uploadedUrl =
          await cloudinaryServices.uploadImage(_imageFile!, "registroUsuario");
      print("URL de Cloudinary: $uploadedUrl");

      if (uploadedUrl != null) {
        // Si uploadedUrl no es nulo, actualizar la interfaz de usuario
        setState(() {
          _imageUrl = uploadedUrl;
        });
      } else {
        // Manejar el caso cuando uploadedUrl es nulo
        print('Error: uploadedUrl es nulo.');
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    ImageText(),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _pickImage(ImageSource.camera);
                          },
                          child: const Text('Abre la cámara'),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            backgroundColor:
                                MaterialStateProperty.all(buttonColor),
                            minimumSize: MaterialStateProperty.all(Size(150,
                                50)), // Ajusta el tamaño según sea necesario
                          ),
                        ),
                        SizedBox(width: 10), // Espacio entre los botones
                        ElevatedButton(
                          onPressed: () {
                            _pickImage(ImageSource.gallery);
                          },
                          child: const Text('Abre la galería'),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            backgroundColor:
                                MaterialStateProperty.all(buttonColor),
                            minimumSize: MaterialStateProperty.all(Size(150,
                                50)), // Ajusta el tamaño según sea necesario
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      height:
                          300, // Altura fija para el contenedor que contiene CircleAvatar
                      child: Center(
                        child: _imageFile != null
                            ? CircleAvatar(
                                radius: 150,
                                backgroundImage: NetworkImage(_imageFile!.path),
                              )
                            : SizedBox.shrink(),
                      ),
                    ),
                    // if (_imageFile != null) ...[
                    //   Image.network(_imageFile!.path),
                    // ElevatedButton(
                    //   onPressed: _uploadImage,
                    //   child: const Text('Subelo a cloudinary'),
                    // ),
                    // ],
                    // if (_imageUrl != null) ...[
                    //   // Image.network(_imageUrl!),
                    //   Text("Cloudinary URL: $_imageUrl",
                    //       style: const TextStyle(fontSize: 20)),
                    //   const Padding(
                    //       padding:
                    //           EdgeInsets.only(left: 20, top: 60, bottom: 100)),
                    // ],
                    SizedBox(height: 20),
                    SubmitButton(signUpController: signUpController),
                  ],
                ),
              ),
            )));
  }
}

class SignUpImageController extends GetxController {
  final Map<String, dynamic> registrationData;
  final TextEditingController profileImageController = TextEditingController();
  final _SignUpImageScreenState _state;

  SignUpImageController({
    required this.registrationData,
    required _SignUpImageScreenState state,
  }) : _state = state;

  Future<void> _uploadImageAndSignUp(BuildContext context) async {
    await _state._uploadImage(); // Llama a la función de subir imagen
    signUp(context); // Llama a la función signUp después de subir la imagen
  }

  void signUp(BuildContext context) async {
    String? username = registrationData['username'];
    String? fullname = registrationData['fullname'];
    String? email = registrationData['email'];
    String? password = registrationData['password'];
    String? rol = registrationData['rol'];
    int? rating = registrationData['rating'];
    String? profileImage = _state.getImageUrl();

    Map<String, dynamic> imageData = {
      'username': username,
      'fullname': fullname,
      'email': email,
      'password': password,
      'rol': rol,
      'rating': rating,
      'profileImage': profileImage,
    };
    ApiResponse response = await UserService.registerUser(imageData);
    print(imageData);

    Get.defaultDialog(
      title: "Cuenta creada",
      backgroundColor: Color(0xFFFFFCEA),
      content: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Color(0xFFFFFCEA),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFCEA),
              ),
              child: Column(
                children: [
                  Lottie.asset(
                    "assets/json/check3.json",
                    width: 100,
                    height: 100,
                    repeat: false,
                  ),
                  SizedBox(height: 20),
                  Text("¡Bienvenido a Km0Market!"),
                ],
              ),
            ),
          ),
        ),
      ),
      radius: 10.0,
      confirm: ElevatedButton(
        onPressed: () {
          Get.offAll(LoginScreen());
        },
        child: Text("Aceptar"),
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          backgroundColor: MaterialStateProperty.all(buttonColor),
        ),
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  final SignUpImageController signUpController;

  SubmitButton({
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
          onPressed: () async {
            await signUpController._uploadImageAndSignUp(context);
          },
          // onPressed: () async {
          //   signUpController.signUp(context);
          // },
          child: Text(
            "Regístrate",
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

class ImageText extends StatelessWidget {
  const ImageText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
          margin: EdgeInsets.only(top: 10, left: 10),
          child: Text(
            "Escoge tu foto de perfil",
            style: TextStyle(
                color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          )),
    );
  }
}
