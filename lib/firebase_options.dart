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
        return macos;
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
    apiKey: 'AIzaSyB_8jxUDrr5QzdrMIrrgfKcD0AxMkcZM5M',
    appId: '1:813017536323:web:aafb8ab08ce324242b81f6',
    messagingSenderId: '813017536323',
    projectId: 'wellnest-demo',
    authDomain: 'wellnest-demo.firebaseapp.com',
    storageBucket: 'wellnest-demo.firebasestorage.app',
    measurementId: 'G-HJ5JYFMSJK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBoafburUypIqs9BUbQ0ELVpOBOLjLmTrE',
    appId: '1:813017536323:android:674c9de2347356b92b81f6',
    messagingSenderId: '813017536323',
    projectId: 'wellnest-demo',
    storageBucket: 'wellnest-demo.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCdpW5Ylx2bvKg5G0tS1xt18AHHYafNFJs',
    appId: '1:813017536323:ios:0321bd182dc76a4b2b81f6',
    messagingSenderId: '813017536323',
    projectId: 'wellnest-demo',
    storageBucket: 'wellnest-demo.firebasestorage.app',
    iosBundleId: 'com.example.albertianWellnest',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCdpW5Ylx2bvKg5G0tS1xt18AHHYafNFJs',
    appId: '1:813017536323:ios:0321bd182dc76a4b2b81f6',
    messagingSenderId: '813017536323',
    projectId: 'wellnest-demo',
    storageBucket: 'wellnest-demo.firebasestorage.app',
    iosBundleId: 'com.example.albertianWellnest',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB_8jxUDrr5QzdrMIrrgfKcD0AxMkcZM5M',
    appId: '1:813017536323:web:98d49ba07346b07c2b81f6',
    messagingSenderId: '813017536323',
    projectId: 'wellnest-demo',
    authDomain: 'wellnest-demo.firebaseapp.com',
    storageBucket: 'wellnest-demo.firebasestorage.app',
    measurementId: 'G-FH4CEM7ZT5',
  );
}
