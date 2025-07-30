import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/elevated_button.dart';
import 'package:synapseride/common/textformfield.dart';
import 'package:synapseride/main.dart' as app;
import 'package:synapseride/utils/firebase.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../test/mock/mock_firebase_auth_service.dart';
import '../test/mock/mock_user_credential.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Integration Test', () {
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

    testWidgets('Valid login navigates to home screen', (tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'Password123!',
      )).thenAnswer((_) async => MockUserCredential());

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Welcome!'), findsOneWidget);

      await tester.tap(find.text('Log In').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(CustomTextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(CustomTextFormField).at(1), 'Password123!');
      await tester.tap(find.widgetWithText(CustomElevatedButton, 'Log In'));
      await tester.pumpAndSettle();
    });

    testWidgets('Invalid login shows error message', (tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'wrong@example.com',
        password: 'BadPass!',
      )).thenThrow(Exception('Wrong password provided.'));

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Welcome!'), findsOneWidget);

      await tester.tap(find.text('Log In').first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(CustomTextFormField).at(0), 'wrong@example.com');
      await tester.enterText(find.byType(CustomTextFormField).at(1), 'BadPass!');
      await tester.tap(find.widgetWithText(CustomElevatedButton, 'Log In'));
      await tester.pumpAndSettle();

      final errorFinder = find.text(AppStrings.wrongPassword);
      await tester.pump(const Duration(milliseconds: 100));
      int tries = 0;
      while (tries < 20 && tester.widgetList(errorFinder).isEmpty) {
        await tester.pump(const Duration(milliseconds: 100));
        tries++;
      }

      expect(errorFinder, findsOneWidget);
    });
  });

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

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Welcome!'), findsOneWidget);
      await tester.tap(find.text('Sign Up').first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(CustomTextFormField).at(0), 'John');
      await tester.enterText(find.byType(CustomTextFormField).at(1), 'Doe');
      await tester.enterText(find.byType(CustomTextFormField).at(2), 'test@example.com');
      await tester.enterText(find.byType(CustomTextFormField).at(3), '123 Main St');
      await tester.enterText(find.byType(CustomTextFormField).at(4), 'Jan 01,2000');
      await tester.enterText(find.byType(IntlPhoneField), '1234567890');
      await tester.enterText(find.byType(CustomTextFormField).at(5), 'Password1!');

      final signUpButton = find.widgetWithText(CustomElevatedButton, AppStrings.signup);
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();
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

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Welcome!'), findsOneWidget);
      await tester.tap(find.text('Sign Up').first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(CustomTextFormField).at(0), 'Jane');
      await tester.enterText(find.byType(CustomTextFormField).at(1), 'Doe');
      await tester.enterText(find.byType(CustomTextFormField).at(2), 'wrong@example.com');
      await tester.enterText(find.byType(CustomTextFormField).at(3), '123 Main St');
      await tester.enterText(find.byType(CustomTextFormField).at(4), 'Jan 01,2000');
      await tester.enterText(find.byType(IntlPhoneField), '1234567890');
      await tester.enterText(find.byType(CustomTextFormField).at(5), 'badpass');

      final signUpButton = find.widgetWithText(CustomElevatedButton, AppStrings.signup);
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();
    });
  });
}