import 'package:flutter/material.dart';

class CustomTextDescription extends StatelessWidget {
  final String descriptionText;
  final String hasLearnMore;

  const CustomTextDescription({
    super.key,
    required this.descriptionText,
    required this.hasLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 20,
        top: 15,
        right: 15,
        bottom: 5,
      ),
      child: RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: descriptionText,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF8C8C8C),
              ),
            ),
            TextSpan(
              text: hasLearnMore,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8C8C8C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
