import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:synapseride/Routes/routes.dart';
import 'package:synapseride/common/app_images.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/common/elevated_button.dart';
import 'package:synapseride/common/textformfield.dart';
import 'package:synapseride/controller/signup_controller.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final SignupController controller = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 35),
                    Text(
                      AppStrings.signup,
                      style: GoogleFonts.inter(
                        textStyle: AppTextStyles.headline1.copyWith(
                          fontSize: 35,
                          color: CustomColors.background,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.createAccount,
                      style: GoogleFonts.inter(
                        textStyle: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 17,
                          color: CustomColors.background,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Obx(() => CustomTextFormField(
                          hintText: AppStrings.firstName,
                          errorText: controller.firstNameError.value,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          controller: controller.firstNameController,
                          borderColor: CustomColors.background,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              controller.firstNameError.value =
                                  AppStrings.enterfirstname;
                              return AppStrings.enterfirstname;
                            }
                            controller.firstNameError.value = '';
                            return null;
                          },
                        )),
                    const SizedBox(height: 15),
                    Obx(() => CustomTextFormField(
                          hintText: AppStrings.lastName,
                          errorText: controller.lastNameError.value,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          controller: controller.lastNameController,
                          borderColor: CustomColors.background,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              controller.lastNameError.value =
                                  AppStrings.enterlastname;
                              return AppStrings.enterlastname;
                            }
                            controller.lastNameError.value = '';
                            return null;
                          },
                        )),
                    const SizedBox(height: 15),
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
                              controller.emailError.value =
                                  AppStrings.enteremail;
                              return AppStrings.enteremail;
                            }
                            if (!controller.validateEmail(value)) {
                              controller.emailError.value =
                                  AppStrings.entervalidemail;
                              return AppStrings.entervalidemail;
                            }
                            controller.emailError.value = '';
                            return null;
                          },
                        )),
                    const SizedBox(height: 15),
                    Obx(() => CustomTextFormField(
                          hintText: AppStrings.address,
                          errorText: controller.addressError.value,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          controller: controller.addressController,
                          borderColor: CustomColors.background,
                          readOnly: true,
                          onTap: () {
                            Get.toNamed(AppRoutes.locationPicker)
                                ?.then((result) {
                              if (result != null &&
                                  result is Map<String, dynamic>) {
                                controller.addressController.text =
                                    result['address'];
                                controller.latitude = result['latitude'];
                                controller.longitude = result['longitude'];
                                controller.addressError.value = '';
                              }
                            });
                          },
                          suffixIcon: Icon(Icons.location_on,
                              color: CustomColors.background),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              controller.addressError.value =
                                  AppStrings.address;
                              return AppStrings.selectAddress;
                            }
                            controller.addressError.value = '';
                            return null;
                          },
                        )),
                    const SizedBox(height: 15),
                    CustomTextFormField(
                      controller: controller.dobController,
                      hintText: AppStrings.enterDOB,
                      showBorders: true,
                      borderColor: CustomColors.background,
                      errorText: '',
                      onChanged: (value) {},
                      obscureText: false,
                      readOnly: true,
                      onTap: () {
                        controller.selectDate(context);
                      },
                      suffixIcon: Icon(Icons.calendar_today,
                          color: CustomColors.background),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: CustomColors.background, width: 1.0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, top: 8.0),
                            child: Text(
                              AppStrings.selectGender,
                              style: AppTextStyles.labelGrey.copyWith(
                                color: CustomColors.textSecondary,
                              ),
                            ),
                          ),
                          Obx(() => Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile<String>(
                                      title: Text(
                                        AppStrings.male,
                                        style:
                                            AppTextStyles.bodyMedium.copyWith(
                                          color: CustomColors.background,
                                        ),
                                      ),
                                      value: AppStrings.male,
                                      groupValue:
                                          controller.selectedGender.value,
                                      activeColor: CustomColors.yellow1,
                                      onChanged: (value) {
                                        controller.selectedGender.value =
                                            value!;
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile<String>(
                                      title: Text(
                                        AppStrings.female,
                                        style:
                                            AppTextStyles.bodyMedium.copyWith(
                                          color: CustomColors.background,
                                        ),
                                      ),
                                      value: AppStrings.female,
                                      groupValue:
                                          controller.selectedGender.value,
                                      activeColor: CustomColors.yellow1,
                                      onChanged: (value) {
                                        controller.selectedGender.value =
                                            value!;
                                      },
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Obx(
                      () => Stack(
                        children: [
                          IntlPhoneField(
                            controller: controller.phoneController,
                            validator: (phone) {
                              if (phone == null || phone.number.isEmpty) {
                                controller.phoneError.value =
                                    'Phone number is required';
                                return 'Phone number is required';
                              }
                              if (phone.number.length < 10) {
                                controller.phoneError.value =
                                    'Please enter a valid phone number';
                                return 'Please enter a valid phone number';
                              }
                              controller.phoneError.value = '';
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: AppStrings.phoneNumberrequire,
                              hintStyle:
                                  TextStyle(color: CustomColors.textSecondary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: CustomColors.error,
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: controller.phoneError.value.isNotEmpty
                                      ? CustomColors.error
                                      : CustomColors.background,
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: controller.phoneError.value.isNotEmpty
                                      ? CustomColors.error
                                      : CustomColors.background,
                                  width: 1.0,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: CustomColors.error,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            initialCountryCode: 'IN',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            dropdownTextStyle: TextStyle(
                              color: Colors.white,
                            ),
                            flagsButtonMargin: EdgeInsets.only(right: 12.0),
                            onChanged: (phone) {
                              if (phone.number.length < 10) {
                                controller.phoneError.value =
                                    'Please enter a valid phone number';
                              } else {
                                controller.phoneError.value = '';
                              }
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(15),
                            ],
                          ),
                          Positioned(
                            left: 100,
                            top: 10,
                            bottom: 30,
                            child: Container(
                              width: 1.5,
                              color: CustomColors.background,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
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
                            controller.validatePassword(value);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              controller.passwordError.value =
                                  AppStrings.enterPassword;
                              return AppStrings.enterPassword;
                            }
                            if (!controller.validatePassword(value)) {
                              return AppStrings.passwordRequirements;
                            }
                            return null;
                          },
                        )),
                    const SizedBox(height: 30),
                    Obx(() => CustomElevatedButton(
                          label: AppStrings.signup,
                          isLoading: controller.isLoading.value,
                          onPressed: controller.handleSignup,
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
                    const SizedBox(height: 35),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.alreadyHaveAccount,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: CustomColors.background,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.offAllNamed(AppRoutes.login);
                          },
                          child: Text(
                            AppStrings.login,
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
        ],
      ),
    );
  }
}
