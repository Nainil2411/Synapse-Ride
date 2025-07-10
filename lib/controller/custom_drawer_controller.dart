import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synapseride/Routes/routes.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_color.dart';

class CustomDrawerController extends GetxController {
  var isLoading = false.obs;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return await FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  Future<void> deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(AppStrings.confirm, style: AppTextStyles.headline4Light),
        content: Text(AppStrings.confirmDeleteuser,
            style: AppTextStyles.bodyMedium.copyWith(color: CustomColors.background)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(AppStrings.cancel,
                style: AppTextStyles.bodyMedium.copyWith(color: CustomColors.background)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(AppStrings.yes,
                style: AppTextStyles.bodyMedium.copyWith(color: CustomColors.error)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isLoading.value = true;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      await user.delete();

      isLoading.value = false;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to delete account: ${e.toString()}',
        backgroundColor: CustomColors.error,
        colorText: CustomColors.background,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
