import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/complain_contact_common.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/controller/complain_controller.dart';

class ComplainForm extends StatelessWidget {
  const ComplainForm({super.key});

  @override
  Widget build(BuildContext context) {
    final ComplainController controller = Get.find<ComplainController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header using common component
          const CommonHeader(
            icon: Icons.support_agent_rounded,
            title: 'We\'re here to help',
            subtitle: 'Tell us about your experience',
          ),
          const SizedBox(height: 32),

          // Complaint Type Selection
          Text(
            'Issue Category',
            style: AppTextStyles.labelLarge.copyWith(
              color: CustomColors.background,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Dropdown (keeping as is since it's specific to complaints)
          _buildDropdown(controller),
          const SizedBox(height: 32),

          // Description using common component
          CommonFormField(
            controller: controller.complaintController,
            label: 'Tell us more',
            hint: 'Describe your experience in detail...',
            errorObs: RxBool(false), // Connect to validation if needed
            errorText: 'Please enter your complaint details',
            maxLines: 5,
            showIcon: false,
          ),
          const SizedBox(height: 40),

          // Submit Button using common component
          CommonSubmitButton(
            isLoading: controller.isLoading,
            onPressed: controller.submitComplaint,
            text: 'Submit Complaint',
            loadingText: 'Submitting...',
            icon: Icons.send_rounded,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDropdown(ComplainController controller) {
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CustomColors.grey700.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField2<String>(
        value: controller.selectedComplaint.value,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: CustomColors.yellow1.withOpacity(0.5),
              width: 2,
            ),
          ),
        ),
        style: AppTextStyles.bodyMedium.copyWith(
          color: CustomColors.background,
          fontWeight: FontWeight.w500,
        ),
        items: controller.complaintTypes
            .map((type) => DropdownMenuItem(
          value: type,
          child: Row(
            children: [
              _getIssueIcon(type),
              const SizedBox(width: 12),
              Text(type),
            ],
          ),
        ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            controller.updateComplaintType(value);
          }
        },
        buttonStyleData: ButtonStyleData(
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        iconStyleData: IconStyleData(
          icon: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: CustomColors.yellow1.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: CustomColors.yellow1,
              size: 25,
            ),
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[900],
            border: Border.all(
              color: CustomColors.grey700.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          offset: const Offset(0, -5),
          isOverButton: false,
        ),
        menuItemStyleData: MenuItemStyleData(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return CustomColors.yellow1.withOpacity(0.1);
              }
              if (states.contains(MaterialState.pressed)) {
                return CustomColors.yellow1.withOpacity(0.2);
              }
              return null;
            },
          ),
        ),
      ),
    ));
  }

  Widget _getIssueIcon(String type) {
    IconData iconData;
    Color iconColor;
    switch (type) {
      case 'Vehicle not clean':
        iconData = Icons.cleaning_services_rounded;
        iconColor = Colors.blue;
        break;
      case 'User was late':
        iconData = Icons.access_time_rounded;
        iconColor = Colors.orange;
        break;
      case 'Over Speeding':
        iconData = Icons.speed_rounded;
        iconColor = Colors.red;
        break;
      case 'Rude behavior':
        iconData = Icons.sentiment_dissatisfied_rounded;
        iconColor = Colors.purple;
        break;
      case 'Wrong destination':
        iconData = Icons.wrong_location_rounded;
        iconColor = Colors.green;
        break;
      default:
        iconData = Icons.help_outline_rounded;
        iconColor = CustomColors.grey400;
    }

    return Icon(
      iconData,
      color: iconColor,
      size: 20,
    );
  }
}