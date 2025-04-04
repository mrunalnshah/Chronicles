import 'package:flutter/material.dart';

class CustomActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final double borderWidth;
  final double width;
  final double height;
  final double borderRadius;
  final double fontSize;

  const CustomActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
    this.borderColor = Colors.blue,
    this.borderWidth = 2.0,
    this.width = 120,
    this.height = 40,
    this.borderRadius = 8,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(color: borderColor, width: borderWidth),
          ),
          elevation: 0,
        ),
        child: Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
