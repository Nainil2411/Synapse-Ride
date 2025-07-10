import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/custom_color.dart';

class ContactUsController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final messageController = TextEditingController();


  var nameError = false.obs;
  var emailError = false.obs;
  var messageError = false.obs;
  var phoneError = ''.obs;
  var isLoading = false.obs;
  var viewAll = false.obs;
  var hasComplaints = false.obs;

  @override
  void onInit() {
    checkForComplaints();
    super.onInit();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    messageController.dispose();
    super.onClose();
  }

  Future<void> checkForComplaints() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final complaintsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('contact_us')
            .get();

        hasComplaints.value = complaintsSnapshot.docs.isNotEmpty;
      }
    } catch (e) {
      log("Error: $e");
    }
  }

  void _showAutoDismissDialog(
      {required String title, required String message}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 48, color: CustomColors.green1),
              const SizedBox(height: 16),
              Text(
                title,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });
  }

  bool validateForm() {
    bool isValid = true;
    if (nameController.text.isEmpty) {
      nameError.value = true;
      isValid = false;
    } else {
      nameError.value = false;
    }

    if (emailController.text.isEmpty || !validateEmail(emailController.text)) {
      emailError.value = true;
      isValid = false;
    } else {
      emailError.value = false;
    }

    if (phoneController.text.isEmpty || phoneController.text.length != 10) {
      phoneError.value = AppStrings.phoneNumberrequire;
      isValid = false;
    } else {
      phoneError.value = '';
    }

    if (messageController.text.isEmpty) {
      messageError.value = true;
      isValid = false;
    } else {
      messageError.value = false;
    }

    return isValid;
  }

  bool validateEmail(String email) {
    return email.contains('@') && email.contains('.com') && email.trim().isNotEmpty;
  }

  Future<void> submitForm() async {
    if (!validateForm()) return;

    isLoading.value = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('contact_us')
            .add({
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'message': messageController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        nameController.clear();
        emailController.clear();
        phoneController.clear();
        messageController.clear();
        hasComplaints.value = true;

        _showAutoDismissDialog(
          title: AppStrings.success,
          message: AppStrings.messageSentSuccessfully,
        );
      }
    } catch (e) {
      log("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteComplaint(String docId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('contact_us')
            .doc(docId)
            .delete();
        Get.snackbar('Successful', AppStrings.complaintDeletedSuccessfully,
            backgroundColor: CustomColors.green1);
        checkForComplaints();
      }
    } catch (e) {
      Get.snackbar('Error', '${AppStrings.errorDeletingComplaint}: $e',
          backgroundColor: CustomColors.error);
    }
  }
}