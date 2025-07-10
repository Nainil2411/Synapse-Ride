import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/Routes/routes.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/utils/utility.dart';

class RequestRideController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController fromAddressController = TextEditingController();
  final TextEditingController toAddressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  var selectedTime = TimeOfDay.now().obs;
  var selectedSeats = 1.obs;
  var isLoading = false.obs;
  var selectedUrgency = 'normal'.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  @override
  void onClose() {
    nameController.dispose();
    fromAddressController.dispose();
    toAddressController.dispose();
    phoneController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          final firstName = data['firstName'] ?? '';
          final lastName = data['lastName'] ?? '';
          nameController.text = '$firstName $lastName';
          phoneController.text = data['phoneNumber'] ?? '';
          fromAddressController.text = data['address'] ?? '';
        }
      }
    } catch (e) {
      Get.snackbar(AppStrings.error, 'Error loading user data: $e',
          backgroundColor: CustomColors.error);
    }
  }

  Future<void> selectPickupLocation() async {
    try {
      final selectedLocation = await Get.toNamed(
        AppRoutes.locationPicker,
        arguments: {
          'title': 'Select Pickup Location',
          'currentLocation': fromAddressController.text.trim(),
          'type': 'pickup'
        },
      );

      if (selectedLocation != null &&
          selectedLocation is Map<String, dynamic>) {
        fromAddressController.text = selectedLocation['address'] ?? '';
      }
    } catch (e) {
      Get.snackbar(AppStrings.error, 'Error selecting pickup location: $e',
          backgroundColor: CustomColors.error);
    }
  }

  Future<void> selectDestinationLocation() async {
    try {
      final selectedLocation = await Get.toNamed(
        AppRoutes.locationPicker,
        arguments: {
          'title': 'Select Destination',
          'currentLocation': toAddressController.text.trim(),
          'type': 'destination'
        },
      );

      if (selectedLocation != null &&
          selectedLocation is Map<String, dynamic>) {
        toAddressController.text = selectedLocation['address'] ?? '';
      }
    } catch (e) {
      Get.snackbar(AppStrings.error, 'Error selecting destination: $e',
          backgroundColor: CustomColors.error);
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await UIUtils.showTimePickerDialog(
      context: context,
      initialTime: selectedTime.value,
    );

    if (pickedTime != null && pickedTime != selectedTime.value) {
      if (!isValidRideTime(pickedTime)) {
        Get.snackbar(
          AppStrings.error,
          'Please select a time that is at least 30 minutes from now',
          backgroundColor: CustomColors.error,
          duration: const Duration(seconds: 4),
        );
        return;
      }
      selectedTime.value = pickedTime;
    }
  }

  bool isValidRideTime(TimeOfDay selectedTime) {
    final now = DateTime.now();
    final selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (selectedDateTime.isBefore(now)) {
      final tomorrowDateTime = selectedDateTime.add(const Duration(days: 1));
      return tomorrowDateTime.isAfter(now.add(const Duration(minutes: 30)));
    }

    return selectedDateTime.isAfter(now.add(const Duration(minutes: 30)));
  }

  bool validateRequestDetails() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(AppStrings.error, 'Please enter your name',
          backgroundColor: CustomColors.error);
      return false;
    }

    if (fromAddressController.text.trim().isEmpty) {
      Get.snackbar(AppStrings.error, 'Please select pickup location',
          backgroundColor: CustomColors.error);
      return false;
    }

    if (toAddressController.text.trim().isEmpty) {
      Get.snackbar(AppStrings.error, 'Please select destination',
          backgroundColor: CustomColors.error);
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      Get.snackbar(AppStrings.error, 'Please enter your phone number',
          backgroundColor: CustomColors.error);
      return false;
    }

    if (selectedSeats.value <= 0) {
      Get.snackbar(AppStrings.error, 'Please select number of seats needed',
          backgroundColor: CustomColors.error);
      return false;
    }

    if (!isValidRideTime(selectedTime.value)) {
      Get.snackbar(
        AppStrings.error,
        'Please select a valid time at least 30 minutes from now',
        backgroundColor: CustomColors.error,
      );
      return false;
    }

    return true;
  }

  Future<void> submitRideRequest() async {
    if (!validateRequestDetails()) return;

    isLoading.value = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar(AppStrings.error, 'User not authenticated',
            backgroundColor: CustomColors.error);
        return;
      }

      await FirebaseFirestore.instance.collection('rideRequests').add({
        'requesterId': user.uid,
        'requesterName': nameController.text.trim(),
        'requesterPhone': phoneController.text.trim(),
        'fromAddress': fromAddressController.text.trim(),
        'toAddress': toAddressController.text.trim(),
        'preferredTime': UIUtils.formatTimeIn12HourFormat(selectedTime.value),
        'seatsNeeded': selectedSeats.value,
        'urgency': selectedUrgency.value,
        'notes': notesController.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'acceptedBy': null,
        'acceptedAt': null,
      });

      UIUtils.showSuccessDialog(
        context: Get.context!,
        title: AppStrings.success,
        message: 'Ride request submitted successfully!',
        onComplete: () {
          Get.back(result: true);
        },
      );
    } catch (e) {
      Get.snackbar(AppStrings.error, 'Error submitting request: $e',
          backgroundColor: CustomColors.error);
    } finally {
      isLoading.value = false;
    }
  }

  void handleSeatSelection() async {
    final seats = await UIUtils.showSeatSelectionBottomSheet(
      context: Get.context!,
      vehicleType: 'request',
      initialSeats: selectedSeats.value,
      maxSeats: 7,
    );
    if (seats != null) {
      selectedSeats.value = seats;
    }
  }
}
