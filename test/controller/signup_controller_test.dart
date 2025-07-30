import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:synapseride/controller/signup_controller.dart';
import 'package:synapseride/utils/firebase.dart';
import '../mock/mock_firebase_auth_service.dart';


void main() {
  late SignupController controller;
  late MockFirebaseAuthService mockAuth;

  setUp(() {
    Get.testMode = true;
    Get.reset();
    mockAuth = MockFirebaseAuthService();
    Get.put<FirebaseAuthService>(mockAuth);
    controller = SignupController();
  });

  tearDown(() {
    Get.reset();
    Get.testMode = false;
  });

  test('validateEmail returns true for valid email', () {
    expect(controller.validateEmail('test@example.com'), isTrue);
  });

  test('validateEmail returns false for invalid email', () {
    expect(controller.validateEmail('invalidemail'), isFalse);
  });

  test('validatePassword returns true for valid password', () {
    expect(controller.validatePassword('Password1!'), isTrue);
  });

  test('validatePassword returns false for invalid password', () {
    expect(controller.validatePassword('pass'), isFalse);
  });
} 