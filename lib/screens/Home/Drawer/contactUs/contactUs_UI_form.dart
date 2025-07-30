import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/complain_contact_common.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/controller/contact_us_controller.dart';

class ContactUsForm extends StatelessWidget {
  const ContactUsForm({super.key});


  @override
  Widget build(BuildContext context) {
    final ContactUsController controller = Get.find<ContactUsController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header using common component
          const CommonHeader(
            icon: Icons.support_agent_rounded,
            title: 'Get in Touch',
            subtitle: 'We\'d love to hear from you',
          ),
          const SizedBox(height: 32),

          // Contact Information
          _buildContactInfo(),
          const SizedBox(height: 32),

          // Form Section
          Text(
            'Send us a Message',
            style: AppTextStyles.labelLarge.copyWith(
              color: CustomColors.background,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // Name Field using common component
          CommonFormField(
            controller: controller.nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline_rounded,
            errorObs: controller.nameError,
            errorText: 'Please enter your name',
          ),
          const SizedBox(height: 20),

          // Email Field using common component
          CommonFormField(
            controller: controller.emailController,
            label: 'Email Address',
            hint: 'Enter your email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            errorObs: controller.emailError,
            errorText: 'Please enter a valid email',
          ),
          const SizedBox(height: 20),

          // Phone Field using common component
          Obx(() => CommonFormField(
            controller: controller.phoneController,
            label: 'Phone Number',
            hint: 'Enter your phone number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            errorObs: RxBool(controller.phoneError.value.isNotEmpty),
            errorText: controller.phoneError.value,
          )),
          const SizedBox(height: 20),

          // Message Field using common component
          CommonFormField(
            controller: controller.messageController,
            label: 'Message',
            hint: 'Tell us how we can help you...',
            errorObs: controller.messageError,
            errorText: 'Please enter your message',
            maxLines: 5,
            showIcon: false,
          ),
          const SizedBox(height: 40),

          // Submit Button using common component
          CommonSubmitButton(
            isLoading: controller.isLoading,
            onPressed: controller.submitForm,
            text: 'Send Message',
            loadingText: 'Sending...',
            icon: Icons.send_rounded,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CustomColors.grey700.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildContactItem(
            icon: Icons.location_on_outlined,
            title: 'Address',
            subtitle: AppStrings.universityAddress,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.phone_outlined,
            title: 'Phone',
            subtitle: AppStrings.callNumber,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: AppStrings.supportEmail,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: CustomColors.background,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: CustomColors.grey400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}