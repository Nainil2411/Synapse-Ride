import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/custom_color.dart';

class ProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  double? latitude;
  double? longitude;
  RxString addressError = ''.obs;
  RxString gender = AppStrings.male.obs;
  RxBool isLoading = false.obs;
  RxString imagePath = ''.obs;
  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    _authSubscription?.cancel();
    super.onClose();
  }

  void _initializeController() {
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadUserData();
        _loadImagePath();
      } else {
        _clearAllData();
      }
    });
  }

  Future<void> refreshUserData() async {
    _loadUserData();
    _loadImagePath();
  }

  void _clearAllData() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    gender.value = AppStrings.male;
    imagePath.value = '';
    addressError.value = '';
    latitude = null;
    longitude = null;
  }

  void showImageSourceBottomSheet(
      BuildContext context, ProfileController controller) {
    showModalBottomSheet(
      elevation: 3,
      backgroundColor: CustomColors.textPrimary,
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Choose an option",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CustomColors.yellow1)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        controller.pickImage(ImageSource.camera);
                      },
                      child: Column(
                        children: const [
                          Icon(Icons.camera_alt,
                              size: 40, color: CustomColors.yellow1),
                          SizedBox(height: 8),
                          Text("Camera",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: CustomColors.yellow1)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        controller.pickImage(ImageSource.gallery);
                      },
                      child: Column(
                        children: const [
                          Icon(Icons.image,
                              size: 40, color: CustomColors.yellow1),
                          SizedBox(height: 8),
                          Text("Gallery",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: CustomColors.yellow1)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _loadImagePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final userImageKey = 'avatarImagePath_$uid';
        imagePath.value = prefs.getString(userImageKey) ?? '';
      }
    } catch (e) {
      print('Error loading image path: $e');
      imagePath.value = '';
    }
  }

  String? getProfileImage() {
    return imagePath.value.isNotEmpty ? imagePath.value : null;
  }

  void _loadUserData() async {
    try {
      isLoading.value = true;
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        print('No user logged in');
        isLoading.value = false;
        return;
      }

      print('Loading data for user: $uid');

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;

        nameController.text =
            "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
        emailController.text = data['email'] ?? '';
        phoneController.text = data['phoneNumber'] ?? '';
        addressController.text = data['address'] ?? '';
        gender.value = data['gender'] ?? AppStrings.male;

        if (data['location'] != null && data['location'] is GeoPoint) {
          GeoPoint geoPoint = data['location'];
          latitude = geoPoint.latitude;
          longitude = geoPoint.longitude;
        } else {
          latitude = data['latitude']?.toDouble();
          longitude = data['longitude']?.toDouble();
        }

        print('User data loaded successfully');
      } else {
        print('User document does not exist');
        _clearAllData();
      }
    } catch (e) {
      print('Error loading user data: $e');
      Get.snackbar('Error', 'Failed to load profile data: $e',
          backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        imagePath.value = image.path;

        final prefs = await SharedPreferences.getInstance();
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          final userImageKey = 'avatarImagePath_$uid';
          await prefs.setString(userImageKey, image.path);
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar('Error', 'Failed to pick image',
          backgroundColor: Colors.red);
    }
  }

  void updateProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        Get.snackbar('Error', 'No user logged in', backgroundColor: Colors.red);
        return;
      }

      final names = nameController.text.trim().split(" ");
      final firstName = names.first;
      final lastName = names.length > 1 ? names.sublist(1).join(" ") : '';

      Map<String, dynamic> updateData = {
        'firstName': firstName,
        'lastName': lastName,
        'email': emailController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'gender': gender.value,
      };

      if (latitude != null && longitude != null) {
        updateData['location'] = GeoPoint(latitude!, longitude!);
        updateData['latitude'] = latitude;
        updateData['longitude'] = longitude;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(updateData);

      Get.snackbar(AppStrings.success, 'Profile updated successfully',
          backgroundColor: CustomColors.green1);
    } catch (e) {
      print('Error updating profile: $e');
      Get.snackbar('Error', 'Failed to update profile: $e',
          backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
}
