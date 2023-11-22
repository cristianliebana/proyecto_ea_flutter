import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:proyecto_flutter/api/services/token_service.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:get/get.dart';
import 'package:proyecto_flutter/screens/update_user.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:proyecto_flutter/widget/nav_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 4),
      body: SingleChildScrollView(
        child: Container(
            width: gWidth,
            height: gHeight,
            child: Column(
              children: [
                SizedBox(height: 50),
                ProfileImage(),
                const SizedBox(height: 10),
                if (userData.isNotEmpty) UsernameText(userData: userData),
                const SizedBox(height: 10),
                if (userData.isNotEmpty) EmailText(userData: userData),
                if (userData.isEmpty) CircularProgressIndicator(),
                const SizedBox(height: 20),
                EditProfileButton(),
                const SizedBox(height: 30),
                const Divider(),
                ProfileMenuWidget(
                    title: "Ajustes",
                    icon: LineAwesomeIcons.cog,
                    onPress: () {}),
                ProfileMenuWidget(
                    title: "Favoritos",
                    icon: LineAwesomeIcons.heart,
                    onPress: () {}),
                ProfileMenuWidget(
                    title: "Placeholder",
                    icon: LineAwesomeIcons.user_check,
                    onPress: () {}),
                const Divider(),
                ProfileMenuWidget(
                    title: "Información",
                    icon: LineAwesomeIcons.info,
                    onPress: () {}),
                ProfileMenuWidget(
                    title: "Cerrar sesión",
                    icon: LineAwesomeIcons.alternate_sign_out,
                    onPress: () {
                      _onRemoveTokenPressed();
                    },
                    text1Color: Color(0xFF486D28),
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
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
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
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    );
  }
}

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 175,
      height: 175,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: const Image(image: AssetImage('assets/images/profile.png')),
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 100),
      width: gWidth,
      height: gHeight / 15,
      child: ElevatedButton(
        onPressed: () async {
          Get.to(UpdateScreen());
        },
        child: Text(
          "Editar Perfil",
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
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? text1Color;

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
                color: Color(0xFF486D28).withOpacity(0.9),
              ),
              child: Icon(icon, color: Color(0xFFFFFCEA), size: 25),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: text1Color,
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
                  color: Color(0xFF486D28).withOpacity(0.9),
                ),
                child: const Icon(LineAwesomeIcons.angle_right,
                    size: 18.0, color: Color(0xFFFFFCEA)),
              ),
          ],
        ),
      ),
    );
  }
}
