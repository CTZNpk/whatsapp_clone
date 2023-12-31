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
    apiKey: 'AIzaSyCCkz5k7N7evuN2XzOmUi0ZJagsArDY_4A',
    appId: '1:819849228886:web:9c2665f5dcd20c10d381f7',
    messagingSenderId: '819849228886',
    projectId: 'whatsapp-clone-7675',
    authDomain: 'whatsapp-clone-7675.firebaseapp.com',
    storageBucket: 'whatsapp-clone-7675.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAwMFgJDr5iB3pIVpLTF7YwoQqCZcvkU4E',
    appId: '1:819849228886:android:35c95d0b8acf5425d381f7',
    messagingSenderId: '819849228886',
    projectId: 'whatsapp-clone-7675',
    storageBucket: 'whatsapp-clone-7675.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC3PHxie7Iw2wgXP0hEQw0iCrRNRWab7ng',
    appId: '1:819849228886:ios:a434b7c822960386d381f7',
    messagingSenderId: '819849228886',
    projectId: 'whatsapp-clone-7675',
    storageBucket: 'whatsapp-clone-7675.appspot.com',
    iosClientId: '819849228886-t002ctg3p500r56cbon1fufodh4q3q2g.apps.googleusercontent.com',
    iosBundleId: 'com.example.whatsappClone',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC3PHxie7Iw2wgXP0hEQw0iCrRNRWab7ng',
    appId: '1:819849228886:ios:1d5ac00637d7b7c3d381f7',
    messagingSenderId: '819849228886',
    projectId: 'whatsapp-clone-7675',
    storageBucket: 'whatsapp-clone-7675.appspot.com',
    iosClientId: '819849228886-r0hdahr2e62es2m17dpiq20tsdndeigd.apps.googleusercontent.com',
    iosBundleId: 'com.example.whatsappClone.RunnerTests',
  );
}
