import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.obscureText,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: hintText,
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey[500]),
          hintStyle: TextStyle(color: Colors.grey[500]),
          suffixIcon: suffixIcon,
          prefixIcon: const Icon(
            Icons.lock,
            color: Color.fromARGB(255, 27, 106, 171),
          ),
        ),
      ),
    );
  }
}
