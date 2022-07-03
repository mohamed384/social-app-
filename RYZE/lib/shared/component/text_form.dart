import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ryze/shared/constants/constants.dart';

class TextForm extends StatelessWidget {
  final TextEditingController? controller;
  final String? label, initialValue;
  final TextStyle? style;
  final String? hintText;
  final IconData? prePhoto;
  final Widget? postPhoto;
  final FocusNode? focusNode;
  final TextInputType? keyType;
  final bool secureText, isFilled, isBorder;
  final ValueChanged<String>? onChange;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final double onFocusBorder, borderRadius;

  const TextForm(
      {Key? key,
      this.controller,
      this.label,
      this.style,
      this.hintText,
      this.prePhoto,
      this.postPhoto,
      this.focusNode,
      this.keyType,
      this.onChange,
      this.validator,
      this.readOnly = false,
      this.isBorder = true,
      this.isFilled = false,
      this.maxLines = 1,
      this.minLines,
      this.onFocusBorder = 20,
      this.borderRadius = 50,
      this.secureText = false,
      this.initialValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        focusNode: focusNode,
        initialValue: initialValue,
        controller: controller,
        style: style,
        readOnly: readOnly,
        decoration: InputDecoration(
            filled: isFilled,
            fillColor: HexColor('#f2f0f2'),
            labelText: label,
            labelStyle: TextStyle(
                fontSize: 14,
                color: Get.isDarkMode ? Colors.white : Colors.black87),
            floatingLabelStyle:
                const TextStyle(fontSize: 16, color: Colors.redAccent),
            hintText: hintText,
            hintStyle: TextStyle(
                color: Get.isDarkMode ? Colors.white : Colors.grey.shade500),
            contentPadding: const EdgeInsets.all(10),
            border: isBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  )
                : InputBorder.none,
            focusedBorder: isBorder
                ? OutlineInputBorder(
                    borderSide: const BorderSide(color: textColor1),
                    borderRadius: BorderRadius.circular(onFocusBorder),
                  )
                : InputBorder.none,
            prefixIcon: prePhoto != null
                ? Icon(
                    prePhoto,
                    color: Get.isDarkMode ? iconColor : Colors.black87,
                  )
                : null,
            suffixIcon: postPhoto),
        keyboardType: keyType,
        maxLines: maxLines,
        minLines: minLines,
        onChanged: onChange,
        validator: validator,
        obscureText: secureText);
  }
}
