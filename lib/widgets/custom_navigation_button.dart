import 'package:flutter/material.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';

class CustomNavigationButton extends StatelessWidget {
  final String textButton;
  final Color textColor;
  final VoidCallback onPressed;

  const CustomNavigationButton({
    super.key,
    required this.textButton,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFE7E7E9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          ),
          elevation: 0,
          minimumSize: const Size(double.infinity, 55),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            CustomTextDisplay(
              receivedText: textButton,
              receivedTextSize: 16,
              receivedTextWeight: FontWeight.w500,
              receivedLetterSpacing: 0,
              receivedTextColor: textColor,
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 17,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
