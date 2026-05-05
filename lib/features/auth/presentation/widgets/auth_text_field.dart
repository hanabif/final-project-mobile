import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.validator,
    this.keyboardType,
  });

  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF005C45);

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(fontFamily: 'Poppins'),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryColor),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
