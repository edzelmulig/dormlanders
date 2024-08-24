import 'package:flutter/material.dart';

// CUSTOM CLASS FOR CUSTOM TEXT COMPONENT
class CustomTextDisplay extends StatelessWidget {
  final String receivedText;
  final double receivedTextSize;
  final FontWeight receivedTextWeight;
  final double receivedLetterSpacing;
  final Color receivedTextColor;

  const CustomTextDisplay({
    Key? key,
    required this.receivedText,
    required this.receivedTextSize,
    required this.receivedTextWeight,
    required this.receivedLetterSpacing,
    required this.receivedTextColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      receivedText,
      style: TextStyle(
        fontSize: receivedTextSize,
        fontWeight: receivedTextWeight,
        letterSpacing: receivedLetterSpacing,
        color: receivedTextColor,
      ),
    );
  }
}