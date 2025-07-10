import 'package:flutter/material.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_color.dart';

class GenderSelector extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String?> onChanged;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.grey[800]!, width: 1.0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 8.0),
            child: Text(
              AppStrings.selectGender,
              style: AppTextStyles.labelMediumlight,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text(
                    AppStrings.male,
                    style: AppTextStyles.bodyMediumwhite,
                  ),
                  value: AppStrings.male,
                  groupValue: selectedGender,
                  activeColor: CustomColors.accent,
                  onChanged: onChanged,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text(
                    AppStrings.female,
                    style: AppTextStyles.bodyMediumwhite,
                  ),
                  value: AppStrings.female,
                  groupValue: selectedGender,
                  activeColor: CustomColors.accent,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text(
                    AppStrings.other,
                    style: AppTextStyles.bodyMediumwhite,
                  ),
                  value: AppStrings.other,
                  groupValue: selectedGender,
                  activeColor: CustomColors.accent,
                  onChanged: onChanged,
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}
