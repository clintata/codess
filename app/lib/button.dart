import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String? text;
  final Color? bgColor;
  final EdgeInsets? padding;
  final Widget? child;

  const MyButton(
      {super.key,
      required this.onTap,
      this.text,
      this.bgColor,
      this.padding,
      this.child});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 70, vertical: 20),
        decoration: BoxDecoration(
            color: bgColor ?? Colors.green[700],
            borderRadius: BorderRadius.circular(9)),
        child: Center(
          child: child ??
              Text(
                text ?? 'Error Button',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
        ),
      ),
    );
  }
}
