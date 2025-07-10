import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/utils/time_utilies.dart';
import 'package:url_launcher/url_launcher.dart';

class AcceptedRidesController extends GetxController {
  bool isLoading = false;
  List<Map<String, dynamic>> acceptedRides = [];
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void onInit() {
    fetchAcceptedRides();
    super.onInit();
  }

  Future<void> fetchAcceptedRides() async {
    isLoading = true;
    update();

    try {
      final User? currentUser = auth.currentUser;
      if (currentUser == null) {
        isLoading = false;
        update();
        return;
      }

      final String currentUserId = currentUser.uid;
      final requestsSnapshot = await FirebaseFirestore.instance
          .collection('rideRequests')
          .where('acceptedBy', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'accepted')
          .orderBy('acceptedAt', descending: true)
          .get();

      List<Map<String, dynamic>> allAcceptedRides = [];

      for (var doc in requestsSnapshot.docs) {
        final requestData = doc.data();
        final preferredTime = requestData['preferredTime'] as String?;
        final currentStatus = requestData['status'] as String?;

        if (preferredTime != null &&
            currentStatus == 'accepted' &&
            TimeUtils.shouldRideBeInactive(preferredTime)) {
          await FirebaseFirestore.instance
              .collection('rideRequests')
              .doc(doc.id)
              .update({'status': 'completed'});
          continue;
        }

        allAcceptedRides.add({
          'requestId': doc.id,
          ...requestData,
        });
      }

      acceptedRides = allAcceptedRides;
    } catch (e) {
      Get.snackbar(AppStrings.error, 'Error loading accepted rides: $e',
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

  Future<void> markRideAsCompleted(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('rideRequests')
          .doc(requestId)
          .update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        AppStrings.success,
        'Ride marked as completed!',
        backgroundColor: CustomColors.green1,
      );
      acceptedRides.removeWhere((ride) => ride['requestId'] == requestId);
      update();
    } catch (e) {
      Get.snackbar(AppStrings.error, 'Error updating ride status: $e',
          backgroundColor: CustomColors.error);
    }
  }

  Future<void> cancelAcceptedRide(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('rideRequests')
          .doc(requestId)
          .update({
        'status': 'pending',
        'acceptedBy': null,
        'acceptorName': null,
        'acceptorPhone': null,
        'acceptedAt': null,
      });

      Get.snackbar(
        AppStrings.success,
        'Ride acceptance cancelled. The request is now available for others.',
        backgroundColor: CustomColors.green1,
        duration: const Duration(seconds: 4),
      );

      acceptedRides.removeWhere((ride) => ride['requestId'] == requestId);
      update();
    } catch (e) {
      Get.snackbar(AppStrings.error, 'Error cancelling ride: $e',
          backgroundColor: CustomColors.error);
    }
  }

  Future<void> showCompleteConfirmationDialog(
      String requestId, String requesterName) async {
    return showDialog<void>(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Complete Ride', style: TextStyle(color: Colors.white)),
          content: Text(
            'Mark the ride with $requesterName as completed?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: Text(AppStrings.cancel),
              onPressed: () => Get.back(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.green,
              ),
              child: Text('Complete'),
              onPressed: () {
                Get.back();
                markRideAsCompleted(requestId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showCancelConfirmationDialog(
      String requestId, String requesterName) async {
    return showDialog<void>(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title:
              Text('Cancel Acceptance', style: TextStyle(color: Colors.white)),
          content: Text(
            'Cancel your acceptance of $requesterName\'s ride request? This will make the request available for others to accept.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: Text('Keep'),
              onPressed: () => Get.back(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.orange,
              ),
              child: Text('Cancel Acceptance'),
              onPressed: () {
                Get.back();
                cancelAcceptedRide(requestId);
              },
            ),
          ],
        );
      },
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  static Future<bool> hasAcceptedRides() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;

      final snapshot = await FirebaseFirestore.instance
          .collection('rideRequests')
          .where('acceptedBy', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'accepted')
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
