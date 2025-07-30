import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/utils/time_utilies.dart';
import 'package:synapseride/utils/utility.dart';

class CreateRideController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isAddressEditable = false;

  var destinationPosition = Rxn<LatLng>();
  var isRouteLoading = false.obs;
  var routePoints = <LatLng>[].obs;
  var currentPosition = Rxn<LatLng>();
  var selectedTime = TimeOfDay.now().obs;
  var selectedVehicle = 'car'.obs;
  var selectedSeats = 0.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    loadUserData();
    getCurrentLocation();
    super.onInit();
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    selectedTime.value = TimeOfDay.now();
    selectedVehicle.value = 'car';
    selectedSeats.value = 0;
    isLoading.value = false;
    isRouteLoading.value = false;
    routePoints.clear();
    super.onClose();
  }

  bool isValidRideTime(TimeOfDay selectedTime) {
    return TimeUtils.isValidTimeOfDay(selectedTime, isEditing: false);
  }

  String getFormattedTimeString(TimeOfDay time) {
    return UIUtils.formatTimeIn12HourFormat(time);
  }

  bool wouldRideBeInactive(TimeOfDay selectedTime) {
    final timeString = getFormattedTimeString(selectedTime);
    return TimeUtils.shouldRideBeInactive(timeString);
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await UIUtils.showTimePickerDialog(
      context: context,
      initialTime: selectedTime.value,
    );

    if (pickedTime != null && pickedTime != selectedTime.value) {
      if (!isValidRideTime(pickedTime)) {
        final validationMessage = TimeUtils.getTimeValidationMessage(pickedTime, isEditing: false);
        Get.snackbar(
          AppStrings.error,
          validationMessage ?? 'Please select a valid time',
          backgroundColor: CustomColors.error,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      selectedTime.value = pickedTime;
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      final location = Location();
      LocationData locationData = await location.getLocation();

      currentPosition.value = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );
    } catch (e) {
      Get.snackbar(AppStrings.error, AppStrings.errorGettingLocation,
          backgroundColor: CustomColors.error);
    }
  }

  bool validateRideDetails() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(AppStrings.error, 'Please enter your name',
          backgroundColor: CustomColors.error);
      return false;
    }

    if (addressController.text.trim().isEmpty) {
      Get.snackbar(AppStrings.error, 'Please enter the destination address',
          backgroundColor: CustomColors.error);
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      Get.snackbar(AppStrings.error, 'Please enter your phone number',
          backgroundColor: CustomColors.error);
      return false;
    }

    if (selectedSeats.value <= 0) {
      Get.snackbar(AppStrings.error, 'Please select the number of available seats',
          backgroundColor: CustomColors.error);
      return false;
    }

    if (!isValidRideTime(selectedTime.value)) {
      final validationMessage = TimeUtils.getTimeValidationMessage(selectedTime.value, isEditing: false);
      Get.snackbar(
        AppStrings.error,
        validationMessage ?? 'Please select a valid time',
        backgroundColor: CustomColors.error,
        duration: const Duration(seconds: 5),
      );
      return false;
    }

    if (currentPosition.value == null) {
      Get.snackbar(AppStrings.error, 'Unable to get your current location',
          backgroundColor: CustomColors.error);
      return false;
    }

    if (destinationPosition.value == null) {
      Get.snackbar(AppStrings.error, 'Please set a destination location',
          backgroundColor: CustomColors.error);
      return false;
    }

    return true;
  }

  Future<void> getRoutePoints() async {
    if (!validateRideDetails()) {
      return;
    }

    final timeString = getFormattedTimeString(selectedTime.value);
    if (TimeUtils.shouldRideBeInactive(timeString)) {
      Get.snackbar(
        AppStrings.error,
        'Cannot create ride: The selected leaving time would make this ride inactive immediately. Please select a future time.',
        backgroundColor: CustomColors.error,
        duration: const Duration(seconds: 5),
      );
      return;
    }

    isRouteLoading.value = true;

    try {
      final response = await http.get(Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/${currentPosition.value!.longitude},${currentPosition.value!.latitude};${destinationPosition.value!.longitude},${destinationPosition.value!.latitude}?overview=full&geometries=geojson'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> coordinates =
        data['routes'][0]['geometry']['coordinates'];
        routePoints.value =
            coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();

        await saveRideDetailsWithRoute();
      } else {
        isRouteLoading.value = false;
        Get.snackbar(AppStrings.error, AppStrings.errorGettingRoute,
            backgroundColor: CustomColors.error);
      }
    } catch (e) {
      isRouteLoading.value = false;
      Get.snackbar(AppStrings.error, AppStrings.errorProcessingRoute,
          backgroundColor: CustomColors.error);
    }
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
          addressController.text = data['address'] ?? '';
          phoneController.text = data['phoneNumber'] ?? '';

          if (data['location'] != null) {
            destinationPosition.value = LatLng(
              data['location'].latitude,
              data['location'].longitude,
            );
          }
        }
      }
    } catch (e) {
      Get.snackbar(AppStrings.error, AppStrings.errorLoadingUserData,
          backgroundColor: CustomColors.error);
    }
  }

  Future<void> saveRideDetailsWithRoute() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar(AppStrings.error, 'User not authenticated',
            backgroundColor: CustomColors.error);
        isRouteLoading.value = false;
        return;
      }

      final timeString = getFormattedTimeString(selectedTime.value);
      if (TimeUtils.shouldRideBeInactive(timeString)) {
        Get.snackbar(
          AppStrings.error,
          'Cannot create ride: The leaving time has passed. Please select a future time.',
          backgroundColor: CustomColors.error,
          duration: const Duration(seconds: 5),
        );
        isRouteLoading.value = false;
        return;
      }

      List<Map<String, double>> routeData = routePoints.value
          .map((point) => {
        'latitude': point.latitude,
        'longitude': point.longitude,
      }).toList();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('rides')
          .add({
        'name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'leavingTime': timeString,
        'vehicle': selectedVehicle.value,
        'seats': selectedSeats.value,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'starting location': {
          'latitude': currentPosition.value!.latitude,
          'longitude': currentPosition.value!.longitude,
        },
        'destinationLocation': {
          'latitude': destinationPosition.value!.latitude,
          'longitude': destinationPosition.value!.longitude,
        },
        'routePoints': routeData,
      });

      UIUtils.showSuccessDialog(
        context: Get.context!,
        title: AppStrings.success,
        message: AppStrings.rideCreated,
        onComplete: () {
          Get.back(result: true);
        },
      );

      isRouteLoading.value = false;
      isLoading.value = false;
    } catch (e) {
      isRouteLoading.value = false;
      isLoading.value = false;
      Get.snackbar(AppStrings.error, '${AppStrings.errorSavingRide}: $e',
          backgroundColor: CustomColors.error);
    }
  }

  void handleVehicleSelection(String value) async {
    selectedVehicle.value = value;
    int maxSeats = value == 'car' ? 7 : 1;
    if (value == 'car' || value == 'bike') {
      final seats = await UIUtils.showSeatSelectionBottomSheet(
        context: Get.context!,
        vehicleType: value,
        initialSeats: selectedSeats.value,
        maxSeats: maxSeats,
      );
      if (seats != null) {
        selectedSeats.value = seats;
      }
    }
  }

  bool get canCreateRide {
    return nameController.text.trim().isNotEmpty &&
        addressController.text.trim().isNotEmpty &&
        phoneController.text.trim().isNotEmpty &&
        selectedSeats.value > 0 &&
        currentPosition.value != null &&
        destinationPosition.value != null &&
        isValidRideTime(selectedTime.value) &&
        !isRouteLoading.value &&
        !isLoading.value;
  }

  String? getTimeValidationMessage() {
    return TimeUtils.getTimeValidationMessage(selectedTime.value, isEditing: false);
  }
}
