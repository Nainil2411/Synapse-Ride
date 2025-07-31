import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synapseride/Routes/routes.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/common/elevated_button.dart';
import 'package:synapseride/controller/custom_drawer_controller.dart';
import 'package:synapseride/controller/profile_controller.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({super.key});

  final CustomDrawerController controller = Get.put(CustomDrawerController());
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: CustomColors.textPrimary,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Stack(
              children: [
                FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: controller.getUserData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return UserAccountsDrawerHeader(
                        accountName: Text(
                          'Loading...',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: Colors.white),
                        ),
                        accountEmail: Text(
                          '',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: Colors.white),
                        ),
                        currentAccountPicture: Obx(() {
                          final imagePath = profileController.getProfileImage();
                          return CircleAvatar(
                            backgroundColor: CustomColors.yellow1,
                            backgroundImage: imagePath != null
                                ? FileImage(File(imagePath))
                                : null,
                            child: imagePath == null
                                ? Icon(Icons.person,
                                    color: CustomColors.textPrimary,
                                    size: 50)
                                : null,
                          );
                        }),
                        decoration: BoxDecoration(
                            color: CustomColors.textPrimary),
                      );
                    } else if (snapshot.hasError ||
                        !snapshot.hasData ||
                        !snapshot.data!.exists) {
                      return UserAccountsDrawerHeader(
                        accountName: Text(
                          'User',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: Colors.white),
                        ),
                        accountEmail: Text(
                          'user@email.com',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: Colors.white),
                        ),
                        currentAccountPicture: Obx(() {
                          final imagePath = profileController.getProfileImage();
                          return CircleAvatar(
                            backgroundColor: CustomColors.yellow1,
                            backgroundImage: imagePath != null
                                ? FileImage(File(imagePath))
                                : null,
                            child: imagePath == null
                                ? Icon(Icons.person,
                                    color: CustomColors.textPrimary,
                                    size: 50)
                                : null,
                          );
                        }),
                        decoration: BoxDecoration(
                            color: CustomColors.textPrimary),
                      );
                    } else {
                      final userData = snapshot.data!.data()!;
                      final name =
                          "${userData['firstName']} ${userData['lastName']}";
                      final email = userData['email'];

                      return UserAccountsDrawerHeader(
                        accountName: Text(
                          name,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: Colors.white),
                        ),
                        accountEmail: Text(
                          email,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: Colors.white),
                        ),
                        currentAccountPicture: Obx(() {
                          final imagePath = profileController.getProfileImage();
                          return CircleAvatar(
                            backgroundColor: CustomColors.yellow1,
                            backgroundImage: imagePath != null
                                ? FileImage(File(imagePath))
                                : null,
                            child: imagePath == null
                                ? Icon(Icons.person,
                                    color: CustomColors.textPrimary,
                                    size: 50)
                                : null,
                          );
                        }),
                        decoration: BoxDecoration(
                            color: CustomColors.textPrimary),
                      );
                    }
                  },
                ),
              ],
            ),
            _buildListTile(context, Icons.edit, AppStrings.editprofile, () {
              Get.toNamed(AppRoutes.profile);
            }),
            _buildListTile(context, Icons.history, AppStrings.rideHistory, () {
              Get.toNamed(AppRoutes.rideHistory);
            }),
            _buildListTile(context, Icons.upcoming, AppStrings.upcomingride,
                () {
              Get.toNamed(AppRoutes.joinedRide);
            }),
            _buildListTile(context, Icons.warning, AppStrings.complain, () {
              Get.toNamed(AppRoutes.complain);
            }),
            _buildListTile(context, Icons.support_agent, AppStrings.contactus,
                () {
              Get.toNamed(AppRoutes.contactus);
            }),
            _buildListTile(context, Icons.info, "Information Hub", () {
              Get.toNamed(AppRoutes.modernInfoHub);
            }),
            ListTile(
              leading:
                  Icon(Icons.logout, color: CustomColors.background),
              title: Text(
                AppStrings.logout,
                style: AppTextStyles.bodyMediumwhite,
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.grey[900],
                    title: Text(
                      AppStrings.logout,
                      style: AppTextStyles.headline4Light,
                    ),
                    content: Text(
                      AppStrings.logoutmessage,
                      style: AppTextStyles.bodyMedium.copyWith(color: CustomColors.background),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          AppStrings.cancel,
                          style: AppTextStyles.bodyMedium.copyWith(color: CustomColors.background),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setBool('isLoggedIn', false);
                          await FirebaseAuth.instance.signOut();
                          Get.back();
                          Get.offAllNamed(AppRoutes.login);
                        },
                        child: Text(
                          AppStrings.yes,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: CustomColors.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 180),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Obx(() => CustomElevatedButton(
                    backgroundColor: CustomColors.error,
                    borderRadius: 12,
                    isLoading: controller.isLoading.value,
                    label: AppStrings.deleteaccount,
                    textColor: CustomColors.background,
                    onPressed: () => controller.deleteAccount(context),
                  )),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: CustomColors.background),
      title: Text(
        title,
        style: AppTextStyles.bodyMediumwhite
      ),
      onTap: onTap,
    );
  }
}
