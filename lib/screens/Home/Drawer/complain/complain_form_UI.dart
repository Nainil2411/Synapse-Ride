import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/common/elevated_button.dart';
import 'package:synapseride/controller/complain_controller.dart';

class ComplainFormUI extends StatelessWidget {
  final ComplainController controller;

  const ComplainFormUI({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Obx(() => DropdownButtonFormField<String>(
            dropdownColor: Colors.grey[900],
            value: controller.selectedComplaint.value,
            icon: const Icon(Icons.keyboard_arrow_down, color: CustomColors.background),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[900],
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: CustomColors.grey700),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            style: AppTextStyles.bodyMedium.copyWith(color: CustomColors.background),
            items: controller.complaintTypes
                .map((type) => DropdownMenuItem(
              value: type,
              child: Text(type),
            ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                controller.updateComplaintType(value);
              }
            },
          )),
          const SizedBox(height: 20),
          TextField(
            controller: controller.complaintController,
            maxLines: 4,
            style: AppTextStyles.bodyMedium.copyWith(color: CustomColors.background),
            decoration: InputDecoration(
              hintText: AppStrings.writecomplain,
              hintStyle: AppTextStyles.bodySmall.copyWith(color: CustomColors.grey400),
              filled: true,
              fillColor: Colors.grey[900],
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: CustomColors.grey700),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Obx(() => CustomElevatedButton(
            label: AppStrings.submit,
            onPressed: controller.submitComplaint,
            fullWidth: true,
            borderRadius: 12,
            isLoading: controller.isLoading.value,
          )),
        ],
      ),
    );
  }
}