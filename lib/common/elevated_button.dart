import 'package:flutter/material.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/utils/utility.dart';

class CustomElevatedButton extends StatelessWidget {
  final String label;
  final Function() onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? width;
  final double borderRadius;
  final IconData? icon;
  final bool fullWidth;

  const CustomElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.width,
    this.borderRadius = 12.0,
    this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 55,
      width: fullWidth ? double.infinity : width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? CustomColors.yellow1,
          foregroundColor: textColor ?? CustomColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          disabledBackgroundColor: backgroundColor?.withOpacity(0.7) ??
              CustomColors.yellow1.withOpacity(0.7),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: UIUtils.circleloading(
                    color: textColor ?? CustomColors.textPrimary))
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: textColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.buttonText.copyWith(
                      color: textColor ?? CustomColors.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
