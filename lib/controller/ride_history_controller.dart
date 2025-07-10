import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/utils/time_utilies.dart';
import 'package:synapseride/utils/utility.dart';
import 'package:url_launcher/url_launcher.dart';

class RideHistoryController extends GetxController {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  final deleteride = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (userId != null) {
      TimeUtils.updateAllUserRidesStatus(userId!);
    }
  }

  Widget buildJoinedUsers(String rideId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('rides')
          .doc(rideId)
          .collection('joinedUsers')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return UIUtils.circleloading();
        }

        if (snapshot.hasError) {
          return Text(
            AppStrings.error,
            style: AppTextStyles.labelGrey,
          );
        }

        final joinedUsers = snapshot.data?.docs ?? [];

        if (joinedUsers.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              AppStrings.noPassengersJoined,
              style: AppTextStyles.labelGrey,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
              child: Text(
                AppStrings.joinedPassengers,
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white70,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: joinedUsers.length,
              itemBuilder: (context, index) {
                final passengerData =
                    joinedUsers[index].data() as Map<String, dynamic>;
                final passengerId = joinedUsers[index].id;
                final passengerName =
                    passengerData['name'] as String? ?? 'Unknown';
                final passengerPhone =
                    passengerData['phoneNumber'] as String? ?? 'Not available';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    passengerName,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white.withOpacity(0.95),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    passengerPhone,
                                    style: AppTextStyles.labelGrey.copyWith(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green.withOpacity(0.3),
                                        Colors.lightGreen.withOpacity(0.2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.phone,
                                        color: CustomColors.green1, size: 20),
                                    onPressed: () =>
                                        makePhoneCall(passengerPhone),
                                    tooltip: 'Call',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.amber.withOpacity(0.3),
                                        Colors.orange.withOpacity(0.2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: Colors.amber.withOpacity(0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.chat,
                                        color: CustomColors.yellow1, size: 20),
                                    onPressed: () => openChat(
                                        rideId,
                                        passengerId,
                                        passengerName,
                                        passengerPhone),
                                    tooltip: 'Chat',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.red.withOpacity(0.3),
                                        Colors.deepOrange.withOpacity(0.2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.person_remove,
                                        color: CustomColors.error, size: 20),
                                    onPressed: () => confirmRemovePassenger(
                                        rideId, passengerId, passengerName),
                                    tooltip: 'Remove',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    if (phoneNumber == 'Not available' || phoneNumber.isEmpty) {
      Get.snackbar(
        AppStrings.error,
        'Phone number not available',
        backgroundColor: CustomColors.error,
      );
      return;
    }

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        'Failed to make phone call',
        backgroundColor: CustomColors.error,
      );
    }
  }

  Future<void> openChat(String rideId, String passengerId, String passengerName,
      String passengerPhone) async {
    try {
      Get.toNamed('/chat', arguments: {
        'rideId': rideId,
        'rideOwnerId': userId,
        'otherUserId': passengerId,
        'otherUserName': passengerName,
        'otherUserPhone': passengerPhone,
        'isRideOwner': true,
      });
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        'Failed to open chat',
        backgroundColor: CustomColors.error,
      );
    }
  }

  Future<void> confirmRemovePassenger(
      String rideId, String passengerId, String passengerName) async {
    final result = await showDialog<bool>(
      context: Get.context!,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          AppStrings.delete,
          style: AppTextStyles.headline4Light,
        ),
        content: Text(
          'Are you sure you want to remove $passengerName from this ride?',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              AppStrings.cancel,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: CustomColors.background),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              AppStrings.remove,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: CustomColors.error),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _removePassenger(rideId, passengerId);
    }
  }

  Future<void> _removePassenger(String rideId, String passengerId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('rides')
          .doc(rideId)
          .collection('joinedUsers')
          .doc(passengerId)
          .delete();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('rides')
          .doc(rideId)
          .update({'seats': FieldValue.increment(1)});

      Get.snackbar(
        AppStrings.success,
        'Passenger removed successfully',
        backgroundColor: CustomColors.green1,
      );
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        'Error removing passenger: $e',
        backgroundColor: CustomColors.error,
      );
    }
  }
}
