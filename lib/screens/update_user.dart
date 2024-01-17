import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:proyecto_flutter/api/services/cloudinary_service.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/profile.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:proyecto_flutter/widget/rep_textfiled.dart';

class UpdateScreen extends StatefulWidget {
  UpdateScreen({Key? key}) : super(key: key);
  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  Map<String, dynamic> userData = {};
  late UpdateController updateController;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    obtenerDatosUsuario();
    updateController = UpdateController(
      state: this,
    );
  }

  XFile? _imageFile;
  String? _imageUrl = '';
  String? getImageUrl() {
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return _imageUrl;
    } else {
      return null; // O cualquier otro valor que desees devolver en este caso
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);
    setState(() {
      _imageFile = pickedFile;
      _selectedImagePath = pickedFile?.path;
    });
  }

  Future<void> _uploadImage() async {
    try {
      if (_imageFile == null && _selectedImagePath == null) {
        print('Error: No se seleccionó ninguna imagen.');
        return;
      }

      final cloudinaryServices = CloudinaryServices();
      final uploadedUrl = await cloudinaryServices.uploadImage(
        _imageFile ?? XFile(_selectedImagePath!),
      );

      print("URL de Cloudinary: $uploadedUrl");

      if (uploadedUrl != null) {
        setState(() {
          _imageUrl = uploadedUrl;
        });
      } else {
        print('Error: La URL de Cloudinary es nula.');
      }
    } catch (error) {
      print('Error en la carga de la imagen: $error');
    }
  }

  Future<void> obtenerDatosUsuario() async {
    ApiResponse response = await UserService.getUserById();
    setState(() {
      userData = response.data;
      print(userData);
      updateController.usernameController.text = userData['username'];
      updateController.fullnameController.text = userData['fullname'];
      updateController.emailController.text = userData['email'];
      updateController.passwordController.text = userData['password'];
      updateController.profileImageController.text = userData['profileImage'];
    });
  }

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
          Get.to(ProfilePage());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic sizing based on screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Container(
          margin: EdgeInsets.all(screenWidth * 0.03), // Responsive margin
          width: screenWidth,
          height: screenHeight,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.06), // Responsive height
                ProfileImage(
                  userData: userData,
                  pickImageFunction: _pickImage,
                  selectedImagePath: _selectedImagePath,
                ),
                SizedBox(height: screenHeight * 0.02), // Responsive height
                UpdateText(),
                SizedBox(height: screenHeight * 0.02),
                FullnameTextFiled(updateController: updateController),
                SizedBox(height: screenHeight * 0.01), // Responsive height
                UsernameTextFiled(updateController: updateController),
                SizedBox(height: screenHeight * 0.02), // Responsive height
                UpdateButton(updateController: updateController)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UpdateController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController profileImageController = TextEditingController();
  final _UpdateScreenState _state;

  UpdateController({
    required _UpdateScreenState state,
  }) : _state = state;

  Future<void> _uploadImageAndUpdate(BuildContext context) async {
    if (_state._imageFile != null) {
      await _state._uploadImage(); // Llama a la función de subir imagen
    }
    updateUser(context); // Llama a la función signUp después de subir la imagen
  }

  void updateUser(BuildContext context) async {
    String? username = usernameController.text;
    String? fullname = fullnameController.text;
    String? email = emailController.text;
    String? password = passwordController.text;
    String? profileImage = _state.getImageUrl() ?? profileImageController.text;

    Map<String, dynamic> userData2 = {
      'username': username,
      'fullname': fullname,
      'email': email,
      'password': password,
      'profileImage': profileImage,
    };

    ApiResponse response = await UserService.updateUser(userData2);

    // Calculate responsive dialog size
    double width = MediaQuery.of(context).size.width;
    double dialogWidth =
        width > 600 ? 500 : width * 0.8; // For larger screens, cap the width

    Get.defaultDialog(
      title: 'felicidades'.tr,
      titleStyle: TextStyle(color: Theme.of(context).primaryColor),
      backgroundColor: Theme.of(context).colorScheme.primary,
      content: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
          child: Container(
            width: dialogWidth, // Use the calculated width
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0), // Consistent padding
              child: Column(
                mainAxisSize: MainAxisSize.min, // Only take required space
                children: [
                  Lottie.asset(
                    "assets/json/check3.json",
                    width: 100,
                    height: 100,
                    repeat: false,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'perfilActualizado'.tr,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      radius: 10.0,
      confirm: ElevatedButton(
        onPressed: () {
          Get.offAll(ProfilePage());
        },
        child: Text(
          'aceptar'.tr,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          backgroundColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }
}

class UpdateButton extends StatelessWidget {
  final UpdateController updateController;

  UpdateButton({
    required this.updateController,
  });

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get the screen width and height
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Adjust the button size and margin based on the screen size
    double buttonWidth = screenWidth * 0.8; // 80% of screen width
    double buttonHeight = screenHeight * 0.06; // 6% of screen height
    double horizontalMargin =
        screenWidth * 0.1; // 10% of screen width for both sides

    return FadeInDown(
      delay: Duration(milliseconds: 150),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
        width: buttonWidth,
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: () {
            updateController._uploadImageAndUpdate(context);
          },
          child: Text(
            'guardarCambios'.tr,
            style: TextStyle(
              fontSize: 20, // Consider making font size responsive if needed
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
              Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class UsernameTextFiled extends StatelessWidget {
  final UpdateController updateController;

  UsernameTextFiled({
    required this.updateController,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
        delay: Duration(milliseconds: 225),
        child: RepTextFiled(
            icon: LineIcons.userTag,
            text: 'nombreUsuario'.tr,
            controller: updateController.usernameController));
  }
}

class FullnameTextFiled extends StatelessWidget {
  final UpdateController updateController;

  FullnameTextFiled({
    required this.updateController,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
        delay: Duration(milliseconds: 225),
        child: RepTextFiled(
            icon: LineIcons.user,
            text: 'nombreCompleto'.tr,
            controller: updateController.fullnameController));
  }
}

class UpdateText extends StatelessWidget {
  const UpdateText({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return FadeInDown(
      delay: Duration(milliseconds: 125),
      child: Container(
        margin: EdgeInsets.only(
            top: 10, left: screenWidth * 0.1), // Responsive left margin
        width: screenWidth,
        height: screenHeight / 25,
        child: Text('actualizarPerfil'.tr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenHeight * 0.04, // Responsive font size
            )),
      ),
    );
  }
}

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    Key? key,
    required this.userData,
    required this.pickImageFunction,
    required this.selectedImagePath,
  }) : super(key: key);

  final Map<String, dynamic> userData;
  final Function(ImageSource) pickImageFunction;
  final String? selectedImagePath;

  @override
  Widget build(BuildContext context) {
    String profileImage = selectedImagePath ?? userData['profileImage'] ?? "";
    double imageSize =
        MediaQuery.of(context).size.width * 0.4; // 40% of screen width

    return Stack(
      children: [
        Container(
          width: imageSize,
          height: imageSize,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(imageSize / 2),
            child: Image(
              image: profileImage.isNotEmpty
                  ? Image.network(profileImage).image
                  : AssetImage("assets/images/profile.png"),
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 10,
          child: Ink(
            decoration: ShapeDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary, // Cambia este color al color del fondo deseado
              shape: CircleBorder(),
            ),
            child: IconButton(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context)
                    .colorScheme
                    .primary, // Cambia este color al color del icono deseado
              ),
              onPressed: () {
                pickImageFunction(ImageSource.gallery);
              },
            ),
          ),
        ),
      ],
    );
  }
}
