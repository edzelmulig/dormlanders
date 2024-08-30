import 'package:flutter/material.dart';

class VerifiedDisplayNameWidget extends StatelessWidget {
  final String displayName;
  final double fontSize;
  final FontWeight fontWeight;
  final double iconSize;

  const VerifiedDisplayNameWidget({
    super.key,
    required this.displayName,
    required this.fontSize,
    required this.fontWeight,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RichText(
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        text: TextSpan(
          children: [
            // DISPLAY
            TextSpan(
              text: "$displayName ",
              style: TextStyle(
                color: const Color(0xFF3C4D48),
                fontWeight: fontWeight,
                fontSize: fontSize,
              ),
            ),
            // VERIFIED ICON
            WidgetSpan(
              child: Icon(
                Icons.verified_rounded,
                color: const Color(0xFF193147),
                size: iconSize,
              ),
              alignment: PlaceholderAlignment.middle,
            ),
          ],
        ),
      ),
    );
  }
}
