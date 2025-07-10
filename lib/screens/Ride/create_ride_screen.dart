import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:synapseride/Routes/routes.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_appbar.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/common/elevated_button.dart';
import 'package:synapseride/common/textformfield.dart';
import 'package:synapseride/controller/create_ride_controller.dart';
import 'package:synapseride/utils/utility.dart';

class CreateRideScreen extends StatelessWidget {
  CreateRideScreen({super.key});

  final CreateRideController controller = Get.put(CreateRideController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.createRide,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? UIUtils.circleloading()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.userDetails,
                      style: AppTextStyles.headline4Light,
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      showTitle: true,
                      title: AppStrings.name,
                      hintText: AppStrings.name,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      controller: controller.nameController,
                      readOnly: true,
                      validator: (value) => null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            showTitle: true,
                            title: AppStrings.address,
                            hintText: AppStrings.address,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            controller: controller.addressController,
                            readOnly: true,
                            maxLines: 2,
                            validator: (value) => null,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Get.toNamed(AppRoutes.locationPicker)
                                ?.then((value) {
                              if (value != null) {
                                controller.addressController.text =
                                    value['address'];
                                controller.destinationPosition.value = LatLng(
                                    value['latitude'], value['longitude']);
                              }
                            });
                          },
                          child: Text(
                            AppStrings.change,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: CustomColors.yellow1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      showTitle: true,
                      title: AppStrings.phoneNumber,
                      hintText: AppStrings.phoneNumber,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      controller: controller.phoneController,
                      readOnly: true,
                      validator: (value) => null,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.rideDetails,
                      style: AppTextStyles.headline4Light,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => controller.selectTime(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          hintText: 'Enter leaving time',
                          label: Text(
                            AppStrings.leavingTime,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: CustomColors.background,
                            ),
                          ),
                          border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          prefixIcon: const Icon(
                            Icons.access_time,
                            color: CustomColors.background,
                          ),
                        ),
                        child: Obx(() => Text(
                              UIUtils.formatTimeIn12HourFormat(
                                  controller.selectedTime.value),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: CustomColors.background,
                              ),
                            )),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.vehicleDetails,
                          style: AppTextStyles.headline4,
                        ),
                        Obx(() => controller.selectedVehicle.value != ''
                            ? Text(
                                'Seats available: ${controller.selectedSeats.value}',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: CustomColors.yellow1,
                                ),
                              )
                            : const SizedBox.shrink()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Obx(() => GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            UIUtils.buildVehicleOption(
                              value: 'car',
                              label: AppStrings.car,
                              icon: Icons.directions_car,
                              selectedVehicle: controller.selectedVehicle.value,
                              onTap: () =>
                                  controller.handleVehicleSelection('car'),
                            ),
                            UIUtils.buildVehicleOption(
                              value: 'bike',
                              label: AppStrings.bike,
                              icon: Icons.motorcycle,
                              selectedVehicle: controller.selectedVehicle.value,
                              onTap: () =>
                                  controller.handleVehicleSelection('bike'),
                            ),
                          ],
                        )),
                    const SizedBox(height: 32),
                    Obx(() => CustomElevatedButton(
                          label: controller.isRouteLoading.value
                              ? 'Processing...'
                              : AppStrings.generate,
                          isLoading: controller.isLoading.value ||
                              controller.isRouteLoading.value,
                          fullWidth: true,
                          onPressed: () async {
                            if (controller.addressController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(AppStrings.selectAddress)),
                              );
                              return;
                            }
                            if (controller.selectedSeats.value == 0) {
                              UIUtils.showAlertDialog(
                                context: context,
                                title: AppStrings.error,
                                message: AppStrings.selectSeatsError,
                              );
                              return;
                            }
                            await controller.getRoutePoints();
                          },
                        )),
                  ],
                ),
              ),
      ),
    );
  }
}
