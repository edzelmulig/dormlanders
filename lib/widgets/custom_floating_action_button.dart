import 'package:flutter/material.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';

class CustomFloatingActionButton extends StatelessWidget {
  // PARAMETERS NEEDED
  final String textLabel;
  final VoidCallback onPressed;

  // CONSTRUCTORS FOR CREATING NEW INSTANCE/OBJECT
  const CustomFloatingActionButton({
    super.key,
    required this.textLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      icon: const Icon(
        Icons.add,
        color: Color(0xFFF5F5F5),
        size: 25,
      ),
      label: Container(
        margin: const EdgeInsets.only(left: 5, right: 5),
        child: CustomTextDisplay(
          receivedText: textLabel,
          receivedTextSize: 15,
          receivedTextWeight: FontWeight.w500,
          receivedLetterSpacing: 0,
          receivedTextColor: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFF279778),
    );
  }
}
