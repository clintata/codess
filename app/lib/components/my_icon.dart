import 'package:flutter/material.dart';

class MyIcon extends StatelessWidget {
  final controller;
  final String hintText;
  final String labelText;
  final bool obsecureText;

  const MyIcon({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.obsecureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obsecureText,
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
          prefixIcon: const Icon(
            Icons.person,
            color: Color.fromARGB(255, 27, 106, 171),
          ),
        ),
      ),
    );
  }
}
