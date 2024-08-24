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
    return SizedBox(
      width: 110,
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 13,
                child: Image.asset(
                  receivedLogo,
                  width: 30,
                  height: 30,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  receivedText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: receivedTextSize,
                    fontWeight: receivedFontWeight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}