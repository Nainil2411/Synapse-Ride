import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_color.dart';

class CommonWidgets {
  static Widget buildGlassCard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? borderColor,
    List<Color>? gradientColors,
    double borderRadius = 22,
    bool showShadow = false,
    Color? shadowColor,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.90),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: showShadow ? [
                BoxShadow(
                  color: shadowColor ?? CustomColors.yellow1.withOpacity(0.20),
                  blurRadius: 32,
                  spreadRadius: 6,
                  offset: Offset(0, 8),
                ),
              ] : null,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors ?? [
                  Colors.black,
                  CustomColors.yellow1.withOpacity(0.055),
                ],
              ),
              border: Border.all(
                color: borderColor ?? CustomColors.yellow1.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  static Widget buildAnimatedCard({
    required Widget child,
    required int index,
    Duration? duration,
    Curve? curve,
  }) {
    return TweenAnimationBuilder(
      duration: duration ?? Duration(milliseconds: 300 + (index * 70)),
      curve: curve ?? Curves.easeOutBack,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 40),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  static Widget buildScreenHeader({
    required String title,
    required String subtitle,
    IconData? icon,
    Color? iconColor,
    Color? titleColor,
    Color? subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CustomColors.yellow1.withOpacity(0.2),
            CustomColors.yellow1.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CustomColors.yellow1.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 48,
              color: iconColor ?? CustomColors.yellow1,
            ),
            const SizedBox(height: 12),
          ],
          Text(
            title,
            style: AppTextStyles.headline4Light.copyWith(
              color: titleColor ?? CustomColors.yellow1,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: subtitleColor ?? Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Widget buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool showBadge = false,
    String? badgeText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: buildGlassCard(
        padding: const EdgeInsets.all(20),
        borderColor: color.withOpacity(0.3),
        gradientColors: [
          Colors.black.withOpacity(0.9),
          color.withOpacity(0.1),
        ],
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                if (showBadge)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: CustomColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      if (showBadge && badgeText != null)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: CustomColors.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color.withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomColors.yellow1.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.labelMedium.copyWith(
            color: CustomColors.yellow1.withOpacity(0.8),
          ),
          prefixIcon: Icon(icon, color: CustomColors.yellow1),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
