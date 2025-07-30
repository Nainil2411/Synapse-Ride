import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/screens/subscreen/login_screen.dart';
import 'package:synapseride/utils/firebase.dart'; // Needed for the service type
import '../mock/mock_firebase_auth_service.dart';  // Adjust path if needed

void main() {
  testWidgets('LoginScreen renders and performs input validation', (WidgetTester tester) async {
    // 1. Create and inject your mock service for the test
    final mockAuthService = MockFirebaseAuthService();

    // Register with GetX
    Get.put<FirebaseAuthService>(mockAuthService);

    // 2. Pump your widget
    await tester.pumpWidget(
      GetMaterialApp(home: LoginScreen()),
    );
    await tester.pumpAndSettle();

// Tap the login button with empty fields
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

// Check for validation error texts
    expect(find.text(AppStrings.enteremail), findsWidgets);
    expect(find.text(AppStrings.enterPassword), findsWidgets);

    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'Password123!');
    await tester.tap(find.text('Log In'));
    await tester.pump();

    // 4. Reset GetX after the test (important for test isolation)
    Get.reset();
  });
}