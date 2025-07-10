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

  final ForgotPasswordController controller = Get.find<ForgotPasswordController>();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.forgotPassword,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenSize.width * 0.05),
          child: Card(
            color: CustomColors.textPrimary,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.emailassosiated,
                      style: AppTextStyles.bodyMediumwhite,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: screenSize.width * 0.9,
                      child: CustomTextFormField(
                        controller: controller.emailController,
                        hintText: AppStrings.enterYourEmail,
                        errorText: '',
                        validator: controller.validateEmail,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(() {
                      if (controller.message.value.isNotEmpty) {
                        return Column(
                          children: [
                            Text(
                              controller.message.value,
                              style: controller.message.value.contains(AppStrings.success)
                                  ? AppTextStyles.bodyMedium
                                  : AppTextStyles.errorText,
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    SizedBox(
                      width: screenSize.width * 0.9,
                      height: 60.0,
                      child: Obx(() => CustomElevatedButton(
                        isLoading: controller.isLoading.value,
                        textColor: CustomColors.yellow1,
                        label: AppStrings.sendResetLink,
                        borderRadius: 10,
                        onPressed: controller.handleResetPassword,
                        backgroundColor: CustomColors.textPrimary,
                      )),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}