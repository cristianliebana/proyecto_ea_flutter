import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  //Google Sign In
  static Future<User?> signInWithGoogle() async {
    // beggin interactive sign in process
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signInSilently();

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
    return userCredential.user;
  }
}