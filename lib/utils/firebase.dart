import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String dob,
    required String address,
    required String gender,
    double? latitude,
    double? longitude,
  }) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _createUserInFirestore(
          uid: userCredential.user!.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          dob: dob,
          address: address,
          gender: gender,
          latitude: latitude,
          longitude: longitude,
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login after successful sign in
      if (userCredential.user != null) {
        await updateLastLogin(userCredential.user!.uid);
      }

      await _setLoggedInStatus(true);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  Future<void> signOut() async {
    try {
      // Clear all user-related data before signing out
      await _clearUserData();
      await _auth.signOut();
      await GoogleSignIn.instance.signOut(); // Also sign out from Google
      await _setLoggedInStatus(false);
    } catch (e) {
      print('Error during sign out: $e');
      // Still set logged in status to false even if other operations fail
      await _setLoggedInStatus(false);
    }
  }

  // Clear all user-related data from SharedPreferences
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('avatarImagePath');
    // Add any other user-specific keys you want to clear
  }

  Future<void> _createUserInFirestore({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String dob,
    required String gender,
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'dob': dob,
      'address': address,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'gender': gender,
      if (latitude != null && longitude != null)
        'location': GeoPoint(latitude, longitude),
      // Store latitude and longitude separately as well
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
  }

  Future<void> updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _setLoggedInStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email.');
      case 'wrong-password':
        return Exception('Wrong password provided.');
      case 'email-already-in-use':
        return Exception('The email address is already in use.');
      case 'weak-password':
        return Exception('The password provided is too weak.');
      case 'invalid-email':
        return Exception('The email address is invalid.');
      default:
        return Exception('An error occurred: ${e.message}');
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        serverClientId: '459055251986-ck2u8hbkn78jcicustfiqs5tb35re739.apps.googleusercontent.com',
      );
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        throw Exception('Failed to get idToken from Google');
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        final user = userCredential.user;
        if (user != null) {
          await _createUserInFirestore(
            uid: user.uid,
            email: user.email ?? '',
            firstName: user.displayName?.split(' ').first ?? '',
            lastName: user.displayName?.split(' ').skip(1).join(' ') ?? '',
            phoneNumber: user.phoneNumber ?? '',
            dob: '',
            address: '',
            gender: '',
          );
        }
      } else {
        // Update last login for existing users
        if (userCredential.user != null) {
          await updateLastLogin(userCredential.user!.uid);
        }
      }

      await _setLoggedInStatus(true);
      return userCredential;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }
}