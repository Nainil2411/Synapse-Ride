import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_appbar.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/controller/request_ride_controller.dart';
import 'package:synapseride/utils/utility.dart';

class RequestRideScreen extends StatelessWidget {
  RequestRideScreen({super.key});

  final RequestRideController controller = Get.put(RequestRideController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Request a Ride',
        onBackPressed: () => Get.back(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Personal Information'),
                  const SizedBox(height: 16),
                  _buildReadOnlyTextField(
                    controller: controller.nameController,
                    label: 'Your Name',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  _buildReadOnlyTextField(
                    controller: controller.phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Trip Details'),
                  const SizedBox(height: 16),
                  _buildLocationField(
                    controller: controller.fromAddressController,
                    label: 'Pickup Location',
                    icon: Icons.my_location,
                    onTap: () => controller.selectPickupLocation(),
                  ),
                  const SizedBox(height: 16),
                  _buildLocationField(
                    controller: controller.toAddressController,
                    label: 'Destination',
                    icon: Icons.location_on,
                    onTap: () => controller.selectDestinationLocation(),
                  ),
                  const SizedBox(height: 16),
                  _buildTimeSelector(),
                  const SizedBox(height: 16),
                  _buildSeatsSelector(),
                  const SizedBox(height: 16),
                  _buildUrgencySelector(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Additional Notes (Optional)'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: controller.notesController,
                    label: 'Any special requirements or notes',
                    icon: Icons.note,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSubmitButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: CustomColors.green1.withOpacity(0.3),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black.withOpacity(0.9),
                CustomColors.green1.withOpacity(0.1),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.labelLarge.copyWith(
        color: CustomColors.background,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomColors.green1.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.labelMedium.copyWith(
            color: Colors.white,
          ),
          prefixIcon: Icon(icon, color: Colors.white),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildReadOnlyTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomColors.green1.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        style: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white.withOpacity(0.7),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.labelMedium.copyWith(
            color: Colors.white.withOpacity(0.6),
          ),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CustomColors.green1.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            maxLines: 2,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              hintText: 'Tap to select $label',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.5),
              ),
              labelStyle: AppTextStyles.labelMedium.copyWith(
                color: Colors.white,
              ),
              prefixIcon: Icon(icon, color: Colors.white),
              suffixIcon: Icon(
                Icons.arrow_forward_ios,
                color: CustomColors.green1.withOpacity(0.6),
                size: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Obx(() {
      return GestureDetector(
        onTap: () => controller.selectTime(Get.context!),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CustomColors.green1.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time, color: CustomColors.background),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferred Time',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: CustomColors.background.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    UIUtils.formatTimeIn12HourFormat(
                        controller.selectedTime.value),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios,
                  color: CustomColors.green1.withOpacity(0.6), size: 16),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSeatsSelector() {
    return Obx(() {
      return GestureDetector(
        onTap: controller.handleSeatSelection,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CustomColors.green1.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.airline_seat_recline_normal,
                  color: CustomColors.background),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seats Needed',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: CustomColors.background.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${controller.selectedSeats.value} ${controller.selectedSeats.value == 1 ? 'seat' : 'seats'}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios,
                  color: CustomColors.green1.withOpacity(0.6), size: 16),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildUrgencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Urgency Level',
          style: AppTextStyles.labelMedium.copyWith(
            color: CustomColors.background.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildUrgencyOption('normal', 'Normal', Icons.schedule),
            ),
            const SizedBox(width: 12),
            Expanded(
              child:
                  _buildUrgencyOption('urgent', 'Urgent', Icons.priority_high),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUrgencyOption(String value, String label, IconData icon) {
    return Obx(() {
      return GestureDetector(
        onTap: () => controller.selectedUrgency.value = value,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: controller.selectedUrgency.value == value
                ? CustomColors.green1.withOpacity(0.2)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: controller.selectedUrgency.value == value
                  ? CustomColors.green1
                  : CustomColors.green1.withOpacity(0.3),
              width: controller.selectedUrgency.value == value ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: controller.selectedUrgency.value == value
                    ? CustomColors.green1
                    : Colors.white.withOpacity(0.7),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: controller.selectedUrgency.value == value
                      ? CustomColors.green1
                      : Colors.white.withOpacity(0.7),
                  fontWeight: controller.selectedUrgency.value == value
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed:
              controller.isLoading.value ? null : controller.submitRideRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomColors.green1,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
          ),
          child: controller.isLoading.value
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Submitting...',
                      style: AppTextStyles.buttonText.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : Text(
                  'Submit Ride Request',
                  style: AppTextStyles.buttonText.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      );
    });
  }
}
