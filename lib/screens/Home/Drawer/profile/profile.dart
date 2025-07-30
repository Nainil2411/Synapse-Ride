import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/Routes/routes.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/custom_appbar.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/common/elevated_button.dart';
import 'package:synapseride/common/textformfield.dart';
import 'package:synapseride/controller/profile_controller.dart';
import 'package:synapseride/screens/Home/Drawer/profile/profile_radiobutton.dart';
import 'package:synapseride/utils/utility.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.textPrimary,
      appBar: CustomAppBar(
        title: AppStrings.editprofile,
      ),
      body: Obx(() => controller.isLoading.value
          ? UIUtils.circleloading()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              Obx(() => Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: CustomColors.accent,
                    backgroundImage: controller
                        .imagePath.value.isNotEmpty
                        ? FileImage(File(controller.imagePath.value))
                        : null,
                    child: controller.imagePath.value.isEmpty
                        ? const Icon(Icons.person,
                        size: 60, color: CustomColors.textPrimary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: CustomColors.textSecondary,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.camera_alt,
                            size: 15, color: CustomColors.background),
                        onPressed: () =>
                            controller.showImageSourceBottomSheet(
                                context, controller),
                      ),
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 16),
              CustomTextFormField(
                hintText: AppStrings.name,
                showTitle: true,
                title: 'Name',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                controller: controller.nameController,
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextFormField(
                showTitle: true,
                title: AppStrings.email,
                hintText: AppStrings.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                controller: controller.emailController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  if (!GetUtils.isEmail(value.trim())) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextFormField(
                showTitle: true,
                title: AppStrings.phoneNumber,
                hintText: AppStrings.phoneNumber,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                controller: controller.phoneController,
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Obx(() => GenderSelector(
                selectedGender: controller.gender.value,
                onChanged: (value) {
                  controller.gender.value = value!;
                },
              )),
              const SizedBox(height: 12),
              Obx(() => CustomTextFormField(
                showTitle: true,
                title: AppStrings.address,
                hintText: AppStrings.address,
                errorText: controller.addressError.value.isEmpty
                    ? null
                    : controller.addressError.value,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                controller: controller.addressController,
                readOnly: true,
                onTap: () {
                  Get.toNamed(AppRoutes.locationPicker)
                      ?.then((result) {
                    if (result != null) {
                      controller.addressController.text =
                      result['address'];
                      controller.latitude = result['latitude'];
                      controller.longitude = result['longitude'];
                      controller.addressError.value = '';
                    }
                  });
                },
                suffixIcon: Icon(Icons.location_on,
                    color: CustomColors.grey300),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    controller.addressError.value =
                        AppStrings.enterAddress;
                    return AppStrings.enterAddress;
                  }
                  controller.addressError.value = '';
                  return null;
                },
              )),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() => CustomElevatedButton(
                  label: AppStrings.change,
                  onPressed: controller.updateProfile,
                  isLoading: controller.isLoading.value,
                )),
              )
            ],
          ),
        ),
      )),
    );
  }
}