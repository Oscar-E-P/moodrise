
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


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
    apiKey: 'AIzaSyCe1EJ1GHqieIUbQXpgFNHsdoQm9UMmrzQ',
    appId: '1:149270457535:web:0b421eb4a44ab28ef56a0a',
    messagingSenderId: '149270457535',
    projectId: 'moodrise-c0310',
    authDomain: 'moodrise-c0310.firebaseapp.com',
    storageBucket: 'moodrise-c0310.firebasestorage.app',
    measurementId: 'G-Y5DD1FJ9N4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA8C6ImnA_2gPw4dzDV4EX3bnDAh2arQBA',
    appId: '1:149270457535:android:c673b82729dab82ff56a0a',
    messagingSenderId: '149270457535',
    projectId: 'moodrise-c0310',
    storageBucket: 'moodrise-c0310.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAHtoOGs7TJ0df-poeDTnETukmOHKFBB6I',
    appId: '1:149270457535:ios:32fea1ade67df770f56a0a',
    messagingSenderId: '149270457535',
    projectId: 'moodrise-c0310',
    storageBucket: 'moodrise-c0310.firebasestorage.app',
    iosBundleId: 'com.example.moodrise',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAHtoOGs7TJ0df-poeDTnETukmOHKFBB6I',
    appId: '1:149270457535:ios:32fea1ade67df770f56a0a',
    messagingSenderId: '149270457535',
    projectId: 'moodrise-c0310',
    storageBucket: 'moodrise-c0310.firebasestorage.app',
    iosBundleId: 'com.example.moodrise',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCe1EJ1GHqieIUbQXpgFNHsdoQm9UMmrzQ',
    appId: '1:149270457535:web:f6294f14622bc16af56a0a',
    messagingSenderId: '149270457535',
    projectId: 'moodrise-c0310',
    authDomain: 'moodrise-c0310.firebaseapp.com',
    storageBucket: 'moodrise-c0310.firebasestorage.app',
    measurementId: 'G-EBZDK61H4H',
  );
}
