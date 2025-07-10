import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/controller/complain_controller.dart';

class ComplainHistoryUI extends StatelessWidget {
  final ComplainController controller;

  const ComplainHistoryUI({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.complaints.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 70, color: CustomColors.grey700),
              const SizedBox(height: 16),
              Text(
                AppStrings.nocomplain,
                style: AppTextStyles.headline4
                    .copyWith(color: CustomColors.grey400),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: controller.complaints.length,
        itemBuilder: (context, index) {
          final complaint = controller.complaints[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        complaint.type,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: CustomColors.background,
                        ),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.delete, color: CustomColors.error),
                        onPressed: () => controller.deleteComplaint(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    complaint.description,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: CustomColors.background),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${complaint.date.day}/${complaint.date.month}/${complaint.date.year} at ${complaint.date.hour}:${complaint.date.minute.toString().padLeft(2, '0')}',
                    style: AppTextStyles.labelGrey.copyWith(
                      color: CustomColors.grey400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
