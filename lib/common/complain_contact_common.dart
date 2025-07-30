import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_color.dart';

// ==================== COMMON HEADER ====================
class CommonHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;

  const CommonHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CustomColors.yellow1.withOpacity(0.1),
            CustomColors.yellow1.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CustomColors.yellow1.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CustomColors.yellow1.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? CustomColors.yellow1,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: CustomColors.background,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: CustomColors.grey400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== COMMON FORM FIELD ====================
class CommonFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final RxBool errorObs;
  final String errorText;
  final int maxLines;
  final bool showIcon;

  const CommonFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.keyboardType,
    this.inputFormatters,
    required this.errorObs,
    required this.errorText,
    this.maxLines = 1,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: CustomColors.background,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[900]?.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: errorObs.value
                  ? CustomColors.error.withOpacity(0.5)
                  : CustomColors.grey700.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            style: AppTextStyles.bodyMedium.copyWith(
              color: CustomColors.background,
              height: maxLines > 1 ? 1.5 : null,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: CustomColors.grey400,
              ),
              suffixIcon: showIcon && icon != null
                  ? Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CustomColors.yellow1.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: CustomColors.yellow1,
                  size: 20,
                ),
              )
                  : null,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.all(maxLines > 1 ? 20 : 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: CustomColors.yellow1.withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        if (errorObs.value) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: CustomColors.error,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                errorText,
                style: AppTextStyles.bodySmall.copyWith(
                  color: CustomColors.error,
                ),
              ),
            ],
          ),
        ],
      ],
    ));
  }
}

// ==================== COMMON SUBMIT BUTTON ====================
class CommonSubmitButton extends StatelessWidget {
  final RxBool isLoading;
  final VoidCallback onPressed;
  final String text;
  final String loadingText;
  final IconData? icon;

  const CommonSubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.text,
    required this.loadingText,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isLoading.value
            ? LinearGradient(
          colors: [
            CustomColors.grey700,
            CustomColors.grey700.withOpacity(0.8),
          ],
        )
            : LinearGradient(
          colors: [
            CustomColors.yellow1,
            CustomColors.yellow1.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: isLoading.value
                ? Colors.transparent
                : CustomColors.yellow1.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading.value ? null : onPressed,
          child: Container(
            alignment: Alignment.center,
            child: isLoading.value
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      CustomColors.background,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  loadingText,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: CustomColors.background,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: Colors.black,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

// ==================== COMMON TAB BAR ====================
class CommonTabBar extends StatelessWidget {
  final TabController tabController;
  final List<CommonTab> tabs;

  const CommonTabBar({
    super.key,
    required this.tabController,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: CustomColors.grey700.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [
              CustomColors.yellow1.withOpacity(0.8),
              CustomColors.yellow1,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: CustomColors.yellow1.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.black,
        unselectedLabelColor: CustomColors.background,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        tabs: tabs
            .map((tab) => Tab(
          icon: Icon(tab.icon, size: 20),
          text: tab.text,
        ))
            .toList(),
      ),
    );
  }
}

class CommonTab {
  final IconData icon;
  final String text;

  const CommonTab({
    required this.icon,
    required this.text,
  });
}

// ==================== COMMON HISTORY CARD ====================
class CommonHistoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String date;
  final String id;
  final IconData icon;
  final Color iconColor;
  final Widget statusChip;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CommonHistoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.date,
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.statusChip,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CustomColors.grey700.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: iconColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: iconColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: CustomColors.background,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 12,
                                  color: CustomColors.grey400,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  date,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: CustomColors.grey400,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      statusChip,
                      const SizedBox(width: 8),
                      _buildDeleteButton(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CustomColors.grey700.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: CustomColors.background.withOpacity(0.9),
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: CustomColors.grey400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap to view details',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: CustomColors.grey400,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: CustomColors.yellow1.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: CustomColors.yellow1.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          'ID: $id',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: CustomColors.yellow1,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Container(
      decoration: BoxDecoration(
        color: CustomColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CustomColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onDelete,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.delete_outline_rounded,
              color: CustomColors.error,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== COMMON EMPTY STATE ====================
class CommonEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionText;

  const CommonEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: CustomColors.grey700.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: CustomColors.grey700.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: 64,
              color: CustomColors.grey700,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTextStyles.headline4.copyWith(
              color: CustomColors.background,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: CustomColors.grey400,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: CustomColors.yellow1.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: CustomColors.yellow1.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: CustomColors.yellow1,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  actionText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: CustomColors.yellow1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== COMMON STATUS CHIP ====================
class CommonStatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const CommonStatusChip({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== COMMON DIALOGS ====================
class CommonDialogs {
  static void showDeleteConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CustomColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: CustomColors.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: CustomColors.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: AppTextStyles.headline3.copyWith(
                  color: CustomColors.background,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: CustomColors.grey400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: CustomColors.grey700.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: CustomColors.grey700.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Get.back(),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: CustomColors.background,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            CustomColors.error,
                            CustomColors.error.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: CustomColors.error.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            onConfirm();
                            Get.back();
                          },
                          child: Center(
                            child: Text(
                              'Delete',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showDetailBottomSheet({
    required Map<String, dynamic> data,
    required String title,
    required IconData icon,
    required Color iconColor,
    List<DetailItem>? additionalDetails,
  }) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: CustomColors.grey700.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: CustomColors.grey700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: iconColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.headline3.copyWith(
                          color: CustomColors.background,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatDate(data['timestamp'] ?? data['date']),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: CustomColors.grey400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (additionalDetails != null) ...[
              ...additionalDetails.map((detail) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDetailRow(detail.label, detail.value, detail.icon),
              )),
              const SizedBox(height: 12),
            ],
            Text(
              'Description',
              style: AppTextStyles.labelLarge.copyWith(
                color: CustomColors.background,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CustomColors.grey700.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                data['description'] ?? data['message'] ?? 'No description',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: CustomColors.background,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  static Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: CustomColors.grey400,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: CustomColors.grey400,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: CustomColors.background,
            ),
          ),
        ),
      ],
    );
  }

  static String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Date not available';

    try {
      DateTime date;
      if (timestamp is DateTime) {
        date = timestamp;
      } else {
        date = timestamp.toDate();
      }
      return DateFormat('MMM d, yyyy - h:mm a').format(date);
    } catch (e) {
      return 'Date not available';
    }
  }
}

class DetailItem {
  final String label;
  final String value;
  final IconData icon;

  const DetailItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}