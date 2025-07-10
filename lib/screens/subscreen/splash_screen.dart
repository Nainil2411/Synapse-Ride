import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_images.dart';
import 'package:synapseride/controller/splash_controller.dart';

import '../../common/custom_color.dart';

class SplashScreen extends StatelessWidget {
   SplashScreen({super.key});

  final SplashController controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.yellow1,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppImages.preview, height: 300),
          ],
        ),
      ),
    );
  }
}
