import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:proyecto_flutter/api/services/token_service.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/widget/socket_manager.dart';

class AuthService {
  //Google Sign In
  static Future<User?> signInWithGoogle() async {
    // beggin interactive sign in process
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // obtain auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // create new credential for user
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // sign in with credential
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(
      credential,
    );
    await registerGoogleUser(userCredential);
    await loginGoogleUser(userCredential);
    //await TokenService.saveToken(googleAuth.accessToken);
    return userCredential.user;
  }
   static Future<void> registerGoogleUser(UserCredential userCredential) async {
    User? user1 = userCredential.user;

    // Verifica si el usuario ya está registrado en tu sistema
    // Si no está registrado, puedes registrar al usuario
    if (user1 != null ){
      // Extrae el nombre de usuario del correo electrónico antes del símbolo @
      String username = user1.email!.split('@').first;
      ApiResponse response = await UserService.usernameExists(username);
      bool usernameExists = response.data['usernameExists'];

      if(!usernameExists){
      Map<String, dynamic> userData = {
        'username': username,
        'email': user1.email,
        'fullname': username,
        'password': username,
        'rol': 'cliente',
        'rating': 0,
        'profileImage': ''
        // Otros campos según tus necesidades
      };
      // Registrar al usuario en tu sistema
      await UserService.registerUser(userData);
      }
    }
  }

static Future<void> loginGoogleUser(UserCredential userCredential) async {
    User? user = userCredential.user;

    // Verifica si el usuario ya está registrado en tu sistema
    // Si no está registrado, puedes registrar al usuario
    if (user != null ){
      // Extrae el nombre de usuario del correo electrónico antes del símbolo @
      String username = user.email!.split('@').first;

      Map<String, dynamic> userData = {
        'email': user.email,
        'password': username,
        // Otros campos según tus necesidades
      };
       ApiResponse response = await UserService.loginUser(userData);
    print(userData);
    if (response.statusCode == 200) {
      String? token = response.data['token'];
      print(token);
      if (token != null) {
        await TokenService.saveToken(token);
        SocketManager();
      } else {
        print('token'.tr);
      }
     }
    } 
   }
}




   



 