import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/common/elevated_button.dart';
import 'package:synapseride/common/textformfield.dart';

class ContactFormUI extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController messageController;
  final bool nameError;
  final bool emailError;
  final String phoneError;
  final bool messageError;
  final bool isLoading;
  final void Function() onSubmitForm;

  const ContactFormUI({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.messageController,
    required this.nameError,
    required this.emailError,
    required this.phoneError,
    required this.messageError,
    required this.isLoading,
    required this.onSubmitForm,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              AppStrings.contactUsForSynapseRide,
              style: AppTextStyles.headline3.copyWith(
                color: CustomColors.background,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.address,
              style: AppTextStyles.headline4.copyWith(
                color: CustomColors.background,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.universityAddress,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: CustomColors.background),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.callNumber,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: CustomColors.background),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.supportEmail,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: CustomColors.background),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.sendMessage,
              style: AppTextStyles.headline3.copyWith(
                color: CustomColors.background,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CustomTextFormField(
              controller: nameController,
              hintText: AppStrings.enterYourName,
              showTitle: true,
              title: AppStrings.name,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              hasError: nameError,
              errorText: nameError ? AppStrings.enterYourNameError : null,
            ),
            const SizedBox(height: 10),
            CustomTextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              showTitle: true,
              title: AppStrings.email,
              hintText: AppStrings.enterYourEmail,
              textInputAction: TextInputAction.next,
              hasError: emailError,
              errorText: emailError ? AppStrings.enterValidEmailError : null,
            ),
            const SizedBox(height: 10),
            CustomTextFormField(
              controller: phoneController,
              showTitle: true,
              title: AppStrings.phoneNumber,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              hintText: AppStrings.phoneNumberrequire,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.phone,
              hasError: phoneError.isNotEmpty,
              errorText: phoneError,
            ),
            const SizedBox(height: 10),
            CustomTextFormField(
              controller: messageController,
              maxLines: 5,
              showTitle: true,
              title: AppStrings.message,
              hintText: AppStrings.enterYourIssueHere,
              textInputAction: TextInputAction.done,
              hasError: messageError,
              errorText: messageError ? AppStrings.enterYourMessageError : null,
            ),
            const SizedBox(height: 30),
            CustomElevatedButton(
              label: AppStrings.sendMessage,
              onPressed: onSubmitForm,
              isLoading: isLoading,
              fullWidth: true,
              borderRadius: 12,
            ),
          ],
        ),
      ),
    );
  }
}
