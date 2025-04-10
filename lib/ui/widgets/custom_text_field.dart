// lib/ui/widgets/custom_text_field.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isMultiline;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool isChinese;
  final IconData? prefixIcon;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.isMultiline = false,
    this.validator,
    this.keyboardType,
    this.isChinese = false,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: isMultiline ? null : 1,
      minLines: isMultiline ? 3 : 1,
      style: TextStyle(
        fontFamily: isChinese ? 'NotoSansSC' : null,
      ),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
    );
  }
}
