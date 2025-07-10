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
    apiKey: 'AIzaSyDKp_B-UEY8bA64JCDBTHxNOR81ZvP3Gi0',
    appId: '1:703752159317:web:41c6b431753f464c6214dc',
    messagingSenderId: '703752159317',
    projectId: 'synapse-ride',
    authDomain: 'synapse-ride.firebaseapp.com',
    storageBucket: 'synapse-ride.firebasestorage.app',
    measurementId: 'G-0FFPNJ69NK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAjIcwYf5PlmawvJ5axCyd4e8iAl05Szoo',
    appId: '1:703752159317:android:40677dfcc9e6f2666214dc',
    messagingSenderId: '703752159317',
    projectId: 'synapse-ride',
    storageBucket: 'synapse-ride.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyChQ-oZ1tMlHaTCGNVqqUsRjeBbFfhyDok',
    appId: '1:703752159317:ios:04d6ab4ede421d866214dc',
    messagingSenderId: '703752159317',
    projectId: 'synapse-ride',
    storageBucket: 'synapse-ride.firebasestorage.app',
    iosBundleId: 'com.example.synapseride',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyChQ-oZ1tMlHaTCGNVqqUsRjeBbFfhyDok',
    appId: '1:703752159317:ios:04d6ab4ede421d866214dc',
    messagingSenderId: '703752159317',
    projectId: 'synapse-ride',
    storageBucket: 'synapse-ride.firebasestorage.app',
    iosBundleId: 'com.example.synapseride',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDKp_B-UEY8bA64JCDBTHxNOR81ZvP3Gi0',
    appId: '1:703752159317:web:5e30711c87f25af66214dc',
    messagingSenderId: '703752159317',
    projectId: 'synapse-ride',
    authDomain: 'synapse-ride.firebaseapp.com',
    storageBucket: 'synapse-ride.firebasestorage.app',
    measurementId: 'G-3F2EDWBBDD',
  );
}
