import 'package:flutter/material.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';

class PrimaryCustomButton extends StatelessWidget {
  // PARAMETERS NEEDED
  final String buttonText;
  final VoidCallback onPressed;
  final double buttonHeight;
  final Color buttonColor;
  final FontWeight fontWeight;
  final double fontSize;
  final Color fontColor;
  final double elevation;
  final double borderRadius;
  final double? borderWidth;
  final Color? borderColor;

  // CONSTRUCTORS FOR CREATING NEW INSTANCE/OBJECT
  const PrimaryCustomButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    required this.buttonHeight,
    required this.buttonColor,
    required this.fontWeight,
    required this.fontSize,
    required this.fontColor,
    required this.elevation,
    required this.borderRadius,
    this.borderWidth = 1.0,
    this.borderColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: elevation,
        backgroundColor: buttonColor,
        foregroundColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            color: borderColor!,
            width: borderWidth!,
          )
        ),
        minimumSize: Size(double.infinity, buttonHeight),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // BUTTON TEXT
          CustomTextDisplay(
            receivedText: buttonText,
            receivedTextSize: fontSize,
            receivedTextWeight: fontWeight,
            receivedLetterSpacing: 0,
            receivedTextColor: fontColor,
          ),
        ],
      ),
    );
  }
}
