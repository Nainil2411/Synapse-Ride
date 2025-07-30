import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/Routes/routes.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/common/elevated_button.dart';

class UIUtils {
  static Widget? keyboardDismiss(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
    return null;
  }

  static Widget circleloading({Color? color}) {
    return Center(
      child: CircularProgressIndicator(
        color: color ?? CustomColors.yellow1,
      ),
    );
  }

  static Widget buildGlassContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? borderColor,
    double borderRadius = 20,
    List<Color>? gradientColors,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.90),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? CustomColors.yellow1.withOpacity(0.3),
              width: 1,
            ),
            gradient: LinearGradient(
              begin
                  : Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors ??
                  [
                    Colors.black,
                    CustomColors.yellow1.withOpacity(0.055),
                  ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  static Widget buildStatusBadge({
    required String status,
    String? timeStatus,
    Color? activeColor,
    Color? inactiveColor,
  }) {
    final bool isActive =
        status == 'active' || status == 'ACCEPTED' || status == 'NORMAL';
    final Color badgeColor = isActive
        ? (activeColor ?? CustomColors.green1)
        : (inactiveColor ?? CustomColors.error);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$status${timeStatus ?? ''}',
        style: AppTextStyles.labelSmall.copyWith(
          color: isActive ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  static Widget buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
    Color? labelColor,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? CustomColors.yellow1, size: 17),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: AppTextStyles.labelSmall.copyWith(
              color: labelColor ?? CustomColors.yellow1.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: AppTextStyles.bodySmall.copyWith(
                color: valueColor ?? Colors.white.withOpacity(0.95),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildRouteInfo({
    required String fromAddress,
    required String toAddress,
    Color? containerColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: containerColor ?? Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor ?? CustomColors.yellow1.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: CustomColors.green1,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fromAddress,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 2,
                height: 20,
                color: CustomColors.yellow1.withOpacity(0.5),
                margin: const EdgeInsets.only(left: 3),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: CustomColors.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  toAddress,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildActionButtonRow({
    required List<ActionButtonConfig> buttons,
  }) {
    return Row(
      children: buttons
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final button = entry.value;

            return [
              Expanded(
                child: CustomElevatedButton(
                  label: button.label,
                  onPressed: button.onPressed ?? () {},
                  backgroundColor: button.backgroundColor,
                  textColor: button.textColor,
                  icon: button.icon,
                  isLoading: button.isLoading ?? false,
                ),
              ),
              if (index < buttons.length - 1) const SizedBox(width: 12),
            ];
          })
          .expand((element) => element)
          .toList(),
    );
  }

  static Widget buildSectionTitle({
    required String title,
    Color? color,
    double? fontSize,
  }) {
    return Text(
      title,
      style: AppTextStyles.labelLarge.copyWith(
        color: color ?? CustomColors.yellow1,
        fontWeight: FontWeight.bold,
        fontSize: fontSize ?? 18,
      ),
    );
  }

  static Widget buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: iconColor ?? CustomColors.yellow1,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.headline4Light,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static void showSuccessDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onComplete,
    int countdownSeconds = 3,
  }) {
    int countdown = countdownSeconds;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future.delayed(const Duration(seconds: 1), () {
              if (countdown > 1) {
                setState(() {
                  countdown--;
                });
              } else {
                Get.back();
                onComplete();
              }
            });

            return Dialog(
              backgroundColor: CustomColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                constraints: const BoxConstraints(
                  minHeight: 200,
                  maxHeight: 300,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: CustomColors.green1.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.check,
                        color: CustomColors.green1,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: AppTextStyles.labelLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        message,
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${AppStrings.closingIn} $countdown...',
                      style: AppTextStyles.successText.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Future<int?> showSeatSelectionBottomSheet({
    required BuildContext context,
    required String vehicleType,
    required int initialSeats,
    required int maxSeats,
  }) async {
    int tempSelectedSeats = initialSeats;
    int? result;

    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: CustomColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.selectSeats,
                        style: AppTextStyles.headline4.copyWith(color: CustomColors.textPrimary),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: CustomColors.textPrimary),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: List.generate(maxSeats, (index) {
                      final seatNumber = index + 1;
                      final isSelected = tempSelectedSeats == seatNumber;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            tempSelectedSeats = seatNumber;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? CustomColors.yellow1 : CustomColors.background,
                            border: Border.all(
                              color: CustomColors.textPrimary,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$seatNumber',
                            style: TextStyle(
                              color: CustomColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: CustomElevatedButton(
                      label: AppStrings.confirm,
                      onPressed: () {
                        result = tempSelectedSeats;
                        Get.back();
                      },
                      fullWidth: true,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    return result;
  }

  static Widget buildVehicleOption({
    required String value,
    required String label,
    required IconData icon,
    required String selectedVehicle,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedVehicle == value;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? CustomColors.yellow1 : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CustomColors.yellow1,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: isSelected
                  ? CustomColors.textPrimary
                  : CustomColors.background,
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected
                    ? CustomColors.textPrimary
                    : CustomColors.background,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            title,
            style: AppTextStyles.headline4Light,
          ),
          content: Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(color: CustomColors.background),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                AppStrings.ok,
                style: AppTextStyles.bodyMedium.copyWith(color: CustomColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<TimeOfDay?> showTimePickerDialog({
    required BuildContext context,
    required TimeOfDay initialTime,
  }) async {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: Theme.of(context).copyWith(
              dialogBackgroundColor: CustomColors.background,
              colorScheme: ColorScheme.light(
                primary: CustomColors.yellow1,
                onPrimary: CustomColors.textPrimary,
                surface: CustomColors.background,
                onSurface: CustomColors.textPrimary,
                onSecondary: CustomColors.textPrimary,
              ),
              textTheme: Theme.of(context).textTheme.copyWith(
                bodyLarge: TextStyle(color: CustomColors.textPrimary),
                bodyMedium: TextStyle(color: CustomColors.textPrimary),
                labelLarge: TextStyle(color: CustomColors.textPrimary),
                labelMedium: TextStyle(color: CustomColors.textPrimary),
                labelSmall: TextStyle(color: CustomColors.textPrimary),
              ),
            ),
            child: child!,
          ),
        );
      },
    );
  }

  static String formatTimeIn12HourFormat(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? additionalMessage,
    String cancelText = 'Cancel',
    String confirmText = 'Confirm',
    Color? cancelColor,
    Color? confirmColor,
  }) async {
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            title,
            style: AppTextStyles.headline4Light,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(color: CustomColors.background),
                ),
                if (additionalMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    additionalMessage,
                    style: AppTextStyles.bodyMedium.copyWith(color: CustomColors.background),
                  ),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                cancelText,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: cancelColor ?? CustomColors.background,
                ),
              ),
              onPressed: () => Get.back(result: false),
            ),
            TextButton(
              child: Text(
                confirmText,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: confirmColor ?? CustomColors.error,
                ),
              ),
              onPressed: () => Get.back(result: true),
            ),
          ],
        );

      },
    );
    return result ?? false;
  }

  static Future<bool> showConfirmDeleteDialog({
    required BuildContext context,
    String? title,
    String? message,
    String? cancelText,
    String? deleteText,
  }) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          title ?? AppStrings.delete,
          style: AppTextStyles.headline4Light,
        ),
        content: Text(
          message ?? AppStrings.confirmDeleteRide,
          style:
              AppTextStyles.bodyMedium.copyWith(color: CustomColors.background),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              cancelText ?? AppStrings.cancel,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: CustomColors.background),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              deleteText ?? AppStrings.delete,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: CustomColors.error),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<void> showAlreadyHasRideDialog({
    required BuildContext context,
    required bool isCreating,
    required bool hasActiveRide,
    required VoidCallback onRideDeleted,
  }) async {
    if (!hasActiveRide) return;
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: CustomColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 60,
                ),
                const SizedBox(height: 20),
                Text(
                  isCreating
                      ? AppStrings.rideInProgress
                      : AppStrings.cannotJoinRide,
                  style: AppTextStyles.headline4,
                ),
                const SizedBox(height: 10),
                Text(
                  isCreating
                      ? AppStrings.alreadyHasRideMessage
                      : AppStrings.alreadyJoinedRideMessage,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(
                        AppStrings.close,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: CustomColors.textPrimary,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                      ),
                      onPressed: () {
                        Get.back();
                        Get.toNamed(AppRoutes.rideHistory)?.then((deleteride) {
                          if (deleteride == true) {
                            onRideDeleted();
                          }
                        });
                      },
                      child: Text(
                        AppStrings.deleteRide,
                        style: AppTextStyles.buttonTextLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> showAlreadyJoinedRideDialog({
    required BuildContext context,
    required VoidCallback onRideDeleted,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: CustomColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 60,
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.alreadyJoinedRide,
                  style: AppTextStyles.headline4,
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.alreadyJoinedRideDescription,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: CustomColors.textSecondary,
                      ),
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(AppStrings.cancel),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColors.yellow1,
                        foregroundColor: CustomColors.textPrimary,
                      ),
                      onPressed: () {
                        Get.back();
                        Get.toNamed(AppRoutes.joinedRide)?.then((value) {
                          if (value == true) {
                            onRideDeleted();
                          }
                        });
                      },
                      child: Text(
                        AppStrings.viewJoinedRide,
                        style: AppTextStyles.buttonText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ActionButtonConfig {
  final String label;
  final Function()? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool? isLoading;

  ActionButtonConfig({
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading,
  });
}
