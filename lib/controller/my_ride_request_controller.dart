import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/utils/time_utilies.dart';
import 'package:url_launcher/url_launcher.dart';

class MyRideRequestsController extends GetxController {
  bool isLoading = false;
  List<Map<String, dynamic>> myRequests = [];
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void onInit() {
    fetchMyRequests();
    super.onInit();
  }

  Future<void> fetchMyRequests() async {
    isLoading = true;
    update();

    try {
      final User? currentUser = auth.currentUser;
      if (currentUser == null) return;

      final requestsSnapshot = await FirebaseFirestore.instance
          .collection('rideRequests')
          .where('requesterId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> allRequests = [];

      for (var doc in requestsSnapshot.docs) {
        final requestData = doc.data();
        final preferredTime = requestData['preferredTime'] as String?;
        final currentStatus = requestData['status'] as String?;

        if (preferredTime != null &&
            currentStatus == 'pending' &&
            TimeUtils.shouldRideBeInactive(preferredTime)) {
          await FirebaseFirestore.instance
              .collection('rideRequests')
              .doc(doc.id)
              .update({'status': 'expired'});
          requestData['status'] = 'expired';
        }

        allRequests.add({
          'requestId': doc.id,
          ...requestData,
        });
      }

      myRequests = allRequests;
    } catch (e) {
      Get.snackbar(AppStrings.error, 'Error loading your requests: $e',
          backgroundColor: CustomColors.error);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> deleteRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('rideRequests')
          .doc(requestId)
          .delete();

      Get.snackbar(
        AppStrings.success,
        'Ride request deleted successfully',
        backgroundColor: CustomColors.green1,
      );

      fetchMyRequests();
    } catch (e) {
      Get.snackbar(AppStrings.error, 'Error deleting request: $e',
          backgroundColor: CustomColors.error);
    }
  }

  Future<void> cancelRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('rideRequests')
          .doc(requestId)
          .update({'status': 'cancelled'});

      Get.snackbar(
        AppStrings.success,
        'Ride request cancelled',
        backgroundColor: CustomColors.green1,
      );

      fetchMyRequests();
    } catch (e) {
      Get.snackbar(AppStrings.error, 'Error cancelling request: $e',
          backgroundColor: CustomColors.error);
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

  Future<void> showDeleteConfirmationDialog(String requestId) async {
    return showDialog<void>(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Delete Request', style: TextStyle(color: Colors.white)),
          content: Text(
            'Are you sure you want to delete this ride request?',
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
                foregroundColor: Colors.white,
                backgroundColor: Colors.redAccent,
              ),
              child: Text('Delete'),
              onPressed: () {
                Get.back();
                deleteRequest(requestId);
              },
            ),
          ],
        );
      },
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.grey;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'expired':
        return 'Expired';
      default:
        return 'Unknown';
    }
  }
}
