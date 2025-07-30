import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/utils/time_utilies.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewRideRequestsController extends GetxController {
  bool isLoading = false;
  List<Map<String, dynamic>> rideRequests = [];
  Set<int> expandedItems = {};
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void onInit() {
    fetchRideRequests();
    super.onInit();
  }

  Future<void> fetchRideRequests() async {
    isLoading = true;
    update();

    try {
      final User? currentUser = auth.currentUser;
      final String currentUserId = currentUser?.uid ?? '';

      if (currentUserId.isEmpty) {
        Get.snackbar(AppStrings.error, 'Please login to view ride requests',
            backgroundColor: CustomColors.error);
        isLoading = false;
        update();
        return;
      }

      final requestsSnapshot = await FirebaseFirestore.instance
          .collection('rideRequests')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> allRequests = [];

      for (var doc in requestsSnapshot.docs) {
        final requestData = doc.data();
        final requesterId = requestData['requesterId'] as String;

        if (requesterId == currentUserId) {
          continue;
        }

        final preferredTime = requestData['preferredTime'] as String?;
        if (preferredTime != null && TimeUtils.shouldRideBeInactive(preferredTime)) {
          await FirebaseFirestore.instance
              .collection('rideRequests')
              .doc(doc.id)
              .update({'status': 'expired'});
          continue;
        }

        allRequests.add({
          'requestId': doc.id,
          ...requestData,
        });
      }

      rideRequests = allRequests;
    } catch (e) {
      Get.snackbar(AppStrings.error, 'Error loading ride requests: $e',
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

  Future<void> acceptRideRequest(Map<String, dynamic> request) async {
    final User? currentUser = auth.currentUser;
    if (currentUser == null) {
      Get.snackbar('Required', 'Please login to accept requests',
          backgroundColor: CustomColors.error);
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (!userDoc.exists) {
      Get.snackbar(AppStrings.error, 'User profile not found',
          backgroundColor: CustomColors.error);
      return;
    }

    final userData = userDoc.data() as Map<String, dynamic>;
    final acceptorName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
    final acceptorPhone = userData['phoneNumber'] ?? '';

    try {
      await FirebaseFirestore.instance
          .collection('rideRequests')
          .doc(request['requestId'])
          .update({
        'status': 'accepted',
        'acceptedBy': currentUser.uid,
        'acceptorName': acceptorName,
        'acceptorPhone': acceptorPhone,
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        AppStrings.success,
        'Ride request accepted! You can now contact the requester.',
        backgroundColor: CustomColors.green1,
        duration: const Duration(seconds: 4),
      );

      fetchRideRequests();
    } catch (e) {
      Get.snackbar(AppStrings.error, 'Error accepting request: $e',
          backgroundColor: CustomColors.error);
    }
  }

  Future<void> showAcceptConfirmationDialog(Map<String, dynamic> request) async {
    return showDialog<void>(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Accept Ride Request',
            style: TextStyle(color: CustomColors.background),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Do you want to accept ${request['requesterName']}\'s ride request?',
                  style: TextStyle(color: CustomColors.background),
                ),
                const SizedBox(height: 12),
                Text('From: ${request['fromAddress']}',
                    style: TextStyle(color: CustomColors.background)),
                Text('To: ${request['toAddress']}',
                    style: TextStyle(color: CustomColors.background)),
                Text('Time: ${request['preferredTime']}',
                    style: TextStyle(color: CustomColors.background)),
                Text('Seats: ${request['seatsNeeded']}',
                    style: TextStyle(color: CustomColors.background)),
                const SizedBox(height: 8),
                Text(
                  'By accepting, you agree to provide the ride and can contact the requester.',
                  style: TextStyle(color: CustomColors.yellow1, fontSize: 12),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: CustomColors.textSecondary),
              child: Text(AppStrings.cancel),
              onPressed: () => Get.back(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: CustomColors.textPrimary,
                backgroundColor: CustomColors.yellow1,
              ),
              child: Text('Accept Request'),
              onPressed: () {
                Get.back(result: true);
                Get.back(result: true);
                acceptRideRequest(request);
              },
            ),
          ],
        );
      },
    );
  }
}
