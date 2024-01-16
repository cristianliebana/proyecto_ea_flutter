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
      print('Aquí debería salir el usuario: $userData');
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
    return Scaffold(
      appBar: _buildAppBar(),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 5),
      body: SingleChildScrollView(
        child: Container(
            child: Column(
          children: [
            SizedBox(height: 50),
            ProfileImage(
              userData: userData,
            ),
            const SizedBox(height: 10),
            if (userData.isNotEmpty) UsernameText(userData: userData),
            const SizedBox(height: 10),
            if (userData.isNotEmpty) EmailText(userData: userData),
            if (userData.isEmpty) CircularProgressIndicator(),
            const SizedBox(height: 20),
            EditProfileButton(),
            const SizedBox(height: 30),
            Divider(
              thickness: 0.2,
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
                  Get.to(UserProfileScreen(userId: userController.userId.value,));
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
              thickness: 0.2,
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
                // text1Color: Theme.of(context).shadowColor,
                customColor: Theme.of(context).shadowColor,
                endIcon: false),
          ],
        )),
      ),
    );
  }
}

class EmailText extends StatelessWidget {
  const EmailText({
    Key? key,
    required this.userData,
  });

  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    String email = userData['email'] ?? "N/A";

    return Text(
      email != "N/A" ? "$email" : "",
      style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w200,
          color: Theme.of(context).primaryColor),
    );
  }
}

class UsernameText extends StatelessWidget {
  const UsernameText({
    Key? key,
    required this.userData,
  });

  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    String username = userData['username'] ?? "N/A";

    return Text(
      username != "N/A" ? "$username" : "",
      style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor),
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

    return Container(
      width: 175,
      height: 175,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: CldImageWidget(
          publicId: profileImage.isNotEmpty
              ? profileImage
              : "https://res.cloudinary.com/dfwsx27vx/image/upload/v1701028188/profile_ju3yvo.png",
          width: 175,
          height: 175,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// "assets/images/profile.png"
class EditProfileButton extends StatelessWidget {
  const EditProfileButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 100),
      width: gWidth,
      height: gHeight / 15,
      child: ElevatedButton(
        onPressed: () async {
          Get.to(UpdateScreen());
        },
        child: Text(
          'editarPerfil'.tr,
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
    return ListTile(
      onTap: onPress,
      title: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
              ),
              child: Icon(icon,
                  color: Theme.of(context).colorScheme.primary, size: 25),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: customColor != null
                      ? Theme.of(context).dividerColor
                      : Theme.of(context).primaryColor,
                  fontSize: 18,
                ),
              ),
            ),
            if (endIcon)
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
                ),
                child: Icon(LineAwesomeIcons.angle_right,
                    color: Theme.of(context).colorScheme.onPrimary, size: 25),
              ),
          ],
        ),
      ),
    );
  }
}
