import 'package:flutter/material.dart';

import '../theme/brutal_theme.dart';

class BrutalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const BrutalTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: BrutalColors.ink, width: 2.5),
    );

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: BrutalColors.ink, fontSize: 16, fontWeight: FontWeight.w600),
      cursorColor: BrutalColors.ink,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.45), fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: BrutalColors.ink),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: BrutalColors.cream,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: border,
        enabledBorder: border,
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: BrutalColors.purple, width: 3),
        ),
      ),
    );
  }
}
