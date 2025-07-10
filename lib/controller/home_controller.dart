import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:synapseride/Routes/routes.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/utils/utility.dart';

enum MapStyle {
  normal,
  satellite,
  terrain,
  dark,
  voyager,
  osmFrench,
}

class HomeController extends GetxController {
  final MapController mapController = MapController();
  final Location location = Location();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  var selectedIndex = 0.obs;
  var routePolylines = <Polyline>[].obs;
  Timer? animationTimer;
  var allRoutePoints = <LatLng>[].obs;
  var currentRoutePoints = <LatLng>[].obs;
  var animationStep = 0.obs;
  var initialPosition = LatLng(37.42796133580664, -122.085749655962).obs;
  final double initialZoom = 14.0;
  var currentPosition = Rxn<LatLng>();
  var markers = <Marker>[].obs;
  var currentUserId = ''.obs;
  var currentMapStyle = MapStyle.normal.obs;
  var showMapStyleDialog = false.obs;
  var currentZoom = 0.0.obs;

  @override
  void onInit() {
    initializeLocationAndMap();
    getCurrentUser();
    checkAndLoadRouteData();
    super.onInit();
  }

  @override
  void onClose() {
    animationTimer?.cancel();
    super.onClose();
  }

  void toggleMapStyleDialog() {
    showMapStyleDialog.value = !showMapStyleDialog.value;
  }

  void changeMapStyle(MapStyle style) {
    currentMapStyle.value = style;
    showMapStyleDialog.value = false;
  }

  String getMapStyleUrl() {
    switch (currentMapStyle.value) {
      case MapStyle.normal:
        return 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';
      case MapStyle.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapStyle.terrain:
        return 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';
      case MapStyle.dark:
        return 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';
      case MapStyle.voyager:
        return 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
      case MapStyle.osmFrench:
        return 'https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png';
    }
  }

  List<String> getMapStyleSubdomains() {
    switch (currentMapStyle.value) {
      case MapStyle.normal:
      case MapStyle.terrain:
      case MapStyle.dark:
      case MapStyle.voyager:
      case MapStyle.osmFrench:
        return ['a', 'b', 'c'];
      case MapStyle.satellite:
        return [];
    }
  }

  String getMapStyleName(MapStyle style) {
    switch (style) {
      case MapStyle.normal:
        return 'Normal';
      case MapStyle.satellite:
        return 'Satellite';
      case MapStyle.terrain:
        return 'Terrain';
      case MapStyle.dark:
        return 'Dark';
      case MapStyle.voyager:
        return 'Voyager';
      case MapStyle.osmFrench:
        return 'OSM French';
    }
  }

  IconData getMapStyleIcon(MapStyle style) {
    switch (style) {
      case MapStyle.normal:
        return Icons.map;
      case MapStyle.satellite:
        return Icons.satellite_alt;
      case MapStyle.terrain:
        return Icons.terrain;
      case MapStyle.dark:
        return Icons.dark_mode;
      case MapStyle.voyager:
        return Icons.explore;
      case MapStyle.osmFrench:
        return Icons.account_balance;
    }
  }

  void getCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId.value = user.uid;
    }
  }

  Future<void> checkAndLoadRouteData() async {
    final user = FirebaseAuth.instance.currentUser;
    currentUserId.value = user?.uid ?? '';
    final userRidesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId.value)
        .collection('rides')
        .get();
    bool joinedAlready = await hasUserJoinedAnyRide();
    if (userRidesSnapshot.docs.isNotEmpty || joinedAlready) {
      loadActiveRideRoute();
    }
  }

  void animateRoute(List<LatLng> points) {
    animationTimer?.cancel();
    animationStep.value = 0;
    allRoutePoints.value = List.from(points);
    currentRoutePoints.clear();

    if (points.length >= 2) {
      routePolylines.value = [
        Polyline(
          points: [points.first, points.first],
          strokeWidth: 4.0,
          color: CustomColors.blue1,
        ),
      ];
    } else {
      routePolylines.clear();
    }

    if (points.length < 2) {
      return;
    }

    final int totalPoints = points.length;
    final int stepsNeeded = totalPoints < 50 ? totalPoints : 50;
    final int pointsPerStep = (totalPoints / stepsNeeded).ceil();

    animationTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (animationStep.value >= totalPoints) {
        timer.cancel();
        return;
      }

      final int endIndex = (animationStep.value + pointsPerStep) < totalPoints
          ? animationStep.value + pointsPerStep
          : totalPoints;

      currentRoutePoints.value = allRoutePoints.sublist(0, endIndex);
      animationStep.value = endIndex;

      if (currentRoutePoints.length >= 2) {
        routePolylines.value = [
          Polyline(
            points: currentRoutePoints.value,
            strokeWidth: 4.0,
            color: CustomColors.blue1,
          ),
        ];
      }
    });
  }

  Future<void> loadActiveRideRoute() async {
    if (currentUserId.value.isEmpty) return;
    try {
      clearMapMarkersAndPolylines();

      routePolylines.clear();
      markers.clear();

      final usersSnapshot =
          await FirebaseFirestore.instance.collection("users").get();

      for (var userDoc in usersSnapshot.docs) {
        final ridesSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userDoc.id)
            .collection('rides')
            .where('status', isEqualTo: 'active')
            .get();

        for (var rideDoc in ridesSnapshot.docs) {
          final joinedUserDoc = await FirebaseFirestore.instance
              .collection("users")
              .doc(userDoc.id)
              .collection("rides")
              .doc(rideDoc.id)
              .collection("joinedUsers")
              .doc(currentUserId.value)
              .get();

          if (joinedUserDoc.exists || userDoc.id == currentUserId.value) {
            final rideData = rideDoc.data();

            if (rideData.containsKey("routePoints")) {
              List<LatLng> points = (rideData["routePoints"] as List<dynamic>)
                  .map((point) => LatLng(point["latitude"], point["longitude"]))
                  .toList();
              points = points
                  .where(
                    (point) =>
                        point.latitude >= -90 &&
                        point.latitude <= 90 &&
                        point.longitude >= -180 &&
                        point.longitude <= 180,
                  )
                  .toList();

              if (rideData.containsKey("destinationLocation")) {
                final destLat = rideData["destinationLocation"]["latitude"];
                final destLng = rideData["destinationLocation"]["longitude"];
                markers.add(
                  Marker(
                    point: LatLng(destLat, destLng),
                    child: Icon(
                      Icons.location_pin,
                      color: CustomColors.error,
                      size: 40,
                    ),
                  ),
                );
              }

              if (points.length >= 2) {
                final startPoint = points.first;
                markers.add(
                  Marker(
                    point: startPoint,
                    child: Icon(
                      Icons.person_pin,
                      color: CustomColors.green1,
                      size: 40,
                    ),
                  ),
                );
                animateRoute(points);
              } else {
                log("Not enough valid points to create a route. Points count: ${points.length}");
              }
              return;
            }
          }
        }
      }
    } catch (e) {
      log("Error loading ride route: $e");
    }
  }

  void clearMapMarkersAndPolylines() {
    animationTimer?.cancel();
    markers.clear();
    routePolylines.clear();
    currentRoutePoints.clear();
    allRoutePoints.clear();
  }

  Future<void> initializeLocationAndMap() async {
    await checkLocationPermission();
    await getCurrentLocation();
  }

  Future<void> checkLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      LocationData locationData = await location.getLocation();

      currentPosition.value = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );
      initialPosition.value = currentPosition.value!;

      mapController.move(initialPosition.value, initialZoom);
    } catch (e) {
      log("Error getting location: $e");
    }
  }

  Future<void> navigateToCurrentLocation() async {
    try {
      LocationData locationData = await location.getLocation();

      currentPosition.value = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );

      mapController.move(currentPosition.value!, initialZoom);
    } catch (e) {
      log("Error getting location: $e");
    }
  }

  Future<bool> hasUserJoinedAnyRide() async {
    if (currentUserId.value.isEmpty) return false;

    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection("users").get();
      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;

        final ridesSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("rides")
            .get();

        for (var rideDoc in ridesSnapshot.docs) {
          final joinedUserDoc = await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .collection("rides")
              .doc(rideDoc.id)
              .collection("joinedUsers")
              .doc(currentUserId.value)
              .get();

          if (joinedUserDoc.exists) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      log("Error checking if user has joined rides: $e");
      return false;
    }
  }

  Future<void> forceRefreshRoute() async {
    animationTimer?.cancel();
    clearMapMarkersAndPolylines();
    await loadActiveRideRoute();
  }

  Future<void> navigateToCreateRide(bool hasActiveRide) async {
    if (hasActiveRide) {
      UIUtils.showAlreadyHasRideDialog(
        context: Get.context!,
        isCreating: true,
        hasActiveRide: hasActiveRide,
        onRideDeleted: clearMapMarkersAndPolylines,
      );
      return;
    }

    final bool hasJoinedRide = await hasUserJoinedAnyRide();
    if (hasJoinedRide) {
      UIUtils.showAlreadyJoinedRideDialog(
        context: Get.context!,
        onRideDeleted: clearMapMarkersAndPolylines,
      );
    } else {
      Get.toNamed(AppRoutes.createRide)?.then((value) {
        if (value == true) {
          loadActiveRideRoute();
        }
      });
    }
  }

  Future<void> navigateToJoiningRide(bool hasActiveRide) async {
    if (hasActiveRide) {
      UIUtils.showAlreadyHasRideDialog(
        context: Get.context!,
        isCreating: true,
        hasActiveRide: hasActiveRide,
        onRideDeleted: clearMapMarkersAndPolylines,
      );
      return;
    }

    final bool hasJoinedRide = await hasUserJoinedAnyRide();
    if (hasJoinedRide) {
      UIUtils.showAlreadyJoinedRideDialog(
        context: Get.context!,
        onRideDeleted: clearMapMarkersAndPolylines,
      );
    } else {
      Get.toNamed(AppRoutes.joiningRide)?.then((value) {
        if (value == true) {
          loadActiveRideRoute();
        }
      });
    }
  }

  Future<void> navigateToRequestRide(bool hasActiveRide) async {
    if (hasActiveRide) {
      UIUtils.showAlreadyHasRideDialog(
        context: Get.context!,
        isCreating: false,
        hasActiveRide: hasActiveRide,
        onRideDeleted: clearMapMarkersAndPolylines,
      );
      return;
    }

    final bool hasJoinedRide = await hasUserJoinedAnyRide();
    if (hasJoinedRide) {
      UIUtils.showAlreadyJoinedRideDialog(
        context: Get.context!,
        onRideDeleted: clearMapMarkersAndPolylines,
      );
    } else {
      Get.toNamed(AppRoutes.rideRequestHub)?.then((value) {
        if (value == true) {
          loadActiveRideRoute();
        }
      });
    }
  }
}
