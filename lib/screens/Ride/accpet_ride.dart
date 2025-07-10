import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/common_widget_requestride.dart';
import 'package:synapseride/common/custom_appbar.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/controller/accept_ride_controller.dart';
import 'package:synapseride/utils/utility.dart';

class AcceptedRidesScreen extends StatelessWidget {
  AcceptedRidesScreen({super.key});

  final AcceptedRidesController controller = Get.put(AcceptedRidesController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AcceptedRidesController>(
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Accepted Rides',
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.fetchAcceptedRides,
              ),
            ],
          ),
          body: controller.isLoading
              ? UIUtils.circleloading()
              : controller.acceptedRides.isEmpty
                  ? UIUtils.buildEmptyState(
                      icon: Icons.check_circle_outline,
                      title: 'No Accepted Rides',
                      subtitle: 'You haven\'t accepted any ride requests yet',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.acceptedRides.length,
                      itemBuilder: (context, index) {
                        final ride = controller.acceptedRides[index];
                        final acceptedAt = ride['acceptedAt'] as Timestamp?;
                        final formattedDate = acceptedAt != null
                            ? DateFormat('MMM dd, yyyy hh:mm a')
                                .format(acceptedAt.toDate())
                            : 'Unknown date';
                        return CommonWidgets.buildAnimatedCard(
                          index: index,
                          child: _buildRideCard(ride, formattedDate),
                        );
                      },
                    ),
        );
      },
    );
  }

  Widget _buildRideCard(Map<String, dynamic> ride, String formattedDate) {
    final status = ride['status'] as String? ?? 'unknown';
    final statusColor = controller.getStatusColor(status);

    return CommonWidgets.buildGlassCard(
      borderColor: Colors.purple.withOpacity(0.3),
      gradientColors: [
        Colors.black,
        Colors.purple.withOpacity(0.1),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ride['requesterName'] ?? 'Unknown Requester',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              UIUtils.buildStatusBadge(
                status: controller.getStatusText(status).toUpperCase(),
                activeColor: statusColor,
                inactiveColor: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Accepted: $formattedDate',
            style: AppTextStyles.labelMedium.copyWith(
              color: CustomColors.yellow1,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          UIUtils.buildRouteInfo(
            fromAddress: ride['fromAddress'] ?? 'Not specified',
            toAddress: ride['toAddress'] ?? 'Not specified',
          ),
          const SizedBox(height: 16),
          UIUtils.buildInfoRow(
            icon: Icons.schedule,
            label: 'Preferred Time',
            value: ride['preferredTime'] ?? 'Not specified',
          ),
          UIUtils.buildInfoRow(
            icon: Icons.airline_seat_recline_normal,
            label: 'Seats Needed',
            value: '${ride['seatsNeeded']} seats',
          ),
          UIUtils.buildInfoRow(
            icon: Icons.phone,
            label: 'Requester Phone',
            value: ride['requesterPhone'] ?? 'Not provided',
          ),
          UIUtils.buildInfoRow(
            icon: Icons.priority_high,
            label: 'Urgency',
            value: ride['urgency'] ?? 'normal',
          ),
          if (ride['notes'] != null && ride['notes'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            UIUtils.buildSectionTitle(title: 'Notes:'),
            const SizedBox(height: 4),
            Text(
              ride['notes'],
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
          const SizedBox(height: 18),
          UIUtils.buildActionButtonRow(
            buttons: [
              ActionButtonConfig(
                label: 'Call',
                icon: Icons.phone,
                backgroundColor: CustomColors.green1,
                textColor: Colors.white,
                onPressed: () =>
                    controller.makePhoneCall(ride['requesterPhone'] ?? ''),
              ),
              ActionButtonConfig(
                label: 'Cancel',
                icon: Icons.cancel,
                backgroundColor: Colors.purple,
                textColor: Colors.white,
                onPressed: () => controller.showCancelConfirmationDialog(
                    ride['requestId'], ride['requesterName'] ?? 'Unknown'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
