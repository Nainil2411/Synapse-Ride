import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/custom_appbar.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/controller/complain_controller.dart';
import 'package:synapseride/screens/Home/Drawer/complain/complain_form_UI.dart';
import 'package:synapseride/screens/Home/Drawer/complain/complain_history_UI.dart';

class ComplainScreen extends StatelessWidget {
  ComplainScreen({super.key});

  final ComplainController controller = Get.put(ComplainController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() => CustomAppBar(
              title: controller.showHistory.value
                  ? 'Complaint History'
                  : 'Complain',
              actions: [
                Obx(() {
                  if (controller.complaints.isNotEmpty) {
                    return IconButton(
                      icon: Icon(
                        controller.showHistory.value
                            ? Icons.add_circle_outline
                            : Icons.history,
                        color: CustomColors.yellow1,
                      ),
                      onPressed: controller.toggleHistoryView,
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            )),
      ),
      body: Obx(() => controller.showHistory.value
          ? ComplainHistoryUI(controller: controller)
          : ComplainFormUI(controller: controller)),
    );
  }
}
