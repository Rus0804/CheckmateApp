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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyAZaN3XOW60aKrLE1UmGeGYta2DdBrXBok',
    appId: '1:527987339209:web:82a21248b24897203c4218',
    messagingSenderId: '527987339209',
    projectId: 'checkmateclub26',
    authDomain: 'checkmateclub26.firebaseapp.com',
    storageBucket: 'checkmateclub26.firebasestorage.app',
    measurementId: 'G-H6W1871WN6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAgAY7EmNQ2W5dSczFo4jqGqIoTqszlZzQ',
    appId: '1:527987339209:android:d47cd01a8dd3b3443c4218',
    messagingSenderId: '527987339209',
    projectId: 'checkmateclub26',
    storageBucket: 'checkmateclub26.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAZaN3XOW60aKrLE1UmGeGYta2DdBrXBok',
    appId: '1:527987339209:web:e2adc50883b30e273c4218',
    messagingSenderId: '527987339209',
    projectId: 'checkmateclub26',
    authDomain: 'checkmateclub26.firebaseapp.com',
    storageBucket: 'checkmateclub26.firebasestorage.app',
    measurementId: 'G-552CSQMWVH',
  );
}
