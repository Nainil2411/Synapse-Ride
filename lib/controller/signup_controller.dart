import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synapseride/utils/firebase.dart';

class SignupController extends GetxController {
  final formKey = GlobalKey<FormState>();

  RxBool obscurePassword = true.obs;
  RxBool isLoading = false.obs;
  RxString selectedGender = 'Male'.obs;
  RxString emailError = ''.obs;
  RxString passwordError = ''.obs;
  RxString firstNameError = ''.obs;
  RxString lastNameError = ''.obs;
  RxString addressError = ''.obs;
  RxString phoneError = ''.obs;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  double? latitude;
  double? longitude;

  final FirebaseAuthService authService = FirebaseAuthService();

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

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text = DateFormat('MMM dd,yyyy').format(picked);
    }
  }

  Future<void> handleSignup() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;

      try {
        final userCredential = await authService.signUpWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          phoneNumber: phoneController.text.trim(),
          dob: dobController.text.trim(),
          address: addressController.text.trim(),
          gender: selectedGender.value,
          latitude: latitude,
          longitude: longitude,
        );
        if (userCredential != null && userCredential.user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          Get.offAllNamed('/home');
        }
      } catch (e) {
        log("Signup error: $e");
      } finally {
        isLoading.value = false;
      }
    }
  }
}
