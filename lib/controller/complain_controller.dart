import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synapseride/Model/complain_model.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/custom_color.dart';

class ComplainController extends GetxController {
  final List<String> complaintTypes = [
    'Vehicle not clean',
    'User was late',
    'Over Speeding',
    'Rude behavior',
    'Wrong destination',
    'Other',
  ];

  var selectedComplaint = 'Vehicle not clean'.obs;
  final TextEditingController complaintController = TextEditingController();
  var complaints = <Complaint>[].obs;
  var showHistory = false.obs;
  var isLoading = false.obs;

  static const String _complaintsKey = 'complaints_list';

  @override
  void onInit() {
    super.onInit();
    _loadComplaints();
  }

  @override
  void onClose() {
    complaintController.dispose();
    super.onClose();
  }

  Future<void> _loadComplaints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final complaintsJson = prefs.getStringList(_complaintsKey);

      if (complaintsJson != null) {
        complaints.value = complaintsJson
            .map((json) => Complaint.fromJson(jsonDecode(json)))
            .toList();
      }
    } catch (e) {
      log('Error loading complaints: $e');
    }
  }

  Future<void> _saveComplaints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final complaintsJson = complaints
          .map((complaint) => jsonEncode(complaint.toJson()))
          .toList();

      await prefs.setStringList(_complaintsKey, complaintsJson);
    } catch (e) {
      log('Error saving complaints: $e');
    }
  }

  void submitComplaint() async {
    if (complaintController.text.trim().isEmpty) {
      Get.snackbar('Required', 'Please enter complaint details.',
          backgroundColor: CustomColors.error);
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));

    final newComplaint = Complaint(
      type: selectedComplaint.value,
      description: complaintController.text.trim(),
      date: DateTime.now(),
    );

    complaints.add(newComplaint);
    await _saveComplaints();

    complaintController.clear();
    isLoading.value = false;
    showHistory.value = true;

    Get.snackbar(AppStrings.success, 'Complaint submitted successfully.',
        backgroundColor: CustomColors.green1);
  }

  void deleteComplaint(int index) async {
    complaints.removeAt(index);
    await _saveComplaints();
  }

  void toggleHistoryView() {
    showHistory.value = !showHistory.value;
  }

  void updateComplaintType(String value) {
    selectedComplaint.value = value;
  }
}