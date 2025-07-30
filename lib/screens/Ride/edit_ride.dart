import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/Routes/routes.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_appbar.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/common/elevated_button.dart';
import 'package:synapseride/common/textformfield.dart';
import 'package:synapseride/controller/edit_ride_contoller.dart';
import 'package:synapseride/utils/utility.dart';

class EditRideScreen extends StatelessWidget {
  EditRideScreen({super.key});

  final EditRideController controller = Get.put(EditRideController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppStrings.editRide),
      body: Obx(() {
        return controller.isLoading.value
            ? UIUtils.circleloading()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.rideDetails,
                        style: AppTextStyles.headline4Light),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      showTitle: true,
                      title: 'Drop-Off',
                      hintText: AppStrings.address,
                      errorText: controller.addressError.value,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      controller: controller.addressController,
                      borderColor: CustomColors.background,
                      readOnly: true,
                      onTap: () {
                        Get.toNamed(AppRoutes.locationPicker)?.then((result) {
                          if (result != null &&
                              result is Map<String, dynamic>) {
                            controller.addressController.text =
                                result['address'];
                            controller.latitude.value = result['latitude'];
                            controller.longitude.value = result['longitude'];
                            controller.addressError.value = '';
                          }
                        });
                      },
                      suffixIcon: Icon(Icons.location_on,
                          color: CustomColors.background),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          controller.addressError.value =
                              AppStrings.enterAddress;
                          return AppStrings.enterAddress;
                        }
                        controller.addressError.value = '';
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    Text(AppStrings.leavingTime,
                        style: TextStyle(
                            color: CustomColors.background,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Obx(() {
                      final timeValidationMessage =
                          controller.getTimeValidationMessage();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => controller.selectTime(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                hintText: 'Enter leaving time',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  borderSide: BorderSide(
                                    color: timeValidationMessage != null
                                        ? Colors.red
                                        : CustomColors.background,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  borderSide: BorderSide(
                                    color: timeValidationMessage != null
                                        ? Colors.red
                                        : CustomColors.background,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.access_time,
                                  color: timeValidationMessage != null
                                      ? Colors.red
                                      : CustomColors.background,
                                ),
                              ),
                              child: Text(
                                UIUtils.formatTimeIn12HourFormat(
                                    controller.selectedTime.value),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: timeValidationMessage != null
                                      ? Colors.red
                                      : CustomColors.background,
                                ),
                              ),
                            ),
                          ),
                          if (timeValidationMessage != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              timeValidationMessage,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      );
                    }),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppStrings.vehicleDetails,
                            style: AppTextStyles.headline4),
                        Obx(() => Text(
                              'Seats available: ${controller.selectedSeats.value}',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: CustomColors.yellow1,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
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
                              onTap: () {
                                controller.selectedVehicle.value = 'car';
                                controller.showSeatSelectionBottomSheet();
                              },
                            ),
                            UIUtils.buildVehicleOption(
                              value: 'bike',
                              label: AppStrings.bike,
                              icon: Icons.motorcycle,
                              selectedVehicle: controller.selectedVehicle.value,
                              onTap: () {
                                controller.selectedVehicle.value = 'bike';
                                if (controller.selectedSeats.value > 1) {
                                  controller.selectedSeats.value = 1;
                                }
                                controller.showSeatSelectionBottomSheet();
                              },
                            ),
                          ],
                        )),
                    const SizedBox(height: 32),
                    Obx(() => CustomElevatedButton(
                      label: AppStrings.save,
                      isLoading: controller.isLoading.value,
                      fullWidth: true,
                      onPressed: () {
                        if (controller.canSaveChanges) {
                          controller.saveChanges();
                        }
                      },
                    )),
                  ],
                ),
              );
      }),
    );
  }
}
