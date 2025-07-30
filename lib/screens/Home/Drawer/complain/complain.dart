import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/complain_contact_common.dart';
import 'package:synapseride/common/custom_appbar.dart';
import 'package:synapseride/controller/complain_controller.dart';
import 'package:synapseride/screens/Home/Drawer/complain/complain_form_UI.dart';
import 'package:synapseride/screens/Home/Drawer/complain/complain_history_UI.dart';

class ComplainScreen extends StatelessWidget {
  ComplainScreen({super.key});

  final ComplainController controller = Get.put(ComplainController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Complain Center',
        ),
        body: Column(
          children: [
            // Common Tab Bar
            CommonTabBar(
              tabController: controller.tabController,
              tabs: const [
                CommonTab(
                  icon: Icons.edit_note_rounded,
                  text: 'New Complaint',
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
                    ComplainForm(),
                    ComplainHistory(),
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