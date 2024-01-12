// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCbgjisCF3qiJtAKT_eUAew2vFGJQzkYpE',
    appId: '1:237252769614:web:1efd9a663b25b8cce8501f',
    messagingSenderId: '237252769614',
    projectId: 'km0-market',
    authDomain: 'km0-market.firebaseapp.com',
    storageBucket: 'km0-market.appspot.com',
  );
  
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBoeKpQC8HotoeQtwUlYWL2gK6T2WCftgI',
    appId: '1:237252769614:android:0d7658a974010729e8501f',
    messagingSenderId: '237252769614',
    projectId: 'km0-market',
    storageBucket: 'km0-market.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBJyfIDrFfspAPVCYypMCdJZ4-g42CS4yQ',
    appId: '1:237252769614:ios:1a7f715c7279602de8501f',
    messagingSenderId: '237252769614',
    projectId: 'km0-market',
    storageBucket: 'km0-market.appspot.com',
    androidClientId: '237252769614-mb4sj911ohdrn6nr15ho68vgpr05fdqp.apps.googleusercontent.com',
    iosClientId: '237252769614-g8dffjjruc6tuqmsj6jiii296s61mv91.apps.googleusercontent.com',
    iosBundleId: 'com.example.proyectoFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBJyfIDrFfspAPVCYypMCdJZ4-g42CS4yQ',
    appId: '1:237252769614:ios:f159d68efe812c12e8501f',
    messagingSenderId: '237252769614',
    projectId: 'km0-market',
    storageBucket: 'km0-market.appspot.com',
    androidClientId: '237252769614-mb4sj911ohdrn6nr15ho68vgpr05fdqp.apps.googleusercontent.com',
    iosClientId: '237252769614-idutb4cigd0h24pt6kvh21prem8k375t.apps.googleusercontent.com',
    iosBundleId: 'com.example.proyectoFlutter.RunnerTests',
  );
}
