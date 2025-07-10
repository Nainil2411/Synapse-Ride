import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/common_widget_requestride.dart';
import 'package:synapseride/common/custom_appbar.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/controller/view_ride_request_controller.dart';
import 'package:synapseride/utils/utility.dart';

class ViewRideRequestsScreen extends StatelessWidget {
  ViewRideRequestsScreen({super.key});

  final ViewRideRequestsController controller =
      Get.put(ViewRideRequestsController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ViewRideRequestsController>(
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Ride Requests',
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.fetchRideRequests,
              ),
            ],
          ),
          body: controller.isLoading
              ? UIUtils.circleloading()
              : controller.rideRequests.isEmpty
                  ? UIUtils.buildEmptyState(
                      icon: Icons.search_off,
                      title: 'No Ride Requests',
                      subtitle:
                          'There are no pending ride requests at the moment',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.rideRequests.length,
                      itemBuilder: (context, index) {
                        final request = controller.rideRequests[index];
                        final isExpanded =
                            controller.expandedItems.contains(index);
                        final createdAt = request['createdAt'] as Timestamp?;
                        final formattedDate = createdAt != null
                            ? DateFormat('MMM dd, yyyy hh:mm a')
                                .format(createdAt.toDate())
                            : 'Unknown date';

                        return CommonWidgets.buildAnimatedCard(
                          index: index,
                          child: _buildRequestCard(
                              request, index, isExpanded, formattedDate),
                        );
                      },
                    ),
        );
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, int index,
      bool isExpanded, String formattedDate) {
    final isUrgent = request['urgency'] == 'urgent';

    return GestureDetector(
      onTap: () {
        if (isExpanded) {
          controller.expandedItems.remove(index);
        } else {
          controller.expandedItems.add(index);
        }
        controller.update();
      },
      child: CommonWidgets.buildGlassCard(
        showShadow: isUrgent,
        shadowColor: CustomColors.error.withOpacity(0.20),
        borderColor: isUrgent
            ? CustomColors.error.withOpacity(0.3)
            : Colors.orange.withOpacity(0.3),
        gradientColors: [
          Colors.black,
          isUrgent
              ? CustomColors.error.withOpacity(0.1)
              : Colors.orange.withOpacity(0.055),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request['requesterName'] ?? 'Unknown',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                UIUtils.buildStatusBadge(
                  status: isUrgent ? 'URGENT' : 'NORMAL',
                  activeColor:
                      isUrgent ? CustomColors.error : CustomColors.green1,
                ),
              ],
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            UIUtils.buildRouteInfo(
              fromAddress: request['fromAddress'] ?? 'Not specified',
              toAddress: request['toAddress'] ?? 'Not specified',
            ),
            if (isExpanded) ...[
              const SizedBox(height: 16),
              Divider(color: CustomColors.yellow1.withOpacity(0.3)),
              const SizedBox(height: 16),
              UIUtils.buildInfoRow(
                icon: Icons.phone,
                label: 'Phone',
                value: request['requesterPhone'] ?? 'Not provided',
              ),
              UIUtils.buildInfoRow(
                icon: Icons.access_time,
                label: 'Requested',
                value: formattedDate,
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
              const SizedBox(height: 20),
              UIUtils.buildActionButtonRow(
                buttons: [
                  ActionButtonConfig(
                    label: 'Call',
                    icon: Icons.phone,
                    backgroundColor: Colors.transparent,
                    textColor: CustomColors.yellow1,
                    onPressed: () => controller
                        .makePhoneCall(request['requesterPhone'] ?? ''),
                  ),
                  ActionButtonConfig(
                    label: 'Accept',
                    icon: Icons.check,
                    backgroundColor: CustomColors.yellow1,
                    textColor: Colors.black,
                    onPressed: () =>
                        controller.showAcceptConfirmationDialog(request),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
