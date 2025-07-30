import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:synapseride/Routes/routes.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/utils/time_utilies.dart';
import 'package:synapseride/utils/utility.dart';

class EditRideController extends GetxController {
  final TextEditingController addressController = TextEditingController();
  var selectedTime = TimeOfDay.now().obs;
  var selectedVehicle = 'car'.obs;
  var selectedSeats = 0.obs;
  var isLoading = false.obs;
  var addressError = ''.obs;
  var latitude = RxnDouble();
  var longitude = RxnDouble();

  String? rideId;
  Map<String, dynamic>? rideData;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      rideId = args['rideId'];
      rideData = args['rideData'];
      _populateFieldsWithExistingData();
    }
  }

  void _populateFieldsWithExistingData() {
    if (rideData != null) {
      addressController.text = rideData!['address'] ?? '';

      if (rideData!['destinationLocation'] != null) {
        final destLocation = rideData!['destinationLocation'];
        latitude.value = destLocation['latitude']?.toDouble();
        longitude.value = destLocation['longitude']?.toDouble();
      } else {
        latitude.value = rideData!['latitude']?.toDouble();
        longitude.value = rideData!['longitude']?.toDouble();
      }

      selectedTime.value = parseTimeString(rideData!['leavingTime'] ?? '');
      selectedVehicle.value = rideData!['vehicle'] ?? 'car';
      selectedSeats.value = rideData!['seats'] ?? 0;
    }
  }

  @override
  void onClose() {
    addressController.dispose();
    super.onClose();
  }

  TimeOfDay parseTimeString(String timeString) {
    try {
      final parts = timeString.split(' ');
      if (parts.length < 2) return const TimeOfDay(hour: 12, minute: 0);

      final timeParts = parts[0].split(':');
      if (timeParts.length < 2) return const TimeOfDay(hour: 12, minute: 0);

      int hour = int.tryParse(timeParts[0]) ?? 12;
      final minute = int.tryParse(timeParts[1]) ?? 0;
      final period = parts[1].toUpperCase();

      if (period == 'PM' && hour < 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return const TimeOfDay(hour: 12, minute: 0);
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await UIUtils.showTimePickerDialog(
      context: context,
      initialTime: selectedTime.value,
    );

    if (pickedTime != null) {
      if (!TimeUtils.isValidTimeOfDay(pickedTime, isEditing: true)) {
        final validationMessage = TimeUtils.getTimeValidationMessage(pickedTime, isEditing: true);
        Get.snackbar(
          AppStrings.error,
          validationMessage ?? 'Please select a valid time',
          backgroundColor: CustomColors.error,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      selectedTime.value = pickedTime;
    }
  }

  void showSeatSelectionBottomSheet() async {
    final maxSeats = selectedVehicle.value == 'car' ? 7 : 1;
    final result = await UIUtils.showSeatSelectionBottomSheet(
      context: Get.context!,
      vehicleType: selectedVehicle.value,
      initialSeats: selectedSeats.value,
      maxSeats: maxSeats,
    );
    if (result != null) {
      selectedSeats.value = result;
    }
  }

  bool validateRideDetails() {
    if (addressController.text.trim().isEmpty) {
      Get.snackbar(AppStrings.error, AppStrings.enterAddress,
          backgroundColor: CustomColors.error);
      return false;
    }
    if (selectedSeats.value <= 0) {
      Get.snackbar(AppStrings.error, 'Please select the number of available seats',
          backgroundColor: CustomColors.error);
      return false;
    }
    if (!TimeUtils.isValidTimeOfDay(selectedTime.value, isEditing: true)) {
      final validationMessage = TimeUtils.getTimeValidationMessage(selectedTime.value, isEditing: true);
      Get.snackbar(
        AppStrings.error,
        validationMessage ?? 'Please select a valid time',
        backgroundColor: CustomColors.error,
        duration: const Duration(seconds: 4),
      );
      return false;
    }

    return true;
  }

  Future<void> getRoutePointsAndUpdateRide() async {
    if (latitude.value == null || longitude.value == null) {
      Get.snackbar(AppStrings.error, 'Destination location is missing',
          backgroundColor: CustomColors.error);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || rideId == null) return;

    try {
      final currentLocation = rideData?['starting location'];
      if (currentLocation == null) throw Exception('Starting location not found');

      final response = await http.get(Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${currentLocation['longitude']},${currentLocation['latitude']};${longitude.value},${latitude.value}?overview=full&geometries=geojson',
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];
        List<Map<String, double>> routeData = coordinates
            .map<Map<String, double>>((coord) => {
          'latitude': coord[1],
          'longitude': coord[0],
        })
            .toList();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('rides')
            .doc(rideId)
            .update({
          'address': addressController.text.trim(),
          'leavingTime': UIUtils.formatTimeIn12HourFormat(selectedTime.value),
          'vehicle': selectedVehicle.value,
          'seats': selectedSeats.value,
          'destinationLocation': {
            'latitude': latitude.value,
            'longitude': longitude.value,
          },
          'routePoints': routeData,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        UIUtils.showSuccessDialog(
          context: Get.context!,
          title: AppStrings.success,
          message: AppStrings.rideUpdated,
          onComplete: () {
            Get.offAllNamed(AppRoutes.home);
          },
        );
      } else {
        throw Exception('Failed to fetch route');
      }
    } catch (e) {
      UIUtils.showAlertDialog(
        context: Get.context!,
        title: AppStrings.error,
        message: '${AppStrings.failedToUpdate}: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveChanges() async {
    if (!validateRideDetails()) {
      return;
    }

    isLoading.value = true;

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');
      final updateData = {
        'address': addressController.text.trim(),
        'leavingTime': UIUtils.formatTimeIn12HourFormat(selectedTime.value),
        'vehicle': selectedVehicle.value,
        'seats': selectedSeats.value,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (latitude.value != null && longitude.value != null) {
        updateData['destinationLocation'] = {
          'latitude': latitude.value,
          'longitude': longitude.value,
        };
      }

      if (latitude.value != null && longitude.value != null) {
        await getRoutePointsAndUpdateRide();
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('rides')
            .doc(rideId)
            .update(updateData);

        UIUtils.showSuccessDialog(
          context: Get.context!,
          title: AppStrings.success,
          message: AppStrings.rideUpdated,
          onComplete: () {
            Get.offAllNamed(AppRoutes.home);
          },
        );
      }
    } catch (e) {
      UIUtils.showAlertDialog(
        context: Get.context!,
        title: AppStrings.error,
        message: '${AppStrings.failedToUpdate}: $e',
      );
    } finally {
      if (isLoading.value) {
        isLoading.value = false;
      }
    }
  }

  bool get canSaveChanges {
    return addressController.text.trim().isNotEmpty &&
        selectedSeats.value > 0 &&
        TimeUtils.isValidTimeOfDay(selectedTime.value, isEditing: true) &&
        !isLoading.value;
  }

  String? getTimeValidationMessage() {
    return TimeUtils.getTimeValidationMessage(selectedTime.value, isEditing: true);
  }
}
