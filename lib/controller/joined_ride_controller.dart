import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/utils/utility.dart';
import 'package:url_launcher/url_launcher.dart';

class JoinedRideController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;

  var isLoading = true.obs;
  var joinedRide = Rxn<Map<String, dynamic>>();
  var rideOwnerId = ''.obs;
  var rideId = ''.obs;
  var currentUserId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    final user = auth.currentUser;
    if (user != null) {
      currentUserId.value = user.uid;
      fetchJoinedRide();
    } else {
      isLoading.value = false;
    }
  }

  Future<void> fetchJoinedRide() async {
    isLoading.value = true;
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        final ridesSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('rides')
            .get();

        for (var rideDoc in ridesSnapshot.docs) {
          final joinedUserDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('rides')
              .doc(rideDoc.id)
              .collection('joinedUsers')
              .doc(currentUserId.value)
              .get();

          if (joinedUserDoc.exists) {
            final rideData = rideDoc.data();
            final userDocData = await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();
            final userData = userDocData.data() ?? {};

            final combinedData = {
              ...rideData,
              'rideId': rideDoc.id,
              'userId': userId,
              'userName': rideData['name'] ??
                  '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}',
              'phoneNumber': rideData['phoneNumber'] ?? userData['phoneNumber'],
              'joinedAt': joinedUserDoc.data()?['joinedAt'],
            };

            joinedRide.value = combinedData;
            rideOwnerId.value = userId;
            rideId.value = rideDoc.id;
            isLoading.value = false;
            return;
          }
        }
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load joined ride',
          backgroundColor: CustomColors.error);
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      Get.snackbar('Error', 'Failed to make phone call');
    }
  }

  Future<void> openChat() async {
    if (rideOwnerId.value.isEmpty || rideId.value.isEmpty) {
      Get.snackbar('Error', 'Ride data not available');
      return;
    }

    try {
      final rideOwnerData = await FirebaseFirestore.instance
          .collection('users')
          .doc(rideOwnerId.value)
          .get();

      final ownerData = rideOwnerData.data() ?? {};
      final ownerName =
          '${ownerData['firstName'] ?? ''} ${ownerData['lastName'] ?? ''}'
              .trim();
      final ownerPhone = joinedRide.value?['phoneNumber'] ?? '';

      Get.toNamed('/chat', arguments: {
        'rideId': rideId.value,
        'rideOwnerId': rideOwnerId.value,
        'otherUserId': rideOwnerId.value,
        'otherUserName': ownerName.isNotEmpty ? ownerName : 'Ride Owner',
        'otherUserPhone': ownerPhone,
        'isRideOwner': false,
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to open chat');
    }
  }

  Future<void> leaveRide() async {
    if (rideOwnerId.value.isEmpty || rideId.value.isEmpty) {
      Get.snackbar('Error', 'Ride data not available');
      return;
    }
    isLoading.value = true;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(rideOwnerId.value)
          .collection('rides')
          .doc(rideId.value)
          .collection('joinedUsers')
          .doc(currentUserId.value)
          .delete();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(rideOwnerId.value)
          .collection('rides')
          .doc(rideId.value)
          .update({'seats': FieldValue.increment(1)});

      Get.back(result: true);
      Get.snackbar('Success', 'You have left the ride',
          backgroundColor: CustomColors.green1);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to leave the ride',
          backgroundColor: CustomColors.error);
    }
  }

  Future<void> showLeaveConfirmationDialog() async {
    final userName = joinedRide.value?['userName'] ?? 'this';
    final confirmed = await UIUtils.showConfirmationDialog(
      context: Get.context!,
      title: AppStrings.leaveRide,
      message: 'Are you sure you want to leave $userName\'s ride?',
      additionalMessage: AppStrings.seatWillBeAvailable,
      cancelText: AppStrings.cancel,
      confirmText: AppStrings.yesLeaveRide,
      cancelColor: CustomColors.textSecondary,
      confirmColor: CustomColors.error,
    );

    if (confirmed) {
      await leaveRide();
    }
  }
}
