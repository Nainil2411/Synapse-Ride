import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synapseride/Routes/routes.dart';
import 'package:synapseride/utils/firebase.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();

  RxBool obscurePassword = true.obs;
  RxBool isLoading = false.obs;
  RxString emailError = ''.obs;
  RxString passwordError = ''.obs;
  RxString message = ''.obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  bool validateEmail(String email) {
    return email.contains('@') &&
        email.contains('.com') &&
        email.trim().isNotEmpty;
  }

  bool validatePassword(String password) {
    String errorMessage = '';

    if (password.length < 6) {
      errorMessage += 'Password must be longer than 6 characters.\n';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      errorMessage += '• Uppercase letter is missing.\n';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      errorMessage += '• Lowercase letter is missing.\n';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      errorMessage += '• Digit is missing.\n';
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      errorMessage += '• Special character is missing.\n';
    }

    passwordError.value = errorMessage;
    return errorMessage.isEmpty;
  }

  void handleLogin() async {
    FocusScope.of(Get.context!).unfocus();
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      message.value = '';

      try {
        final userCredential = await _authService.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        if (userCredential != null && userCredential.user != null) {
          await _authService.updateLastLogin(userCredential.user!.uid);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          Get.offAllNamed(AppRoutes.home);
          message.value = 'Login successful!';
        }
      } catch (e) {
        // Remove 'Exception: ' prefix if present
        final errorMsg = e.toString().replaceFirst('Exception: ', '');
        message.value = errorMsg;
      } finally {
        isLoading.value = false;
      }
    }
  }

  void handleGoogleSignIn() async {
    isLoading.value = true;
    message.value = '';
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null && userCredential.user != null) {
        await _authService.updateLastLogin(userCredential.user!.uid);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        Get.offAllNamed(AppRoutes.home);
        message.value = 'Login successful!';
      }
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      message.value = errorMsg;
    } finally {
      isLoading.value = false;
    }
  }
}
