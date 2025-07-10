import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/common_widget_requestride.dart';
import 'package:synapseride/common/custom_appbar.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/controller/my_ride_request_controller.dart';
import 'package:synapseride/utils/utility.dart';

class MyRideRequestsScreen extends StatelessWidget {
  MyRideRequestsScreen({super.key});

  final MyRideRequestsController controller =
      Get.put(MyRideRequestsController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyRideRequestsController>(
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'My Ride Requests',
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.fetchMyRequests,
              ),
            ],
          ),
          body: controller.isLoading
              ? UIUtils.circleloading()
              : controller.myRequests.isEmpty
                  ? UIUtils.buildEmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'No Ride Requests',
                      subtitle: 'You haven\'t made any ride requests yet',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.myRequests.length,
                      itemBuilder: (context, index) {
                        final request = controller.myRequests[index];
                        final createdAt = request['createdAt'] as Timestamp?;
                        final formattedDate = createdAt != null
                            ? DateFormat('MMM dd, yyyy hh:mm a')
                                .format(createdAt.toDate())
                            : 'Unknown date';

                        return CommonWidgets.buildAnimatedCard(
                          index: index,
                          child: _buildRequestCard(request, formattedDate),
                        );
                      },
                    ),
        );
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, String formattedDate) {
    final status = request['status'] as String? ?? 'unknown';
    final statusColor = controller.getStatusColor(status);
    final isAccepted = status == 'accepted';

    return CommonWidgets.buildGlassCard(
      borderColor: CustomColors.blue1.withOpacity(0.3),
      gradientColors: [
        Colors.black,
        CustomColors.blue1.withOpacity(0.1),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: AppTextStyles.labelLarge.copyWith(
                  color: CustomColors.yellow1,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              UIUtils.buildStatusBadge(
                status: controller.getStatusText(status).toUpperCase(),
                activeColor: statusColor,
                inactiveColor: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          UIUtils.buildRouteInfo(
            fromAddress: request['fromAddress'] ?? 'Not specified',
            toAddress: request['toAddress'] ?? 'Not specified',
          ),
          const SizedBox(height: 16),
          UIUtils.buildInfoRow(
            icon: Icons.schedule,
            label: 'Preferred Time',
            value: request['preferredTime'] ?? 'Not specified',
          ),
          UIUtils.buildInfoRow(
            icon: Icons.airline_seat_recline_normal,
            label: 'Seats Needed',
            value: '${request['seatsNeeded']} seats',
          ),
          UIUtils.buildInfoRow(
            icon: Icons.priority_high,
            label: 'Urgency',
            value: request['urgency'] ?? 'normal',
          ),
          if (request['notes'] != null &&
              request['notes'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            UIUtils.buildSectionTitle(title: 'Notes:'),
            const SizedBox(height: 4),
            Text(
              request['notes'],
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
          if (isAccepted && request['acceptorName'] != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CustomColors.blue1.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: CustomColors.blue1.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accepted by:',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: CustomColors.blue1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request['acceptorName'] ?? 'Unknown',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (request['acceptorPhone'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      request['acceptorPhone'],
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          _buildActionButtons(request, isAccepted, status),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      Map<String, dynamic> request, bool isAccepted, String status) {
    List<ActionButtonConfig> buttons = [];

    if (isAccepted && request['acceptorPhone'] != null) {
      buttons.add(ActionButtonConfig(
        label: 'Call Driver',
        icon: Icons.phone,
        backgroundColor: CustomColors.blue1,
        textColor: Colors.white,
        onPressed: () => controller.makePhoneCall(request['acceptorPhone']),
      ));
    }

    if (status == 'pending') {
      buttons.add(ActionButtonConfig(
        label: 'Cancel',
        backgroundColor: Colors.transparent,
        textColor: CustomColors.blue1,
        onPressed: () => controller.cancelRequest(request['requestId']),
      ));
    }

    buttons.add(ActionButtonConfig(
      label: 'Delete',
      backgroundColor: CustomColors.error,
      textColor: Colors.white,
      onPressed: () =>
          controller.showDeleteConfirmationDialog(request['requestId']),
    ));

    return UIUtils.buildActionButtonRow(buttons: buttons);
  }
}
