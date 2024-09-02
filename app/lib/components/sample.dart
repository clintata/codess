import 'package:flutter/material.dart';

class MySample extends StatelessWidget {
  const MySample({super.key});

  @override
  Widget build(BuildContext context) {
    return const TextField(
      decoration: InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: 'change email',
          labelStyle: TextStyle(fontSize: 14),
          hintText: 'clintituscantilang@gmail.com',
          hintStyle: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
    );
  }
}
