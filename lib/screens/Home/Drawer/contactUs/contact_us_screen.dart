import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/custom_appbar.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/controller/contact_us_controller.dart';
import 'package:synapseride/screens/Home/Drawer/contactUs/contactUs_UI_form.dart';
import 'package:synapseride/screens/Home/Drawer/contactUs/contact_us_listUI.dart';

class ContactUsScreen extends StatelessWidget {
  ContactUsScreen({super.key});

  final ContactUsController controller = Get.put(ContactUsController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: CustomAppBar(
          title: AppStrings.contactus,
          actions: [
            if (controller.hasComplaints.value)
              IconButton(
                icon: const Icon(Icons.history, color: CustomColors.yellow1),
                onPressed: () {
                  controller.viewAll.value = !controller.viewAll.value;
                },
              ),
          ],
        ),
        body: controller.viewAll.value
            ? ComplaintsListUI(
                onBackPressed: () {
                  controller.viewAll.value = false;
                },
                onDeleteComplaint: controller.deleteComplaint,
              )
            : ContactFormUI(
                nameController: controller.nameController,
                emailController: controller.emailController,
                phoneController: controller.phoneController,
                messageController: controller.messageController,
                nameError: controller.nameError.value,
                emailError: controller.emailError.value,
                phoneError: controller.phoneError.value,
                messageError: controller.messageError.value,
                isLoading: controller.isLoading.value,
                onSubmitForm: controller.submitForm,
              ),
      );
    });
  }
}
