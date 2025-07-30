import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/controller/forget_password_controller.dart';
import '../../common/elevated_button.dart';
import '../../common/textformfield.dart';
import "../../common/app_string.dart";
import "../../common/custom_appbar.dart";
import "../../common/custom_color.dart";

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final ForgotPasswordController controller = Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.forgotPassword,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CustomColors.textPrimary,
              CustomColors.textPrimary.withOpacity(0.8),
              CustomColors.background,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.05),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Header Section with Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: CustomColors.yellow1.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_reset,
                    size: 80,
                    color: CustomColors.yellow1,
                  ),
                ),
                const SizedBox(height: 24),
                // Title and Description
                Text(
                  'Forgot Your Password?',
                  style: AppTextStyles.headline1.copyWith(
                    color: CustomColors.background,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'No worries! Enter your email address and we\'ll send you a reset link.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: CustomColors.background.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Main Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: CustomColors.textPrimary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        // Email Icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: CustomColors.yellow1.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.email_outlined,
                            size: 32,
                            color: CustomColors.yellow1,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Email Field
                        CustomTextFormField(
                          controller: controller.emailController,
                          hintText: AppStrings.enterYourEmail,
                          errorText: '',
                          validator: controller.validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          prefixIcon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 24),
                        // Message Display
                        Obx(() {
                          if (controller.message.value.isNotEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: controller.message.value.contains(AppStrings.success)
                                    ? CustomColors.green1.withOpacity(0.1)
                                    : CustomColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: controller.message.value.contains(AppStrings.success)
                                      ? CustomColors.green1
                                      : CustomColors.error,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    controller.message.value.contains(AppStrings.success)
                                        ? Icons.check_circle
                                        : Icons.error_outline,
                                    color: controller.message.value.contains(AppStrings.success)
                                        ? CustomColors.green1
                                        : CustomColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      controller.message.value,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: controller.message.value.contains(AppStrings.success)
                                            ? CustomColors.green1
                                            : CustomColors.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                        const SizedBox(height: 24),
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: Obx(() => CustomElevatedButton(
                            isLoading: controller.isLoading.value,
                            textColor: CustomColors.textPrimary,
                            label: AppStrings.sendResetLink,
                            borderRadius: 12,
                            onPressed: controller.handleResetPassword,
                            backgroundColor: CustomColors.yellow1,
                            fullWidth: true,
                          )),
                        ),
                        const SizedBox(height: 16),
                        // Back to Login Link
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            'Back to Login',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: CustomColors.yellow1,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}