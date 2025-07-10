import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/utils/time_utilies.dart';
import 'package:url_launcher/url_launcher.dart';

class JoiningRideController extends GetxController {
  bool isLoading = false;
  List<Map<String, dynamic>> rides = [];
  Set<int> expandedItems = {};
  Set<String> joinedRides = {};
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool hasJoinedAnyRide = false;

  @override
  void onInit() {
    fetchRides();
    super.onInit();
  }

  Future<void> fetchRides() async {
    isLoading = true;
    update();

    try {
      final User? currentUser = auth.currentUser;
      final String currentUserId = currentUser?.uid ?? '';
      Set<String> alreadyJoinedRides = {};
      final usersSnapshot =
      await FirebaseFirestore.instance.collection('users').get();

      List<Map<String, dynamic>> allRides = [];

      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        final userData = userDoc.data();
        final ridesSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('rides')
            .get();

        for (var rideDoc in ridesSnapshot.docs) {
          final rideData = rideDoc.data();
          final leavingTime = rideData['leavingTime'] as String?;
          String rideStatus = rideData['status'] as String? ?? 'inactive';

          if (leavingTime != null && rideStatus == 'active') {
            if (TimeUtils.shouldRideBeInactive(leavingTime)) {
              await TimeUtils.updateRideStatusIfNeeded(userId, rideDoc.id, rideData);
              rideStatus = 'inactive';
            }
          }

          if (rideStatus != 'active') {
            continue;
          }

          bool isJoined = false;

          if (currentUserId.isNotEmpty) {
            final joinedUserDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('rides')
                .doc(rideDoc.id)
                .collection('joinedUsers')
                .doc(currentUserId)
                .get();

            isJoined = joinedUserDoc.exists;
            if (isJoined) {
              alreadyJoinedRides.add(rideDoc.id);
              hasJoinedAnyRide = true;
            }
          }

          allRides.add({
            'rideId': rideDoc.id,
            'userId': userId,
            'userName': rideData['name'] ??
                '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}',
            'phoneNumber': rideData['phoneNumber'] ?? userData['phoneNumber'],
            'address': rideData['address'] ?? userData['address'],
            'leavingTime': rideData['leavingTime'] ?? '',
            'vehicle': rideData['vehicle'] ?? 'car',
            'seats': rideData['seats'] ?? 1,
            'status': rideStatus,
            'createdAt': rideData['createdAt'] ?? Timestamp.now(),
            'hasJoined': isJoined,
          });
        }
      }

      allRides.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp;
        final bTime = b['createdAt'] as Timestamp;
        return bTime.compareTo(aTime);
      });

      rides = allRides;
      joinedRides = alreadyJoinedRides;
    } catch (e) {
      Get.snackbar(AppStrings.error, AppStrings.errorLoadingRides,
          backgroundColor: CustomColors.error);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(launchUri);
    } catch (e) {
      Get.snackbar(AppStrings.error, 'Could not launch dialer: $e',
          backgroundColor: CustomColors.error);
    }
  }

  Future<void> joinRide(Map<String, dynamic> ride) async {
    final User? currentUser = auth.currentUser;
    if (currentUser == null) {
      Get.snackbar('Required', AppStrings.loginRequired,
          backgroundColor: CustomColors.error);
      return;
    }

    final leavingTime = ride['leavingTime'] as String?;
    if (leavingTime != null && TimeUtils.shouldRideBeInactive(leavingTime)) {
      Get.snackbar(AppStrings.error, 'This ride is no longer available (time has passed)',
          backgroundColor: CustomColors.error);
      fetchRides();
      return;
    }

    isLoading = true;
    update();

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final userData = userDoc.data();
      final String currentUserName =
          '${userData?['firstName'] ?? ''} ${userData?['lastName'] ?? ''}';
      final String currentUserPhoneNumber = userData?['phoneNumber'] ?? '';

      await FirebaseFirestore.instance
          .collection('users')
          .doc(ride['userId'])
          .collection('rides')
          .doc(ride['rideId'])
          .collection('joinedUsers')
          .doc(currentUser.uid)
          .set({
        'name': currentUserName,
        'phoneNumber': currentUserPhoneNumber,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      if (ride['seats'] > 0) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(ride['userId'])
            .collection('rides')
            .doc(ride['rideId'])
            .update({'seats': FieldValue.increment(-1)});

        joinedRides.add(ride['rideId']);
        hasJoinedAnyRide = true;

        final index = rides.indexWhere((r) => r['rideId'] == ride['rideId']);
        if (index != -1) {
          final updatedRide = Map<String, dynamic>.from(rides[index]);
          updatedRide['seats'] = (updatedRide['seats'] as int) - 1;
          updatedRide['hasJoined'] = true;
          rides[index] = updatedRide;
        }

        isLoading = false;
        update();
        _navigateBackWithResult();
      } else {
        Get.snackbar(AppStrings.error, AppStrings.noSeatsAvailable,
            backgroundColor: CustomColors.error);
      }
    } catch (e) {
      Get.snackbar(AppStrings.error, AppStrings.errorJoiningRide,
          backgroundColor: CustomColors.error);
    } finally {
      if (isLoading) {
        isLoading = false;
        update();
      }
    }
  }

  void _navigateBackWithResult() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      Get.back(result: true);
    });
  }

  Future<void> showJoinConfirmationDialog(Map<String, dynamic> ride) async {
    final leavingTime = ride['leavingTime'] as String?;
    if (leavingTime != null && TimeUtils.shouldRideBeInactive(leavingTime)) {
      Get.snackbar(AppStrings.error, 'This ride is no longer available (time has passed)',
          backgroundColor: CustomColors.error);
      fetchRides();
      return;
    }

    return showDialog<void>(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppStrings.joinRide),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    '${AppStrings.rideJoinConfirmation} ${ride['userName']}\'s ride?'),
                const SizedBox(height: 8),
                Text('${AppStrings.leavingTime}: ${ride['leavingTime']}'),
                const SizedBox(height: 4),
                Text('${AppStrings.dropOff}: ${ride['address'] ?? AppStrings.noAddressProvided}'),
                const SizedBox(height: 8),
                Text('${AppStrings.availableSeats}: ${ride['seats']}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: Text(AppStrings.cancel),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: CustomColors.textPrimary,
                backgroundColor: CustomColors.yellow1,
              ),
              child: Text('Yes, ${AppStrings.joinRide}'),
              onPressed: () {
                Get.back(result: true);
                joinRide(ride);
                Get.back(result: true);
              },
            ),
          ],
        );
      },
    );
  }
}
