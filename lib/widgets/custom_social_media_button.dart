import 'package:flutter/material.dart';

// CUSTOM CLASS THAT WILL HANDLE SOCIAL MEDIA BUTTONS
class SocialMediaButton extends StatelessWidget {
  final String receivedLogo;
  final String receivedText;
  final double receivedTextSize;
  final double receivedBorderRadius;
  final FontWeight receivedFontWeight;
  final Color receivedColor;
  final VoidCallback receivedCallback;

  const SocialMediaButton({
    super.key,
    required this.receivedLogo,
    required this.receivedText,
    required this.receivedTextSize,
    required this.receivedBorderRadius,
    required this.receivedFontWeight,
    required this.receivedColor,
    required this.receivedCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 50, right: 50),
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: receivedCallback,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(receivedBorderRadius),
          ),
          backgroundColor: receivedColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center elements in Row
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 13,
                child: Image.asset(
                  receivedLogo,
                  width: 24, // Adjusted logo size for better centering
                  height: 24,
                ),
              ),
            ),
            const SizedBox(width: 10), // Space between logo and text
            Text(
              receivedText,
              style: TextStyle(
                color: Colors.white,
                fontSize: receivedTextSize,
                fontWeight: receivedFontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
