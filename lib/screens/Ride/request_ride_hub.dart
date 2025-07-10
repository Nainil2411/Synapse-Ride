import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/Routes/routes.dart';
import 'package:synapseride/common/common_widget_requestride.dart';
import 'package:synapseride/common/custom_appbar.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/controller/accept_ride_controller.dart';

class RideRequestHubScreen extends StatefulWidget {
  const RideRequestHubScreen({super.key});

  @override
  State<RideRequestHubScreen> createState() => _RideRequestHubScreenState();
}

class _RideRequestHubScreenState extends State<RideRequestHubScreen> {
  bool hasAcceptedRides = false;

  @override
  void initState() {
    super.initState();
    _checkAcceptedRides();
  }

  Future<void> _checkAcceptedRides() async {
    final hasRides = await AcceptedRidesController.hasAcceptedRides();
    if (mounted) {
      setState(() {
        hasAcceptedRides = hasRides;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Ride Requests',
        onBackPressed: () => Get.back(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CommonWidgets.buildScreenHeader(
              title: 'Ride Request System',
              subtitle:
                  'Request rides or help others by accepting their requests',
              icon: Icons.directions_car,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CommonWidgets.buildActionCard(
                      title: 'Request a Ride',
                      subtitle:
                          'Need a ride? Create a request for others to see',
                      icon: Icons.add_circle_outline,
                      color: CustomColors.green1,
                      onTap: () async {
                        final result = await Get.toNamed(AppRoutes.requestRide);
                        if (result == true) {
                          _checkAcceptedRides();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    CommonWidgets.buildActionCard(
                      title: 'My Ride Requests',
                      subtitle: 'View and manage your ride requests',
                      icon: Icons.list_alt,
                      color: CustomColors.blue1,
                      onTap: () => Get.toNamed(AppRoutes.myRideRequests),
                    ),
                    const SizedBox(height: 16),
                    CommonWidgets.buildActionCard(
                      title: 'Available Requests',
                      subtitle: 'Help others by accepting their ride requests',
                      icon: Icons.people_outline,
                      color: Colors.orange,
                      onTap: () async {
                        final result =
                            await Get.toNamed(AppRoutes.viewRideRequests);
                        if (result == true) {
                          _checkAcceptedRides();
                        }
                      },
                    ),
                    if (hasAcceptedRides) ...[
                      const SizedBox(height: 16),
                      CommonWidgets.buildActionCard(
                        title: 'Accepted Rides',
                        subtitle: 'Manage rides you\'ve accepted from others',
                        icon: Icons.check_circle_outline,
                        color: Colors.purple,
                        onTap: () async {
                          final result =
                              await Get.toNamed(AppRoutes.acceptedRides);
                          if (result == true) {
                            _checkAcceptedRides();
                          }
                        },
                        showBadge: true,
                        badgeText: 'NEW',
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
