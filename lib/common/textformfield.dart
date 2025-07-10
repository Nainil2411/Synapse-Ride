import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'custom_color.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final bool obscureText;
  final String? errorText;
  final Function(String)? onChanged;
  final Function()? onPressed;
  final Function()? onTap;
  final String? Function(String?)? validator;
  final bool showSuffixIcon;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final Color? borderColor;
  final Color? fillColor;
  final String? hintText;
  final bool showBorders;
  final List<TextInputFormatter>? inputFormatters;
  final Color? hintStyle;
  final bool readOnly;
  final TextInputAction? textInputAction;
  final InputDecoration? decoration;
  final String? title;
  final bool showTitle;
  final int? maxLines;
  final bool? hasError;
  final emojiRegex = '(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])';

  const CustomTextFormField({
    super.key,
    required this.controller,
    this.label,
    this.obscureText = false,
    this.errorText,
    this.onChanged,
    this.onPressed,
    this.onTap,
    this.validator,
    this.showSuffixIcon = false,
    this.suffixIcon,
    this.prefixIcon,
    this.keyboardType,
    this.borderColor,
    this.fillColor = Colors.transparent,
    this.hintText,
    this.showBorders = true,
    this.inputFormatters,
    this.hintStyle,
    this.readOnly = false,
    this.textInputAction,
    this.decoration,
    this.title,
    this.showTitle = false,
    this.maxLines = 1,
    this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              title!,
              style: TextStyle(
                  color: CustomColors.background, fontWeight: FontWeight.bold),
            ),
          ),
        TextFormField(
          style: TextStyle(color: CustomColors.background),
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          obscureText: obscureText,
          onChanged: onChanged,
          onTap: onTap,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters ??
              [ FilteringTextInputFormatter.deny(RegExp(emojiRegex))],
          decoration: InputDecoration(
            labelText: label,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: showBorders
                    ? (borderColor ?? CustomColors.grey300)
                    : Colors.transparent,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: showBorders
                    ? (borderColor ??
                    CustomColors.textSecondary.withOpacity(0.5))
                    : Colors.transparent,
                width: 1.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: showBorders ? CustomColors.error : Colors.transparent,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color:
                showBorders ? CustomColors.background : Colors.transparent,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: showBorders ? CustomColors.error : Colors.transparent,
                width: 1.0,
              ),
            ),
            errorText: errorText?.isEmpty == true ? null : errorText,
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(color: CustomColors.textSecondary),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: CustomColors.background)
                : null,
            suffixIcon: showSuffixIcon
                ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: onPressed,
            )
                : suffixIcon,
          ),
        ),
      ],
    );
  }
}
