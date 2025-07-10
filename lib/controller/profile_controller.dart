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

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _loadImagePath();
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
    final prefs = await SharedPreferences.getInstance();
    imagePath.value = prefs.getString('avatarImagePath') ?? '';
  }

  String? getProfileImage() {
    return imagePath.value.isNotEmpty ? imagePath.value : null;
  }

  void _loadUserData() async {
    isLoading.value = true;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        nameController.text = "${data['firstName']} ${data['lastName']}";
        emailController.text = data['email'] ?? '';
        phoneController.text = data['phoneNumber'] ?? '';
        addressController.text = data['address'] ?? '';
        gender.value = data['gender'] ?? AppStrings.male;
        latitude = data['latitude']?.toDouble();
        longitude = data['longitude']?.toDouble();
      }
    }

    isLoading.value = false;
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      imagePath.value = image.path;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatarImagePath', image.path);
    }
  }

  void updateProfile() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final names = nameController.text.trim().split(" ");
        final firstName = names.first;
        final lastName = names.length > 1 ? names.sublist(1).join(" ") : '';

        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'firstName': firstName,
          'lastName': lastName,
          'email': emailController.text,
          'phoneNumber': phoneController.text,
          'address': addressController.text,
          'gender': gender.value,
          'latitude': latitude,
          'longitude': longitude,
        });

        Get.snackbar(AppStrings.success, 'Profile updated successfully',
            backgroundColor: CustomColors.green1);
      }
      isLoading.value = false;
    }
  }
}
