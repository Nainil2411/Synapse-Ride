import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/complain_contact_common.dart';
import 'package:synapseride/common/custom_appbar.dart';
import 'package:synapseride/controller/contact_us_controller.dart';
import 'package:synapseride/screens/Home/Drawer/contactUs/contactUs_UI_form.dart';
import 'package:synapseride/screens/Home/Drawer/contactUs/contact_us_listUI.dart';

class ContactUsScreen extends StatelessWidget {
  ContactUsScreen({super.key});

  final ContactUsController controller = Get.put(ContactUsController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CustomAppBar(
          title: AppStrings.contactus,
        ),
        body: Column(
          children: [
            // Common Tab Bar
            CommonTabBar(
              tabController: controller.tabController,
              tabs: const [
                CommonTab(
                  icon: Icons.message_rounded,
                  text: 'Send Message',
                ),
                CommonTab(
                  icon: Icons.history_rounded,
                  text: 'History',
                ),
              ],
            ),
            // Tab Bar View
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey[900]!.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: TabBarView(
                  controller: controller.tabController,
                  children: const [
                    ContactUsForm(),
                    ContactUsHistory(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}