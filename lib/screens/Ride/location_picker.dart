import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_appbar.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/common/elevated_button.dart';
import 'package:synapseride/controller/location_picker_controller.dart';
import 'package:synapseride/utils/utility.dart';

class LocationPickerScreen extends StatelessWidget {
  LocationPickerScreen({super.key});

  final LocationPickerController controller = Get.put(LocationPickerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.pickLocation,
      ),
      body: Obx(() => controller.isLoading.value
          ? UIUtils.circleloading()
          : Stack(
        children: [
          FlutterMap(
            mapController: controller.mapController,
            options: MapOptions(
              initialCenter: controller.selectedLocation.value,
              initialZoom: 15.0,
              onMapEvent: (MapEvent mapEvent) {
                if (mapEvent is MapEventMoveEnd) {
                  controller.onMapMoveEnd();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.synapseride.app',
              ),
              if (controller.currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: controller.currentLocation!,
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const Center(
            child: Icon(
              Icons.location_pin,
              color: CustomColors.error,
              size: 36,
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'current_location_btn',
              mini: true,
              backgroundColor: Colors.white,
              onPressed: controller.goToCurrentLocation,
              child: const Icon(
                Icons.my_location,
                color: Colors.blue,
              ),
            ),
          ),
          Positioned(
            top: 80,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoom_in_btn',
                  backgroundColor: Colors.white,
                  onPressed: controller.zoomIn,
                  child: const Icon(Icons.add, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoom_out_btn',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: controller.zoomOut,
                  child: const Icon(Icons.remove, color: Colors.black54),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.selectedLocation,
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      'Lat: ${controller.selectedLocation.value.latitude.toStringAsFixed(6)}, '
                          'Lng: ${controller.selectedLocation.value.longitude.toStringAsFixed(6)}',
                      style: AppTextStyles.bodySmall,
                    )),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.address,
                      style: AppTextStyles.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      controller.address.value,
                      style: AppTextStyles.bodySmall,
                    )),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            height: 55,
            child: CustomElevatedButton(
              label: AppStrings.confirmLocation,
              fullWidth: true,
              onPressed: () {
                Get.back(result: {
                  'address': controller.address.value,
                  'latitude': controller.selectedLocation.value.latitude,
                  'longitude': controller.selectedLocation.value.longitude,
                });
              },
            ),
          ),
        ],
      )),
    );
  }
}