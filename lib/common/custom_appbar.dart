import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      title: Text(
        title,
        style: AppTextStyles.headline4.copyWith(
          color: foregroundColor ?? CustomColors.yellow1,
        ),
      ),
      backgroundColor: backgroundColor ?? CustomColors.textPrimary,
      foregroundColor: foregroundColor ?? CustomColors.yellow1,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: foregroundColor ?? CustomColors.yellow1,
              onPressed: onBackPressed ?? () => Get.back(),
            )
          : null,
      actions: actions,
      elevation: 0,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
