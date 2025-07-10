import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_string.dart';

class ForgotPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var message = ''.obs;
  var isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> handleResetPassword() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      message.value = '';

      String email = emailController.text.trim();

      try {
        await _auth.sendPasswordResetEmail(email: email);
        await _showSuccessDialog();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-email') {
        } else {
          message.value = "Error: ${e.message}";
        }
      } catch (e) {
        log("Error sending password reset email: $e");
        message.value = "An unexpected error occurred. Please try again.";
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    return Get.dialog(
      AlertDialog(
        title: Text(AppStrings.successfulPasswordReset),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(AppStrings.linksent),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(AppStrings.ok),
            onPressed: () {
              Get.back();
              Get.back();
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.enterYourEmail;
    }
    final bool emailValid =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
            .hasMatch(value);
    if (!emailValid) {
      return AppStrings.entervalidemail;
    }
    return null;
  }
}
