// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyACjmUfXRN1YA_shqu1yY1YWxULuPzMBlw',
    appId: '1:374472448870:web:6bc2ff54a26e2f6131c6a7',
    messagingSenderId: '374472448870',
    projectId: 'flutter-now-6e8cc',
    authDomain: 'flutter-now-6e8cc.firebaseapp.com',
    storageBucket: 'flutter-now-6e8cc.appspot.com',
    measurementId: 'G-46SXZ2FN6J',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBmja39_bLoxhaqj-_3S49hZTq6EIkcPtM',
    appId: '1:374472448870:android:7ecba7906116224531c6a7',
    messagingSenderId: '374472448870',
    projectId: 'flutter-now-6e8cc',
    storageBucket: 'flutter-now-6e8cc.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDJjGZGkUItG69n0q6QxzoKmmdqfch96es',
    appId: '1:374472448870:ios:53b72fbfe52ce5fb31c6a7',
    messagingSenderId: '374472448870',
    projectId: 'flutter-now-6e8cc',
    storageBucket: 'flutter-now-6e8cc.appspot.com',
    androidClientId: '374472448870-m40kjgkp3qpq6vgpf3vf66t7lck130he.apps.googleusercontent.com',
    iosClientId: '374472448870-i386r8l7r0ob7lnr3ndc1l044jq8uduh.apps.googleusercontent.com',
    iosBundleId: 'com.now.app',
  );

}