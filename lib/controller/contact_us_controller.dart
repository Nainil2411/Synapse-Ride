import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/custom_color.dart';

class ContactUsController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final messageController = TextEditingController();

  var nameError = false.obs;
  var emailError = false.obs;
  var messageError = false.obs;
  var phoneError = ''.obs;
  var isLoading = false.obs;
  var isDeleting = false.obs;
  var contacts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    _loadContacts();
  }

  @override
  void onClose() {
    tabController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    messageController.dispose();
    super.onClose();
  }

  Future<void> _loadContacts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final contactsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('contact_us')
            .orderBy('timestamp', descending: true)
            .get();

        contacts.value = contactsSnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      }
    } catch (e) {
      log('Error loading contacts: $e');
      Get.snackbar(
        'Error',
        'Failed to load contact history',
        backgroundColor: CustomColors.error.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    }
  }

  bool validateForm() {
    bool isValid = true;

    if (nameController.text.trim().isEmpty) {
      nameError.value = true;
      isValid = false;
    } else {
      nameError.value = false;
    }

    if (emailController.text.trim().isEmpty || !validateEmail(emailController.text.trim())) {
      emailError.value = true;
      isValid = false;
    } else {
      emailError.value = false;
    }

    if (phoneController.text.trim().isEmpty || phoneController.text.trim().length != 10) {
      phoneError.value = AppStrings.phoneNumberrequire;
      isValid = false;
    } else {
      phoneError.value = '';
    }

    if (messageController.text.trim().isEmpty) {
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
    if (!validateForm()) {
      Get.snackbar(
        'Incomplete Form',
        'Please fill all fields correctly',
        backgroundColor: CustomColors.error.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: Icon(
          Icons.warning_rounded,
          color: Colors.white,
        ),
      );
      return;
    }

    isLoading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Simulate API call delay
        await Future.delayed(const Duration(seconds: 2));

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('contact_us')
            .add({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'message': messageController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Clear form
        nameController.clear();
        emailController.clear();
        phoneController.clear();
        messageController.clear();

        // Reload contacts
        await _loadContacts();

        // Show success message
        Get.snackbar(
          'Success!',
          'Your message has been sent successfully',
          backgroundColor: CustomColors.green1.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 4),
          icon: Icon(
            Icons.check_circle_rounded,
            color: Colors.white,
          ),
        );

        // Switch to history tab with animation
        tabController.animateTo(1);
      }
    } catch (e) {
      log("Error: $e");
      Get.snackbar(
        'Submission Failed',
        'Something went wrong. Please try again.',
        backgroundColor: CustomColors.error.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: Icon(
          Icons.error_rounded,
          color: Colors.white,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteContact(int index) async {
    if (index < 0 || index >= contacts.length) return;

    isDeleting.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Simulate deletion delay for better UX
        await Future.delayed(const Duration(milliseconds: 500));

        final contactId = contacts[index]['id'];
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('contact_us')
            .doc(contactId)
            .delete();

        final deletedContact = contacts[index];
        contacts.removeAt(index);

        Get.snackbar(
          'Deleted',
          'Message removed successfully',
          backgroundColor: CustomColors.grey700.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
          mainButton: TextButton(
            onPressed: () => _undoDelete(deletedContact, index),
            child: Text(
              'UNDO',
              style: TextStyle(
                color: CustomColors.yellow1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          icon: Icon(
            Icons.delete_rounded,
            color: Colors.white,
          ),
        );
      }
    } catch (e) {
      log('Error deleting contact: $e');
      Get.snackbar(
        'Delete Failed',
        'Could not delete message. Please try again.',
        backgroundColor: CustomColors.error.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isDeleting.value = false;
    }
  }

  void _undoDelete(Map<String, dynamic> contact, int originalIndex) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Re-add to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('contact_us')
            .add({
          'name': contact['name'],
          'email': contact['email'],
          'phone': contact['phone'],
          'message': contact['message'],
          'timestamp': contact['timestamp'],
        });

        // Reload contacts to get the new document ID
        await _loadContacts();

        Get.snackbar(
          'Restored',
          'Message has been restored',
          backgroundColor: CustomColors.green1.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 2),
          icon: Icon(
            Icons.restore_rounded,
            color: Colors.white,
          ),
        );
      }
    } catch (e) {
      log('Error restoring contact: $e');
    }
  }

  void switchToHistoryTab() {
    tabController.animateTo(1);
  }

  void switchToFormTab() {
    tabController.animateTo(0);
  }

  // Helper methods
  bool get hasContacts => contacts.isNotEmpty;

  int get totalContacts => contacts.length;
}