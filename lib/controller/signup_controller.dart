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
  RxString dobError = ''.obs;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  double? latitude;
  double? longitude;

  final FirebaseAuthService _authService = Get.find<FirebaseAuthService>();

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

  bool validateLastName(String lastName) {
    if (lastName.trim().isEmpty) {
      lastNameError.value = 'Last name is required';
      return false;
    }
    if (lastName.trim().length < 2) {
      lastNameError.value = 'Last name must be at least 2 characters';
      return false;
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(lastName.trim())) {
      lastNameError.value = 'Last name can only contain letters and spaces';
      return false;
    }
    lastNameError.value = '';
    return true;
  }

  bool validatePhone(String phone) {
    if (phone.trim().isEmpty) {
      phoneError.value = 'Phone number is required';
      return false;
    }
    if (phone.trim().length < 10) {
      phoneError.value = 'Please enter a valid phone number (at least 10 digits)';
      return false;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(phone.trim())) {
      phoneError.value = 'Phone number can only contain digits';
      return false;
    }
    phoneError.value = '';
    return true;
  }

  bool validateDOB(String dob) {
    if (dob.trim().isEmpty) {
      return false;
    }
    try {
      final date = DateFormat('MMM dd,yyyy').parse(dob);
      final now = DateTime.now();
      int age = now.year - date.year;
      if (now.month < date.month || (now.month == date.month && now.day < date.day)) {
        age--;
      }
      if (age < 18) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
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
      // Validate the selected date
      if (!validateDOB(dobController.text)) {
        dobError.value = 'Please select a valid date of birth (must be 18 or older)';
      } else {
        dobError.value = '';
      }
    }
  }

  Future<void> handleSignup() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;

      try {
        final userCredential = await _authService.signUpWithEmailAndPassword(
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
        Get.snackbar(
          'Signup Error',
          e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> handleGoogleSignIn() async {
    isLoading.value = true;
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null && userCredential.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        Get.offAllNamed('/home');
      }
    } catch (e) {
      log("Google signup error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
