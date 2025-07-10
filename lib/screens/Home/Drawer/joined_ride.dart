import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_appbar.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/common/elevated_button.dart';
import 'package:synapseride/controller/joined_ride_controller.dart';

class JoinedRideScreen extends StatefulWidget {
  const JoinedRideScreen({super.key});

  @override
  State<JoinedRideScreen> createState() => _JoinedRideScreenState();
}

class _JoinedRideScreenState extends State<JoinedRideScreen>
    with TickerProviderStateMixin {
  final JoinedRideController controller = Get.put(JoinedRideController());
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fadeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _slideController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.background,
      appBar: CustomAppBar(
        title: AppStrings.joinedRide,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchJoinedRide,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        } else if (controller.joinedRide.value == null) {
          return _buildEmptyState();
        }

        final joinedRide = controller.joinedRide.value!;
        return _buildRideContent(joinedRide);
      }),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [CustomColors.yellow1, CustomColors.yellow1.withOpacity(0.3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your ride...',
            style: AppTextStyles.bodyMediumwhite.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        CustomColors.yellow1.withOpacity(0.2),
                        CustomColors.yellow1.withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.directions_car_rounded,
                    size: 60,
                    color: CustomColors.yellow1,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  AppStrings.noJoinedRides,
                  style: AppTextStyles.headline4Light.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.joinedmessage,
                  style: AppTextStyles.bodyMediumwhite.copyWith(
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [CustomColors.yellow1, CustomColors.yellow1.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: CustomColors.yellow1.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Find a Ride',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: CustomColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRideContent(Map<String, dynamic> joinedRide) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeroSection(joinedRide),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRideDetailsCard(joinedRide),
                  const SizedBox(height: 20),
                  _buildDriverDetailsCard(joinedRide),
                  const SizedBox(height: 30),
                  _buildActionButtons(joinedRide),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(Map<String, dynamic> joinedRide) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CustomColors.yellow1,
            CustomColors.yellow1.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: CustomColors.yellow1.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: joinedRide['status'] == 'active'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: joinedRide['status'] == 'active'
                          ? Colors.green
                          : Colors.red,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: joinedRide['status'] == 'active'
                              ? Colors.green
                              : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        joinedRide['status'] == 'active' ? 'Active Ride' : 'Inactive',
                        style: TextStyle(
                          color: joinedRide['status'] == 'active'
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Hero(
                      tag: 'driver_avatar',
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _buildProfileImage(joinedRide['profileImagePath']),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Riding with',
                            style: TextStyle(
                              color: CustomColors.textPrimary.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            joinedRide['userName'] ?? 'Unknown Driver',
                            style: AppTextStyles.labelLarge.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CustomColors.textPrimary,
                        borderRadius: BorderRadius.circular(55),
                      ),
                      child: Icon(
                        joinedRide['vehicle'] == 'car'
                            ? Icons.directions_car_rounded
                            : Icons.motorcycle_rounded,
                        color: CustomColors.background,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(String? path) {
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _defaultProfileIcon(),
        );
      }
    }
    return _defaultProfileIcon();
  }

  Widget _defaultProfileIcon() {
    return Container(
      color: CustomColors.textPrimary,
      alignment: Alignment.center,
      child: Icon(
        Icons.person_rounded,
        color: CustomColors.background,
        size: 35,
      ),
    );
  }

  Widget _buildRideDetailsCard(Map<String, dynamic> joinedRide) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-0.3, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut)),
      child: Container(
        decoration: BoxDecoration(
          color: CustomColors.background,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: CustomColors.textPrimary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CustomColors.textPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: CustomColors.yellow1,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.rideDetails,
                    style: AppTextStyles.headline4
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildAnimatedDetailRow(
                Icons.access_time_rounded,
                AppStrings.leavingTime,
                joinedRide['leavingTime'] ?? 'Not specified',
                0,
              ),
              _buildAnimatedDetailRow(
                Icons.location_on_rounded,
                AppStrings.dropOffLocation,
                joinedRide['address'] ?? 'Not specified',
                1,
              ),
              _buildAnimatedDetailRow(
                Icons.event_rounded,
                AppStrings.joinedOn,
                joinedRide['joinedAt'] != null
                    ? DateFormat('MMM dd, yyyy • hh:mm a').format(
                    (joinedRide['joinedAt'] as Timestamp).toDate())
                    : 'Unknown',
                2,
              ),
              _buildAnimatedDetailRow(
                Icons.airline_seat_recline_normal_rounded,
                AppStrings.availableSeats,
                '${joinedRide['seats'] ?? 0} seats',
                3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverDetailsCard(Map<String, dynamic> joinedRide) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.3, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut)),
      child: Container(
        decoration: BoxDecoration(
          color: CustomColors.background,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: CustomColors.textPrimary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CustomColors.green1.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: CustomColors.green1,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.userDetails,
                    style: AppTextStyles.headline4
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildAnimatedDetailRow(
                Icons.person_rounded,
                AppStrings.name,
                joinedRide['userName'] ?? 'Unknown',
                0,
              ),
              _buildAnimatedDetailRow(
                Icons.phone_rounded,
                AppStrings.phoneNumber,
                joinedRide['phoneNumber'] ?? 'Not available',
                1,
                isPhone: true,
              ),
              _buildAnimatedDetailRow(
                Icons.directions_car_rounded,
                AppStrings.vehicleType,
                joinedRide['vehicle'] == 'car' ? 'Car' : 'Motorcycle',
                2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedDetailRow(
      IconData icon,
      String label,
      String value,
      int index, {
        bool isPhone = false,
      }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0.2, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _slideController,
          curve: Interval(
            index * 0.15,
            1.0,
            curve: Curves.easeOutBack,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CustomColors.textPrimary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CustomColors.textPrimary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CustomColors.textPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: CustomColors.yellow1,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelGrey.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> joinedRide) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomElevatedButton(
                  onPressed: () => controller.makePhoneCall(joinedRide['phoneNumber'] ?? ''),
                  label: AppStrings.callDriver,
                  icon: Icons.phone_rounded,
                  backgroundColor: CustomColors.green1,
                  textColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomElevatedButton(
                  onPressed: controller.openChat,
                  label: 'Chat',
                  icon: Icons.chat_rounded,
                  textColor: CustomColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CustomElevatedButton(
              onPressed: controller.showLeaveConfirmationDialog,
              label: AppStrings.leaveRide,
              icon: Icons.exit_to_app_rounded,
              textColor: Colors.white,
              backgroundColor: CustomColors.error,
            ),
          ),
        ],
      ),
    );
  }
}