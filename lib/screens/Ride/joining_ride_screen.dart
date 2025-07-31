import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_appbar.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/controller/joining_ride_controller.dart';
import 'package:synapseride/utils/utility.dart';

class JoiningRideScreen extends StatelessWidget {
  JoiningRideScreen({super.key});

  final JoiningRideController controller = Get.put(JoiningRideController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<JoiningRideController>(
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(
            title: AppStrings.availableRides,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.fetchRides,
              ),
            ],
          ),
          body: controller.isLoading
              ? UIUtils.circleloading()
              : controller.rides.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.no_transfer,
                            size: 64,
                            color: CustomColors.yellow1,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.noRidesAvailable,
                            style: AppTextStyles.headline4Light,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.checkBackLater,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.rides.length,
                      itemBuilder: (context, index) {
                        final ride = controller.rides[index];
                        var isExpanded =
                            controller.expandedItems.contains(index);
                        final isActive = ride['status'] == 'active';
                        final createdAt = ride['createdAt'] as Timestamp;
                        final formattedDate = DateFormat('MMM dd, yyyy hh:mm a')
                            .format(createdAt.toDate());
                        final bool hasJoined = ride['hasJoined'] == true ||
                            controller.joinedRides.contains(ride['rideId']);
                        final availableSeats = ride['seats'] as int;
                        return Card(
                          color: CustomColors.background,
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isActive
                                  ? Colors.green.shade300
                                  : Colors.red.shade300,
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              if (isExpanded) {
                                controller.expandedItems.remove(index);
                              } else {
                                controller.expandedItems.add(index);
                              }
                              controller.update();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  leading: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: CustomColors.textPrimary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      ride['vehicle'] == 'car'
                                          ? Icons.directions_car
                                          : Icons.motorcycle,
                                      color: CustomColors.yellow1,
                                      size: 28,
                                    ),
                                  ),
                                  title: Text(
                                    ride['userName'] ?? 'Unknown User',
                                    style: AppTextStyles.labelLarge,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.phone,
                                              size: 14,
                                              color:
                                                  CustomColors.textSecondary),
                                          const SizedBox(width: 4),
                                          Text(
                                            ride['phoneNumber'] ?? 'No phone',
                                            style: AppTextStyles.bodySmall,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time,
                                              size: 14,
                                              color:
                                                  CustomColors.textSecondary),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Leaving at ${ride['leavingTime']}',
                                            style: AppTextStyles.bodySmall,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formattedDate,
                                        style: AppTextStyles.labelGrey,
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? Colors.green.shade100
                                              : Colors.red.shade100,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          isActive
                                              ? AppStrings.active
                                              : AppStrings.inactive,
                                          style: TextStyle(
                                            color: isActive
                                                ? CustomColors.green1
                                                : CustomColors.error,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$availableSeats ${AppStrings.seats}',
                                        style: AppTextStyles.labelSmall,
                                      ),
                                    ],
                                  ),
                                ),
                                if (controller.expandedItems.contains(index))
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: CustomColors.background,
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppStrings.rideDetails,
                                          style: AppTextStyles.labelLarge,
                                        ),
                                        const Divider(),
                                        const SizedBox(height: 8),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.location_on,
                                                color:
                                                    CustomColors.textSecondary,
                                                size: 20),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppStrings.dropOffAddress,
                                                    style: AppTextStyles
                                                        .labelMedium,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    ride['address'] ??
                                                        AppStrings
                                                            .noAddressProvided,
                                                    style:
                                                        AppTextStyles.bodySmall,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            if (!hasJoined &&
                                                availableSeats > 0)
                                              Expanded(
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        CustomColors.yellow1,
                                                    foregroundColor:
                                                        CustomColors
                                                            .textPrimary,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    controller
                                                        .showJoinConfirmationDialog(
                                                            ride);
                                                  },
                                                  child: Text(
                                                    AppStrings.joinRide,
                                                    style: AppTextStyles
                                                        .buttonText,
                                                  ),
                                                ),
                                              )
                                            else if (hasJoined)
                                              Expanded(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 12),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.green.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'Ride Joined',
                                                    style: AppTextStyles
                                                        .successText,
                                                  ),
                                                ),
                                              )
                                            else
                                              Expanded(
                                                child: Center(
                                                  child: Text(
                                                    AppStrings.noSeatsAvailable,
                                                    style:
                                                        AppTextStyles.errorText,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    CustomColors.textPrimary,
                                                foregroundColor:
                                                    CustomColors.yellow1,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),

                                                ),
                                              ),
                                              onPressed: () {
                                                controller.makePhoneCall(
                                                    ride['phoneNumber'] ?? '');
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.phone,
                                                      color: CustomColors
                                                          .background,
                                                      size: 18),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    AppStrings.call,
                                                    style: AppTextStyles
                                                        .buttonTextLight,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
          ),
        );
      },
    );
  }
}
