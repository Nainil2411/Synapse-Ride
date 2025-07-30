import 'package:firebase_auth/firebase_auth.dart';

class MockUserCredential implements UserCredential {
  @override
  final User? user = _MockUser();

  @override
  final AuthCredential? credential = null;

  @override
  final AdditionalUserInfo? additionalUserInfo = null;
}

class _MockUser implements User {
  @override
  String get uid => 'mockUid';

  // Stub all other members with noSuchMethod fallback
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
