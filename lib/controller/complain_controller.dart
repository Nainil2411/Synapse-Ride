import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synapseride/Model/complain_model.dart';
import 'package:synapseride/common/custom_color.dart';

class ComplainController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;

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
  var isLoading = false.obs;
  var isDeleting = false.obs;

  static const String _complaintsKey = 'complaints_list';

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    _loadComplaints();
  }

  @override
  void onClose() {
    tabController.dispose();
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

        // Sort complaints by date (newest first)
        complaints.sort((a, b) => b.date.compareTo(a.date));
      }
    } catch (e) {
      log('Error loading complaints: $e');
      Get.snackbar(
        'Error',
        'Failed to load complaint history',
        backgroundColor: CustomColors.error.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
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
      Get.snackbar(
        'Error',
        'Failed to save complaint',
        backgroundColor: CustomColors.error.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void submitComplaint() async {
    if (complaintController.text.trim().isEmpty) {
      Get.snackbar(
        'Incomplete Form',
        'Please describe your complaint in detail',
        backgroundColor: CustomColors.error.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: Icon(
          Icons.warning_rounded,
          color: Colors.white,
        ),
      );
      return;
    }

    if (complaintController.text.trim().length < 10) {
      Get.snackbar(
        'Too Short',
        'Please provide more details about your complaint',
        backgroundColor: CustomColors.error.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: Icon(
          Icons.info_rounded,
          color: Colors.white,
        ),
      );
      return;
    }

    isLoading.value = true;

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      final newComplaint = Complaint(
        type: selectedComplaint.value,
        description: complaintController.text.trim(),
        date: DateTime.now(),
      );

      complaints.insert(0, newComplaint); // Add to beginning for newest first
      await _saveComplaints();

      // Clear form
      complaintController.clear();
      selectedComplaint.value = complaintTypes.first;

      // Show success message
      Get.snackbar(
        'Success!',
        'Your complaint has been submitted successfully',
        backgroundColor: CustomColors.green1.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        icon: Icon(
          Icons.check_circle_rounded,
          color: Colors.white,
        ),
      );

      // Switch to history tab with animation
      tabController.animateTo(1);

    } catch (e) {
      log('Error submitting complaint: $e');
      Get.snackbar(
        'Submission Failed',
        'Something went wrong. Please try again.',
        backgroundColor: CustomColors.error.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: Icon(
          Icons.error_rounded,
          color: Colors.white,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void deleteComplaint(int index) async {
    if (index < 0 || index >= complaints.length) return;

    isDeleting.value = true;

    try {
      // Simulate deletion delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      final deletedComplaint = complaints[index];
      complaints.removeAt(index);
      await _saveComplaints();

      Get.snackbar(
        'Deleted',
        'Complaint removed successfully',
        backgroundColor: CustomColors.grey700.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        mainButton: TextButton(
          onPressed: () => _undoDelete(deletedComplaint, index),
          child: Text(
            'UNDO',
            style: TextStyle(
              color: CustomColors.yellow1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        icon: Icon(
          Icons.delete_rounded,
          color: Colors.white,
        ),
      );

    } catch (e) {
      log('Error deleting complaint: $e');
      Get.snackbar(
        'Delete Failed',
        'Could not delete complaint. Please try again.',
        backgroundColor: CustomColors.error.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isDeleting.value = false;
    }
  }

  void _undoDelete(Complaint complaint, int originalIndex) async {
    try {
      // Insert back at original position or at the end if index is out of bounds
      final insertIndex = originalIndex <= complaints.length
          ? originalIndex
          : complaints.length;

      complaints.insert(insertIndex, complaint);
      await _saveComplaints();

      Get.snackbar(
        'Restored',
        'Complaint has been restored',
        backgroundColor: CustomColors.green1.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: Icon(
          Icons.restore_rounded,
          color: Colors.white,
        ),
      );
    } catch (e) {
      log('Error restoring complaint: $e');
    }
  }

  void updateComplaintType(String value) {
    selectedComplaint.value = value;
  }

  void switchToHistoryTab() {
    tabController.animateTo(1);
  }

  void switchToFormTab() {
    tabController.animateTo(0);
  }

  // Helper method to get complaint statistics
  Map<String, int> getComplaintStats() {
    final stats = <String, int>{};
    for (final complaint in complaints) {
      stats[complaint.type] = (stats[complaint.type] ?? 0) + 1;
    }
    return stats;
  }

  // Helper method to get recent complaints (last 7 days)
  List<Complaint> getRecentComplaints() {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return complaints.where((complaint) =>
        complaint.date.isAfter(sevenDaysAgo)).toList();
  }

  // Helper method to check if there are any pending complaints
  bool get hasPendingComplaints => complaints.isNotEmpty;

  // Helper method to get the most common complaint type
  String? get mostCommonComplaintType {
    if (complaints.isEmpty) return null;

    final stats = getComplaintStats();
    String? mostCommon;
    int maxCount = 0;

    stats.forEach((type, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = type;
      }
    });

    return mostCommon;
  }
}