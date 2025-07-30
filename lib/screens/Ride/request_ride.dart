import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_appbar.dart';
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPersonalInfoCard(),
            const SizedBox(height: 24),
            _buildTripDetailsCard(),
            const SizedBox(height: 24),
            _buildNotesCard(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // MARK: - Card Builders
  Widget _buildPersonalInfoCard() {
    return _buildCard(
      icon: Icons.person_outline,
      title: 'Personal Information',
      iconColor: const Color(0xFF6366F1),
      child: Column(
        children: [
          _buildModernTextField(
            controller: controller.nameController,
            label: 'Your Name',
            icon: Icons.person_outline,
            isReadOnly: true,
          ),
          const SizedBox(height: 16),
          _buildModernTextField(
            controller: controller.phoneController,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            isReadOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetailsCard() {
    return _buildCard(
      icon: Icons.route_outlined,
      title: 'Trip Details',
      iconColor: const Color(0xFF8B5CF6),
      child: Column(
        children: [
          _buildLocationField(
            controller: controller.fromAddressController,
            label: 'Pickup Location',
            icon: Icons.my_location_outlined,
            onTap: () => controller.selectPickupLocation(),
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 16),
          _buildLocationField(
            controller: controller.toAddressController,
            label: 'Destination',
            icon: Icons.location_on_outlined,
            onTap: () => controller.selectDestinationLocation(),
            color: const Color(0xFFEF4444),
          ),
          const SizedBox(height: 20),
          _buildTimeSelector(),
          const SizedBox(height: 16),
          _buildSeatsSelector(),
          const SizedBox(height: 20),
          _buildUrgencySelector(),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return _buildCard(
      icon: Icons.edit_note_outlined,
      title: 'Additional Notes',
      iconColor: const Color(0xFFF59E0B),
      child: _buildModernTextField(
        controller: controller.notesController,
        label: 'Any special requirements or notes',
        icon: Icons.note_outlined,
        maxLines: 3,
      ),
      trailing: _buildOptionalBadge(),
    );
  }

  // MARK: - Reusable Components
  Widget _buildCard({
    required IconData icon,
    required String title,
    required Color iconColor,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _getCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIconContainer(icon, iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: _getCardTitleStyle(),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildIconContainer(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildOptionalBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Optional',
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // MARK: - Form Fields
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isReadOnly = false,
  }) {
    return Container(
      decoration: _getTextFieldDecoration(isReadOnly),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: isReadOnly,
        style: _getTextFieldStyle(isReadOnly),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: _getLabelStyle(isReadOnly),
          prefixIcon: Icon(
            icon,
            color: _getIconColor(isReadOnly),
            size: 20,
          ),
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
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: _getTextFieldDecoration(false),
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            maxLines: 2,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              hintText: 'Tap to select $label',
              hintStyle: _getHintStyle(),
              labelStyle: _getLabelStyle(false),
              prefixIcon: _buildLocationIcon(icon, color),
              suffixIcon: _buildChevronIcon(),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationIcon(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }

  Widget _buildChevronIcon() {
    return Icon(
      Icons.chevron_right,
      color: Colors.white.withOpacity(0.6),
      size: 20,
    );
  }

  // MARK: - Selectors
  Widget _buildTimeSelector() {
    return Obx(() {
      return _buildSelector(
        onTap: () => controller.selectTime(Get.context!),
        icon: Icons.access_time_outlined,
        iconColor: const Color(0xFF3B82F6),
        title: 'Preferred Time',
        value: UIUtils.formatTimeIn12HourFormat(controller.selectedTime.value),
      );
    });
  }

  Widget _buildSeatsSelector() {
    return Obx(() {
      return _buildSelector(
        onTap: controller.handleSeatSelection,
        icon: Icons.airline_seat_recline_normal_outlined,
        iconColor: const Color(0xFF06B6D4),
        title: 'Seats Needed',
        value: '${controller.selectedSeats.value} ${controller.selectedSeats.value == 1 ? 'seat' : 'seats'}',
      );
    });
  }

  Widget _buildSelector({
    required VoidCallback onTap,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _getTextFieldDecoration(false),
        child: Row(
          children: [
            _buildIconContainer(icon, iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: _getSelectorTitleStyle(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: _getSelectorValueStyle(),
                  ),
                ],
              ),
            ),
            _buildChevronIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Urgency Level',
          style: _getSelectorTitleStyle(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildUrgencyOption(
                'normal',
                'Normal',
                Icons.schedule_outlined,
                const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildUrgencyOption(
                'urgent',
                'Urgent',
                Icons.priority_high_outlined,
                const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUrgencyOption(String value, String label, IconData icon, Color color) {
    return Obx(() {
      final isSelected = controller.selectedUrgency.value == value;
      return GestureDetector(
        onTap: () => controller.selectedUrgency.value = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56, // Fixed height to prevent shaking
          padding: const EdgeInsets.symmetric(horizontal: 16), // Only horizontal padding
          decoration: _getUrgencyOptionDecoration(isSelected, color),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: _getUrgencyIconColor(isSelected, color),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: _getUrgencyTextStyleFixed(isSelected, color), // Use fixed style
              ),
            ],
          ),
        ),
      );
    });
  }

  // MARK: - Submit Button
  Widget _buildSubmitButton() {
    return Obx(() {
      return Container(
        width: double.infinity,
        height: 56,
        decoration: _getSubmitButtonDecoration(),
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.submitRideRequest,
          style: _getSubmitButtonStyle(),
          child: controller.isLoading.value
              ? _buildLoadingContent()
              : _buildSubmitContent(),
        ),
      );
    });
  }

  Widget _buildLoadingContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Submitting...',
          style: _getSubmitButtonTextStyle(),
        ),
      ],
    );
  }

  Widget _buildSubmitContent() {
    return Text(
      'Submit Ride Request',
      style: _getSubmitButtonTextStyle(),
    );
  }

  // MARK: - Styles
  BoxDecoration _getCardDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1A1A1D),
          Color(0xFF16161A),
        ],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: const Color(0xFF2A2A2E),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  BoxDecoration _getTextFieldDecoration(bool isReadOnly) {
    return BoxDecoration(
      color: const Color(0xFF0F0F11),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isReadOnly
            ? const Color(0xFF374151).withOpacity(0.3)
            : const Color(0xFF4B5563),
        width: 1,
      ),
    );
  }

  BoxDecoration _getUrgencyOptionDecoration(bool isSelected, Color color) {
    return BoxDecoration(
      color: isSelected
          ? color.withOpacity(0.1)
          : const Color(0xFF0F0F11),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isSelected
            ? color
            : const Color(0xFF374151),
        width: isSelected ? 2 : 1,
      ),
    );
  }

  BoxDecoration _getSubmitButtonDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF8B5CF6),
          Color(0xFF6366F1),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF6366F1).withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  TextStyle _getCardTitleStyle() {
    return AppTextStyles.labelLarge.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 16,
    );
  }

  TextStyle _getTextFieldStyle(bool isReadOnly) {
    return AppTextStyles.bodyMedium.copyWith(
      color: isReadOnly
          ? Colors.white.withOpacity(0.7)
          : Colors.white,
    );
  }

  TextStyle _getLabelStyle(bool isReadOnly) {
    return AppTextStyles.labelMedium.copyWith(
      color: isReadOnly
          ? Colors.white.withOpacity(0.5)
          : Colors.white.withOpacity(0.8),
    );
  }

  TextStyle _getHintStyle() {
    return AppTextStyles.bodyMedium.copyWith(
      color: Colors.white.withOpacity(0.5),
    );
  }

  TextStyle _getSelectorTitleStyle() {
    return AppTextStyles.labelMedium.copyWith(
      color: Colors.white.withOpacity(0.7),
      fontSize: 12,
    );
  }

  TextStyle _getSelectorValueStyle() {
    return AppTextStyles.bodyMedium.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 16,
    );
  }

  TextStyle _getUrgencyTextStyle(bool isSelected, Color color) {
    return AppTextStyles.labelMedium.copyWith(
      color: isSelected
          ? color
          : Colors.white.withOpacity(0.7),
      fontWeight: isSelected
          ? FontWeight.w600
          : FontWeight.normal,
      fontSize: 14,
    );
  }

  TextStyle _getUrgencyTextStyleFixed(bool isSelected, Color color) {
    return AppTextStyles.labelMedium.copyWith(
      color: isSelected ? color : Colors.white.withOpacity(0.7),
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      fontSize: 14, // Fixed font size
      height: 1.2,  // Fixed line height
    );
  }

  TextStyle _getSubmitButtonTextStyle() {
    return AppTextStyles.buttonText.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      color: Colors.white,
    );
  }

  Color _getIconColor(bool isReadOnly) {
    return isReadOnly
        ? Colors.white.withOpacity(0.5)
        : Colors.white.withOpacity(0.8);
  }

  Color _getUrgencyIconColor(bool isSelected, Color color) {
    return isSelected
        ? color
        : Colors.white.withOpacity(0.7);
  }

  ButtonStyle _getSubmitButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}