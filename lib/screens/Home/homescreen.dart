import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_map/flutter_map.dart";
import "package:flutter_map_location_marker/flutter_map_location_marker.dart";
import "package:get/get.dart";
import "package:synapseride/Routes/routes.dart";
import "package:synapseride/common/app_string.dart";
import "package:synapseride/common/app_textstyle.dart";
import "package:synapseride/common/custom_color.dart";
import "package:synapseride/controller/home_controller.dart";
import "package:synapseride/screens/Home/custom_drawer.dart";

class MapScreen extends StatelessWidget {
  MapScreen({super.key});

  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.arguments == true) {
        controller.forceRefreshRoute();
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: controller.scaffoldKey,
        drawer: CustomDrawer(),
        body: Stack(
          children: [
            Obx(() => FlutterMap(
                  mapController: controller.mapController,
                  options: MapOptions(
                    initialCenter: controller.initialPosition.value,
                    initialZoom: controller.initialZoom,
                    minZoom: 4.0,
                    maxZoom: 20.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                    onPositionChanged: (position, hasGesture) {
                      controller.currentZoom.value = position.zoom;
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: controller.getMapStyleUrl(),
                      subdomains: controller.getMapStyleSubdomains(),
                    ),
                    PolylineLayer(polylines: controller.routePolylines.value),
                    CurrentLocationLayer(),
                    MarkerLayer(markers: controller.markers.value),
                  ],
                )),
            Positioned(
              top: 40,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: CustomColors.textPrimary,
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: CustomColors.yellow1),
                      onPressed: () {
                        controller.scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: CustomColors.textPrimary,
                    child: IconButton(
                      icon: const Icon(Icons.notifications,
                          color: CustomColors.yellow1),
                      onPressed: () =>
                          Get.toNamed(AppRoutes.notificationScreen),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 110,
              left: 25,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final isOpen = controller.showMapStyleDialog.value;

                    return Visibility(
                      visible: isOpen,
                      child: Container(
                        width: 70,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: CustomColors.textPrimary,
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: MapStyle.values.map((style) {
                              return Obx(() => Container(
                                    width: 70,
                                    height: 60,
                                    margin: const EdgeInsets.all(4),
                                    child: GestureDetector(
                                      onTap: () =>
                                          controller.changeMapStyle(style),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: controller
                                                      .currentMapStyle.value ==
                                                  style
                                              ? CustomColors.yellow1
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(31),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              controller.getMapStyleIcon(style),
                                              color: controller.currentMapStyle
                                                          .value ==
                                                      style
                                                  ? CustomColors.textPrimary
                                                  : CustomColors.yellow1,
                                              size: 24,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              controller.getMapStyleName(style),
                                              style: TextStyle(
                                                color: controller
                                                            .currentMapStyle
                                                            .value ==
                                                        style
                                                    ? CustomColors.textPrimary
                                                    : CustomColors.yellow1,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ));
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  }),
                  Obx(() => CircleAvatar(
                        radius: 22,
                        backgroundColor: controller.showMapStyleDialog.value
                            ? CustomColors.yellow1
                            : CustomColors.textPrimary,
                        child: IconButton(
                          icon: Icon(
                            controller.showMapStyleDialog.value
                                ? Icons.close
                                : Icons.layers,
                            color: controller.showMapStyleDialog.value
                                ? CustomColors.textPrimary
                                : CustomColors.yellow1,
                          ),
                          onPressed: controller.toggleMapStyleDialog,
                        ),
                      )),
                ],
              ),
            ),
            Positioned(
              bottom: 110,
              right: 16,
              child: CircleAvatar(
                backgroundColor: CustomColors.textPrimary,
                child: IconButton(
                  icon: const Icon(Icons.my_location,
                      color: CustomColors.yellow1),
                  onPressed: controller.navigateToCurrentLocation,
                ),
              ),
            ),
            Obx(() => StreamBuilder<QuerySnapshot>(
                  stream: controller.currentUserId.value.isNotEmpty
                      ? FirebaseFirestore.instance
                          .collection('users')
                          .doc(controller.currentUserId.value)
                          .collection('rides')
                          .where('status', isEqualTo: 'active')
                          .snapshots()
                      : null,
                  builder: (context, snapshot) {
                    bool hasActiveRide = false;
                    if (snapshot.hasData && snapshot.data != null) {
                      hasActiveRide = snapshot.data!.docs.isNotEmpty;
                    }
                    if (hasActiveRide && controller.routePolylines.isEmpty) {
                      controller.loadActiveRideRoute();
                    }

                    return Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: CustomColors.textPrimary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Obx(() => GestureDetector(
                                    onTap: () {
                                      controller.selectedIndex.value = 0;
                                      controller
                                          .navigateToCreateRide(hasActiveRide);
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color:
                                            controller.selectedIndex.value == 0
                                                ? CustomColors.yellow1
                                                : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.directions_car,
                                            color: controller
                                                        .selectedIndex.value ==
                                                    0
                                                ? CustomColors.textPrimary
                                                : CustomColors.background,
                                            size: 18,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            AppStrings.createRide,
                                            style: AppTextStyles.labelSmall
                                                .copyWith(
                                              color: controller.selectedIndex
                                                          .value ==
                                                      0
                                                  ? CustomColors.textPrimary
                                                  : CustomColors.background,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Obx(() => GestureDetector(
                                    onTap: () {
                                      controller.selectedIndex.value = 1;
                                      controller
                                          .navigateToJoiningRide(hasActiveRide);
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color:
                                            controller.selectedIndex.value == 1
                                                ? CustomColors.yellow1
                                                : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.group,
                                            color: controller
                                                        .selectedIndex.value ==
                                                    1
                                                ? CustomColors.textPrimary
                                                : CustomColors.background,
                                            size: 18,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            AppStrings.joiningRide,
                                            style: AppTextStyles.labelSmall
                                                .copyWith(
                                              color: controller.selectedIndex
                                                          .value ==
                                                      1
                                                  ? CustomColors.textPrimary
                                                  : CustomColors.background,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Obx(() => GestureDetector(
                                    onTap: () {
                                      controller.selectedIndex.value = 2;
                                      controller
                                          .navigateToRequestRide(hasActiveRide);
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color:
                                            controller.selectedIndex.value == 2
                                                ? CustomColors.yellow1
                                                : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.hail,
                                            color: controller
                                                        .selectedIndex.value ==
                                                    2
                                                ? CustomColors.textPrimary
                                                : CustomColors.background,
                                            size: 18,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            AppStrings.requestride,
                                            style: AppTextStyles.labelSmall
                                                .copyWith(
                                              color: controller.selectedIndex
                                                          .value ==
                                                      2
                                                  ? CustomColors.textPrimary
                                                  : CustomColors.background,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }
}
