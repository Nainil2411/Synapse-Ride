import 'package:mockito/mockito.dart';
import 'package:synapseride/utils/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {
  @override
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return super.noSuchMethod(
      Invocation.method(
        #signInWithEmailAndPassword,
        [],
        {#email: email, #password: password},
      ),
      returnValue: Future.value(null),
      returnValueForMissingStub: Future.value(null),
    );
  }

  @override
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
  }) {
    return super.noSuchMethod(
      Invocation.method(
        #signUpWithEmailAndPassword,
        [],
        {
          #email: email,
          #password: password,
          #firstName: firstName,
          #lastName: lastName,
          #phoneNumber: phoneNumber,
          #dob: dob,
          #address: address,
          #gender: gender,
          #latitude: latitude,
          #longitude: longitude,
        },
      ),
      returnValue: Future.value(null),
      returnValueForMissingStub: Future.value(null),
    );
  }
}
