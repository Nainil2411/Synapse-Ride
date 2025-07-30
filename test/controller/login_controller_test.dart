import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:synapseride/controller/login_controller.dart';
import '../mock/mock_firebase_auth_service.dart';
import 'package:synapseride/utils/firebase.dart';

void main() {
  late LoginController controller;
  late MockFirebaseAuthService mockAuthService;

  setUp(() {
    // Reset GetX dependencies before each test
    Get.reset();

    mockAuthService = MockFirebaseAuthService();
    // Inject the mock service before the controller is created
    Get.put<FirebaseAuthService>(mockAuthService);

    controller = LoginController();
    controller.emailController.text = 'test@example.com';
    controller.passwordController.text = 'Password123!';
  });

  test('Validate email success', () {
    final isValid = controller.validateEmail('test@example.com');
    expect(isValid, true);
  });

  test('Validate email failure', () {
    final isValid = controller.validateEmail('invalidemail');
    expect(isValid, false);
  });

  test('Validate password success', () {
    final isValid = controller.validatePassword('Password123!');
    expect(isValid, true);
  });

  test('Validate password failure', () {
    final isValid = controller.validatePassword('pass');
    expect(isValid, false);
    expect(controller.passwordError.value.contains('Uppercase'), true);
  });
}
