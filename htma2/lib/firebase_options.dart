import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Generated placeholder. Replace with output from `flutterfire configure`.
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
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCmHG38l2Pn4P9mits_fIb4jauAAPxZzws',
    appId: '1:755342721880:web:339343815f86a021eddb2d',
    messagingSenderId: '755342721880',
    projectId: 'shopsfirebase-a92b0',
    authDomain: 'shopsfirebase-a92b0.firebaseapp.com',
    databaseURL: 'https://shopsfirebase-a92b0-default-rtdb.firebaseio.com',
    storageBucket: 'shopsfirebase-a92b0.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBJ3fDXbp8AijHVH4RGFarOiZwltRVCzRQ',
    appId: '1:755342721880:android:bc1c2e76330cc454eddb2d',
    messagingSenderId: '755342721880',
    projectId: 'shopsfirebase-a92b0',
    databaseURL: 'https://shopsfirebase-a92b0-default-rtdb.firebaseio.com',
    storageBucket: 'shopsfirebase-a92b0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBNBkGnRmj5Suot37mc5gTMdl39TFGpAW0',
    appId: '1:755342721880:ios:c8a82314db8dbe39eddb2d',
    messagingSenderId: '755342721880',
    projectId: 'shopsfirebase-a92b0',
    databaseURL: 'https://shopsfirebase-a92b0-default-rtdb.firebaseio.com',
    storageBucket: 'shopsfirebase-a92b0.firebasestorage.app',
    iosBundleId: 'com.example.htmarevived',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBNBkGnRmj5Suot37mc5gTMdl39TFGpAW0',
    appId: '1:755342721880:ios:c8a82314db8dbe39eddb2d',
    messagingSenderId: '755342721880',
    projectId: 'shopsfirebase-a92b0',
    databaseURL: 'https://shopsfirebase-a92b0-default-rtdb.firebaseio.com',
    storageBucket: 'shopsfirebase-a92b0.firebasestorage.app',
    iosBundleId: 'com.example.htmarevived',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCmHG38l2Pn4P9mits_fIb4jauAAPxZzws',
    appId: '1:755342721880:web:3e7b4566e643bd7feddb2d',
    messagingSenderId: '755342721880',
    projectId: 'shopsfirebase-a92b0',
    authDomain: 'shopsfirebase-a92b0.firebaseapp.com',
    databaseURL: 'https://shopsfirebase-a92b0-default-rtdb.firebaseio.com',
    storageBucket: 'shopsfirebase-a92b0.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    appId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    messagingSenderId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    projectId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
  );
}