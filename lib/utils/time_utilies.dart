import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeUtils {
  static bool shouldRideBeInactive(String leavingTime) {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      DateTime leavingDateTime;
      if (leavingTime.contains('AM') || leavingTime.contains('PM')) {
        leavingDateTime = DateFormat('h:mm a').parse(leavingTime);
        leavingDateTime = DateTime(
          today.year,
          today.month,
          today.day,
          leavingDateTime.hour,
          leavingDateTime.minute,
        );
      } else {
        final timeParts = leavingTime.split(':');
        if (timeParts.length >= 2) {
          final hour = int.tryParse(timeParts[0]) ?? 0;
          final minute = int.tryParse(timeParts[1]) ?? 0;
          leavingDateTime =
              DateTime(today.year, today.month, today.day, hour, minute);
        } else {
          return false;
        }
      }

      final cutoffTime = leavingDateTime.add(const Duration(minutes: 30));

      return now.isAfter(cutoffTime);
    } catch (e) {
      return false;
    }
  }

  static Future<void> updateRideStatusIfNeeded(
      String userId, String rideId, Map<String, dynamic> rideData) async {
    try {
      final leavingTime = rideData['leavingTime'] as String?;
      final currentStatus = rideData['status'] as String?;

      if (leavingTime != null && currentStatus == 'active') {
        if (shouldRideBeInactive(leavingTime)) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('rides')
              .doc(rideId)
              .update({'status': 'inactive'});
        }
      }
    } catch (e) {
      log('Error updating ride status: $e');
    }
  }

  static Future<void> updateAllUserRidesStatus(String userId) async {
    try {
      final ridesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('rides')
          .where('status', isEqualTo: 'active')
          .get();

      final batch = FirebaseFirestore.instance.batch();

      for (final doc in ridesSnapshot.docs) {
        final rideData = doc.data();
        final leavingTime = rideData['leavingTime'] as String?;

        if (leavingTime != null && shouldRideBeInactive(leavingTime)) {
          batch.update(doc.reference, {'status': 'inactive'});
        }
      }

      await batch.commit();
    } catch (e) {
      log('Error batch updating rides: $e');
    }
  }

  static bool isValidRideTime(String timeString, {bool isEditing = false}) {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      DateTime leavingDateTime;

      if (timeString.contains('AM') || timeString.contains('PM')) {
        leavingDateTime = DateFormat('h:mm a').parse(timeString);
        leavingDateTime = DateTime(
          today.year,
          today.month,
          today.day,
          leavingDateTime.hour,
          leavingDateTime.minute,
        );
      } else {
        final timeParts = timeString.split(':');
        if (timeParts.length >= 2) {
          final hour = int.tryParse(timeParts[0]) ?? 0;
          final minute = int.tryParse(timeParts[1]) ?? 0;
          leavingDateTime =
              DateTime(today.year, today.month, today.day, hour, minute);
        } else {
          return false;
        }
      }

      if (isEditing) {
        return leavingDateTime.isAfter(now);
      }

      return leavingDateTime.isAfter(now.add(const Duration(minutes: 15)));
    } catch (e) {
      return false;
    }
  }

  static bool isValidTimeOfDay(TimeOfDay selectedTime,
      {bool isEditing = false}) {
    try {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      if (isEditing) {
        return selectedDateTime.isAfter(now);
      }

      return selectedDateTime.isAfter(now.add(const Duration(minutes: 15)));
    } catch (e) {
      return false;
    }
  }

  static String? getTimeValidationMessage(TimeOfDay selectedTime,
      {bool isEditing = false}) {
    final now = DateTime.now();
    final selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (selectedDateTime.isBefore(now)) {
      return 'Selected time has already passed';
    }

    if (!isEditing &&
        selectedDateTime.isBefore(now.add(const Duration(minutes: 15)))) {
      return 'Please select a time at least 15 minutes from now';
    }

    return null;
  }
}
