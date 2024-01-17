import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:proyecto_flutter/api/services/token_service.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:get/get.dart';
import 'package:proyecto_flutter/screens/chatbot.dart';
import 'package:proyecto_flutter/screens/login.dart';
import 'package:proyecto_flutter/screens/on_boarding.dart';
import 'package:proyecto_flutter/screens/recipe.dart';
import 'package:proyecto_flutter/screens/update_user.dart';
import 'package:proyecto_flutter/screens/user_products.dart';
import 'package:proyecto_flutter/screens/user_profile.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:proyecto_flutter/utils/theme_provider.dart';
import 'package:proyecto_flutter/widget/language_controller.dart';
import 'package:proyecto_flutter/widget/nav_bar.dart';
import 'package:proyecto_flutter/widget/socket_manager.dart';
import 'package:proyecto_flutter/widget/userId_controller.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userData = {};
  @override
  void initState() {
    super.initState();
    checkAuthAndNavigate();
    obtenerDatosUsuario();
    CloudinaryContext.cloudinary =
        Cloudinary.fromCloudName(cloudName: "dfwsx27vx");
  }

  final List locale = [
    {'name': 'Español', 'locale': Locale('es')},
    {'name': 'English', 'locale': Locale('en')},
  ];
  updateLanguage(Locale locale) {
    Get.back();
    Get.updateLocale(locale);
  }

  Future<void> obtenerDatosUsuario() async {
    ApiResponse response = await UserService.getUserById();
    setState(() {
      userData = response.data;
    });
  }

  Future<void> checkAuthAndNavigate() async {
    await TokenService.loggedIn();
  }

  void _onRemoveTokenPressed() {
    TokenService.removeToken();
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      automaticallyImplyLeading: false,
      actions: [_buildAppBarThemeButton(), _buildAppBarLanguageButton()],
    );
  }

  Widget _buildAppBarThemeButton() {
    final ThemeProvider themeProvider = Get.find<ThemeProvider>();

    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: Theme.of(context).colorScheme.primary,
        ),
        onPressed: () {
          // Lógica para cambiar el tema
          Get.find<ThemeProvider>().toggleTheme();
        },
      ),
    );
  }

  Widget _buildAppBarLanguageButton() {
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon:
            Icon(Icons.language, color: Theme.of(context).colorScheme.primary),
        onPressed: () {
          buildLanguageDialog(context)();
        },
      ),
    );
  }

  buildLanguageDialog(BuildContext context) {
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
                    return Divider(
                      color: Colors.blue,
                    );
                  },
                  itemCount: locale.length),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double verticalSpace = MediaQuery.of(context).size.height * 0.02;
    double dividerThickness = MediaQuery.of(context).size.height * 0.002;

    return Scaffold(
      appBar: _buildAppBar(),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 5),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              SizedBox(height: verticalSpace * 2.5),
              ProfileImage(
                userData: userData,
              ),
              SizedBox(height: verticalSpace),
              if (userData.isNotEmpty) UsernameText(userData: userData),
              SizedBox(height: verticalSpace),
              if (userData.isNotEmpty) EmailText(userData: userData),
              if (userData.isEmpty) CircularProgressIndicator(),
              SizedBox(height: verticalSpace * 2),
              EditProfileButton(),
              SizedBox(height: verticalSpace * 3),
              Divider(
                thickness: dividerThickness,
                color: Theme.of(context).shadowColor,
              ),
              ProfileMenuWidget(
                  title: 'ajustes'.tr,
                  icon: LineAwesomeIcons.cog,
                  onPress: () {}),
              ProfileMenuWidget(
                  title: 'perfil'.tr,
                  icon: LineAwesomeIcons.user,
                  onPress: () {
                    userController.setUserId(userData['_id'] ?? '');
                    Get.to(UserProfileScreen(userId: userController.userId.value));
                  }),
              ProfileMenuWidget(
                  title: 'misProductos'.tr,
                  icon: LineAwesomeIcons.fruit_apple,
                  onPress: () {
                    Get.to(UserProductsScreen());
                  }),
              ProfileMenuWidget(
                  title: 'Mis Recetas'.tr,
                  icon: LineAwesomeIcons.receipt,
                  onPress: () {
                    Get.to(RecipeScreen());
                  }),
              Divider(
                thickness: dividerThickness,
                color: Theme.of(context).shadowColor,
              ),
              ProfileMenuWidget(
                  title: 'informacion'.tr,
                  icon: LineAwesomeIcons.info,
                  onPress: () {
                    Get.to(ConcentricTransitionPage());
                  }),
              ProfileMenuWidget(
                  title: 'logout'.tr,
                  icon: LineAwesomeIcons.alternate_sign_out,
                  onPress: () {
                    _onRemoveTokenPressed();
                  },
                  customColor: Theme.of(context).shadowColor,
                  endIcon: false),
            ],
          ),
        ),
      ),
    );
  }
}

class EmailText extends StatelessWidget {
  const EmailText({
    Key? key,
    required this.userData,
  }) : super(key: key);

  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    String email = userData['email'] ?? "N/A";
    double fontSize = MediaQuery.of(context).size.width * 0.04; // Adjust the font size based on the screen width

    return Text(
      email != "N/A" ? "$email" : "",
      style: TextStyle(
        fontSize: fontSize, // Responsive font size
        fontWeight: FontWeight.w200,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}


class UsernameText extends StatelessWidget {
  const UsernameText({
    Key? key,
    required this.userData,
  }) : super(key: key);

  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    String username = userData['username'] ?? "N/A";
    double fontSize = MediaQuery.of(context).size.width * 0.05; // Adjust the font size based on the screen width

    return Text(
      username != "N/A" ? "$username" : "",
      style: TextStyle(
        fontSize: fontSize, // Responsive font size
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}


class ProfileImage extends StatelessWidget {
  const ProfileImage({
    Key? key,
    required this.userData,
  }) : super(key: key);

  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    String profileImage = userData['profileImage'] ?? "";
    double imageSize = MediaQuery.of(context).size.width * 0.4; // Adjust the size based on the screen width

    return Container(
      width: imageSize,
      height: imageSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(imageSize / 2), // Make borderRadius responsive
        child: CldImageWidget(
          publicId: profileImage.isNotEmpty
              ? profileImage
              : "https://res.cloudinary.com/dfwsx27vx/image/upload/v1701028188/profile_ju3yvo.png",
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class EditProfileButton extends StatelessWidget {
  const EditProfileButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width * 0.6; // Adjust the width based on the screen width
    double buttonHeight = MediaQuery.of(context).size.height * 0.07; // Adjust the height based on the screen height

    return Container(
      margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.2), // Responsive horizontal margin
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () async {
          Get.to(UpdateScreen());
        },
        child: Text(
          'editarPerfil'.tr,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.05, // Responsive font size
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonHeight / 2), // Responsive borderRadius
              ),
            ),
            backgroundColor: MaterialStateProperty.all(
                Theme.of(context).colorScheme.onPrimary)),
      ),
    );
  }
}


class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.text1Color,
    this.customColor, // Nuevo parámetro para el color personalizado
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? text1Color;
  final Color? customColor; // Nuevo parámetro para el color personalizado

  @override
  Widget build(BuildContext context) {
    // Using MediaQuery for responsive layout
    double iconSize = MediaQuery.of(context).size.width * 0.1; // Dynamic icon size based on screen width
    double fontSize = MediaQuery.of(context).size.width * 0.045; // Dynamic font size based on screen width

    return ListTile(
      onTap: onPress,
      title: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: iconSize, // Responsive width
              height: iconSize, // Responsive height
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(iconSize / 2), // Responsive borderRadius
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
              ),
              child: Icon(icon,
                  color: Theme.of(context).colorScheme.primary, size: iconSize * 0.6), // Responsive icon size
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.05), // Responsive spacing
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: customColor ?? Theme.of(context).primaryColor, // Custom or default color
                  fontSize: fontSize, // Responsive font size
                ),
              ),
            ),
            if (endIcon)
              Container(
                width: iconSize * 0.6, // Responsive width
                height: iconSize * 0.6, // Responsive height
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
                ),
                child: Icon(LineAwesomeIcons.angle_right,
                    color: Theme.of(context).colorScheme.onPrimary, size: iconSize * 0.6), // Responsive icon size
              ),
          ],
        ),
      ),
    );
  }
}
