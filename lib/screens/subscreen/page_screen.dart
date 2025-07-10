import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/Routes/routes.dart';
import 'package:synapseride/common/app_images.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/common/elevated_button.dart';

class PageScreen extends StatelessWidget {
  const PageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Image.asset(
              AppImages.welcome,
              fit: BoxFit.fitWidth,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.47,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    AppStrings.welcome,
                    style: AppTextStyles.headline1.copyWith(
                      fontSize: 45,
                      color: CustomColors.background,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Join us to share rides",
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: CustomColors.background,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 80),
                  CustomElevatedButton(
                    label: AppStrings.login,
                    onPressed: () {
                      Get.toNamed(AppRoutes.login);
                    },
                    fullWidth: true,
                    backgroundColor: CustomColors.yellow1,
                    textColor: CustomColors.textPrimary,
                  ),
                  const SizedBox(height: 20),
                  CustomElevatedButton(
                    label: AppStrings.signup,
                    onPressed: () {
                      Get.toNamed(AppRoutes.signup);
                    },
                    fullWidth: true,
                    backgroundColor: CustomColors.textPrimary,
                    textColor: CustomColors.background,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
