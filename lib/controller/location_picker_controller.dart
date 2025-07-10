import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerController extends GetxController {
  final MapController mapController = MapController();
  Rx<LatLng> selectedLocation = LatLng(20.5937, 78.9629).obs;
  LatLng? currentLocation;
  RxBool isLoading = true.obs;
  RxString address = 'Fetching address...'.obs;
  bool isFetchingAddress = false;

  @override
  void onInit() {
    getCurrentLocation();
    super.onInit();
  }

  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          isLoading.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        isLoading.value = false;
        return;
      }
      final Position position = await Geolocator.getCurrentPosition();
      currentLocation = LatLng(position.latitude, position.longitude);
      selectedLocation.value = currentLocation!;
      isLoading.value = false;
      getAddressFromLatLng(selectedLocation.value);
      animateToLocation(selectedLocation.value);
    } catch (e) {
      isLoading.value = false;
    }
  }

  Future<void> getAddressFromLatLng(LatLng position) async {
    if (isFetchingAddress) return;

    isFetchingAddress = true;
    address.value = 'Fetching address...';

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        address.value = '${place.street ?? ''}, ${place.subLocality ?? ''}, '
            '${place.locality ?? ''}, ${place.postalCode ?? ''}, '
            '${place.administrativeArea ?? ''}, ${place.country ?? ''}';

        address.value = address.value.replaceAll(RegExp(r', ,'), ',');
        address.value = address.value.replaceAll(RegExp(r',,'), ',');
        address.value = address.value.replaceAll(RegExp(r'^, '), '');
        address.value = address.value.replaceAll(RegExp(r', $'), '');

        isFetchingAddress = false;
      }
    } catch (e) {
      address.value = 'Unable to fetch address';
      isFetchingAddress = false;
    }
  }

  void animateToLocation(LatLng location) {
    mapController.move(location, 15.0);
  }

  void onMapMoveEnd() {
    final center = mapController.camera.center;
    selectedLocation.value = center;
    getAddressFromLatLng(center);
  }

  void goToCurrentLocation() {
    if (currentLocation != null) {
      animateToLocation(currentLocation!);
    } else {
      getCurrentLocation();
    }
  }

  void zoomIn() {
    final currentZoom = mapController.camera.zoom;
    mapController.move(mapController.camera.center, currentZoom + 1);
  }

  void zoomOut() {
    final currentZoom = mapController.camera.zoom;
    mapController.move(mapController.camera.center, currentZoom - 1);
  }
}
