import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/Routes/routes.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/common_widget_requestride.dart';
import 'package:synapseride/common/custom_appbar.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/controller/ride_history_controller.dart';
import 'package:synapseride/utils/time_utilies.dart';
import 'package:synapseride/utils/utility.dart';

class RideHistoryScreen extends StatelessWidget {
  RideHistoryScreen({super.key});

  final RideHistoryController controller = Get.put(RideHistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.rideHistory,
        onBackPressed: () {
          Get.back(result: controller.deleteride.value);
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(controller.userId)
            .collection('rides')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return UIUtils.circleloading();
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: CustomColors.yellow1),
              ),
            );
          }

          final rides = snapshot.data?.docs ?? [];
          if (rides.isEmpty) {
            return UIUtils.buildEmptyState(
              icon: Icons.history,
              title: AppStrings.noRideHistory,
              subtitle: 'You haven\'t created any rides yet',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index].data() as Map<String, dynamic>;
              final rideId = rides[index].id;
              final createdAt = ride['createdAt'] as Timestamp?;
              final formattedDate = createdAt != null
                  ? '${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}'
                  : 'Unknown date';

              final leavingTime = ride['leavingTime'] as String?;
              final currentStatus = ride['status'] as String?;

              if (leavingTime != null && currentStatus == 'active') {
                if (TimeUtils.shouldRideBeInactive(leavingTime)) {
                  TimeUtils.updateRideStatusIfNeeded(
                      controller.userId!, rideId, ride);
                  ride['status'] = 'inactive';
                }
              }

              return CommonWidgets.buildAnimatedCard(
                index: index,
                child: GlassRideCard(
                  ride: ride,
                  rideId: rideId,
                  formattedDate: formattedDate,
                  controller: controller,
                  confirmDelete: () => confirmDelete(context, rideId),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> confirmDelete(BuildContext context, String rideId) async {
    final result = await UIUtils.showConfirmDeleteDialog(context: context);
    if (result) {
      Get.offAllNamed(AppRoutes.home);
      controller.deleteride.value = true;
      try {
        final joinedUsersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(controller.userId)
            .collection('rides')
            .doc(rideId)
            .collection('joinedUsers')
            .get();

        for (final doc in joinedUsersSnapshot.docs) {
          await doc.reference.delete();
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(controller.userId)
            .collection('rides')
            .doc(rideId)
            .delete();

        Get.snackbar(AppStrings.success, AppStrings.rideDeleted,
            backgroundColor: CustomColors.green1);
      } catch (e) {
        Get.snackbar('', '${AppStrings.errorDeletingRide} $e',
            backgroundColor: CustomColors.error);
      }
    }
  }
}

class GlassRideCard extends StatefulWidget {
  final Map<String, dynamic> ride;
  final String rideId;
  final String formattedDate;
  final RideHistoryController controller;
  final VoidCallback confirmDelete;

  const GlassRideCard({
    required this.ride,
    required this.rideId,
    required this.formattedDate,
    required this.controller,
    required this.confirmDelete,
    super.key,
  });

  @override
  State<GlassRideCard> createState() => _GlassRideCardState();
}

class _GlassRideCardState extends State<GlassRideCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 1, end: 1.05)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.ride['status'] == 'active';
    final leavingTime = widget.ride['leavingTime'] as String?;

    String timeStatus = '';
    if (leavingTime != null && !isActive) {
      if (TimeUtils.shouldRideBeInactive(leavingTime)) {
        timeStatus = ' (Time passed)';
      }
    }

    return ScaleTransition(
      scale: isActive ? _scale : AlwaysStoppedAnimation(1.0),
      child: CommonWidgets.buildGlassCard(
        showShadow: isActive,
        shadowColor: CustomColors.yellow1.withOpacity(0.20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.formattedDate,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: CustomColors.yellow1,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.7,
                  ),
                ),
                UIUtils.buildStatusBadge(
                  status: widget.ride['status'] ?? 'unknown',
                  timeStatus: timeStatus,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: CustomColors.yellow1.withOpacity(0.13),
                    border: Border.all(
                      color: CustomColors.yellow1.withOpacity(0.35),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.ride['vehicle'] == 'car'
                        ? Icons.directions_car
                        : Icons.motorcycle,
                    color: CustomColors.yellow1,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${widget.ride['vehicle'] == 'car' ? AppStrings.car : AppStrings.bike}'
                  ' • ${widget.ride['seats']} ${widget.ride['seats'] == 1 ? 'seat' : 'seats'}',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            UIUtils.buildInfoRow(
              icon: Icons.access_time,
              label: AppStrings.leavingTime,
              value: widget.ride['leavingTime'] ?? 'Not specified',
            ),
            UIUtils.buildInfoRow(
              icon: Icons.location_on,
              label: AppStrings.address,
              value: widget.ride['address'] ?? 'Not specified',
            ),
            UIUtils.buildInfoRow(
              icon: Icons.phone,
              label: AppStrings.phoneNumber,
              value: widget.ride['phoneNumber'] ?? 'Not specified',
            ),
            const SizedBox(height: 14),
            widget.controller.buildJoinedUsers(widget.rideId),
            const SizedBox(height: 18),
            UIUtils.buildActionButtonRow(
              buttons: [
                ActionButtonConfig(
                  label: AppStrings.edit,
                  backgroundColor: Colors.transparent,
                  textColor: CustomColors.yellow1,
                  onPressed: () {
                    Get.toNamed(AppRoutes.editRide, arguments: {
                      'rideId': widget.rideId,
                      'rideData': widget.ride,
                    });
                  },
                ),
                ActionButtonConfig(
                  label: AppStrings.delete,
                  backgroundColor: CustomColors.yellow1,
                  textColor: Colors.black,
                  onPressed: widget.confirmDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
