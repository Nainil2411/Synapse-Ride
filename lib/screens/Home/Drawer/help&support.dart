import 'package:flutter/material.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_appbar.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.helpandsupport,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "At SynapseRide, we are committed to providing a safe, seamless, and reliable carpooling experience for you all. Our support team is always here to help you with any issues you may encounter—whether it's regarding ride scheduling, account management, or general inquiries. We value your feedback and aim to resolve every concern promptly and efficiently. You can reach out to us directly through the app or via email, and we'll do our best to assist you at the earliest. Your satisfaction and trust matter most to us, and we're here to support you every step of the way.",
                style: AppTextStyles.bodyMediumwhite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}