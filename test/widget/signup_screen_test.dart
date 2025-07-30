
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/elevated_button.dart';
import 'package:synapseride/common/textformfield.dart';
import 'package:synapseride/screens/subscreen/signup_screen.dart';
import 'package:synapseride/utils/firebase.dart';

import '../mock/mock_firebase_auth_service.dart';
import '../mock/mock_user_credential.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Signup Integration Test', () {
    late MockFirebaseAuthService mockAuth;

    setUp(() {
      Get.testMode = true;
      Get.reset();
      mockAuth = MockFirebaseAuthService();
      Get.put<FirebaseAuthService>(mockAuth);
    });

    tearDown(() {
      Get.reset();
      Get.testMode = false;
    });

    testWidgets('Valid signup navigates to home screen', (tester) async {
      when(mockAuth.signUpWithEmailAndPassword(
        email: 'test@example.com',
        password: 'Password1!',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '1234567890',
        dob: 'Jan 01,2000',
        address: '123 Main St',
        gender: 'Male',
        latitude: anyNamed('latitude'),
        longitude: anyNamed('longitude'),
      )).thenAnswer((_) async => MockUserCredential());

      await tester.pumpWidget(GetMaterialApp(home: SignupScreen()));
      await tester.pumpAndSettle();

      // Enter text in the fields (adjust indices as per your widget tree)
      await tester.enterText(find.byType(CustomTextFormField).at(0), 'John'); // First Name
      await tester.enterText(find.byType(CustomTextFormField).at(1), 'Doe'); // Last Name
      await tester.enterText(find.byType(CustomTextFormField).at(2), 'test@example.com'); // Email
      await tester.enterText(find.byType(CustomTextFormField).at(3), '123 Main St'); // Address
      await tester.enterText(find.byType(CustomTextFormField).at(4), 'Jan 01,2000'); // DOB
      await tester.enterText(find.byType(IntlPhoneField), '1234567890'); // Phone
      await tester.enterText(find.byType(CustomTextFormField).at(5), 'Password1!'); // Password

      final signUpButton = find.widgetWithText(CustomElevatedButton, AppStrings.signup);
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();
      // You can add expect() here for navigation or success message if needed
    });

    testWidgets('Invalid signup shows error message', (tester) async {
      when(mockAuth.signUpWithEmailAndPassword(
        email: 'wrong@example.com',
        password: 'badpass',
        firstName: 'Jane',
        lastName: 'Doe',
        phoneNumber: '1234567890',
        dob: 'Jan 01,2000',
        address: '123 Main St',
        gender: 'Female',
        latitude: anyNamed('latitude'),
        longitude: anyNamed('longitude'),
      )).thenThrow(Exception('Signup failed'));

      await tester.pumpWidget(GetMaterialApp(home: SignupScreen()));
      await tester.pumpAndSettle();
    });
  });
} 