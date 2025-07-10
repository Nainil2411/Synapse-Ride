import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synapseride/Routes/routes.dart';
import 'package:synapseride/common/app_images.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/common/elevated_button.dart';
import 'package:synapseride/common/textformfield.dart';
import 'package:synapseride/controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.signInToAccount,
                    style: GoogleFonts.inter(
                      textStyle: AppTextStyles.headline1.copyWith(
                        fontSize: 35,
                        color: CustomColors.background,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.enterEmailPassword,
                    style: GoogleFonts.inter(
                      textStyle: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: CustomColors.background,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(() => CustomTextFormField(
                        hintText: AppStrings.email,
                        errorText: controller.emailError.value,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        controller: controller.emailController,
                        borderColor: CustomColors.background,
                        onChanged: (value) {
                          controller.emailError.value =
                              controller.validateEmail(value)
                                  ? ''
                                  : AppStrings.enteremail;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.enteremail;
                          }
                          if (!controller.validateEmail(value)) {
                            return AppStrings.entervalidemail;
                          }
                          return null;
                        },
                      )),
                  const SizedBox(height: 16),
                  Obx(() => CustomTextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        hintText: AppStrings.password,
                        errorText: controller.passwordError.value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscurePassword.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: CustomColors.background,
                          ),
                          onPressed: () {
                            controller.obscurePassword.value =
                                !controller.obscurePassword.value;
                          },
                        ),
                        obscureText: controller.obscurePassword.value,
                        controller: controller.passwordController,
                        borderColor: CustomColors.background,
                        onChanged: (value) {
                          controller.passwordError.value =
                              controller.validatePassword(value)
                                  ? ''
                                  : controller.passwordError.value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.enterPassword;
                          }
                          if (!controller.validatePassword(value)) {
                            return controller.passwordError.value;
                          }
                          return null;
                        },
                      )),
                  const SizedBox(height: 16),
                  Obx(() => controller.message.value.isNotEmpty
                      ? Column(
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              controller.message.value,
                              style: AppTextStyles.errorText,
                            ),
                          ],
                        )
                      : const SizedBox.shrink()),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Get.offNamed(AppRoutes.forgetpassword),
                      child: Text('Forgot Password?',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: CustomColors.yellow1)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(() => CustomElevatedButton(
                        isLoading: controller.isLoading.value,
                        label: AppStrings.login,
                        onPressed: controller.handleLogin,
                        fullWidth: true,
                        borderRadius: 14,
                      )),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(
                          child: Divider(color: CustomColors.textSecondary)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          AppStrings.or,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: CustomColors.background,
                          ),
                        ),
                      ),
                      const Expanded(
                          child: Divider(color: CustomColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: Image.asset(AppImages.googleIcon, height: 24),
                      label: Text(
                        AppStrings.continueWithGoogle,
                        style: AppTextStyles.buttonText.copyWith(
                          color: CustomColors.background,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: CustomColors.background,
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: CustomColors.background),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.dontHaveAccount,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: CustomColors.background,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.emailController.clear();
                          controller.passwordController.clear();
                          Get.offAllNamed(AppRoutes.signup);
                        },
                        child: Text(
                          AppStrings.signup,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: CustomColors.yellow1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Obx(() => controller.isLoading.value
            ? const ModalBarrier(
                dismissible: false,
              )
            : const SizedBox.shrink()),
      ]),
    );
  }
}
