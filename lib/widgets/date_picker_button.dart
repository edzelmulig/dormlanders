import 'package:flutter/material.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';

class TimeSelectionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onPressed;

  const TimeSelectionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 10),
          child: Icon(
            icon,
            size: 25,
            color: const Color(0xFF3C4D48),
          ),
        ),
         CustomTextDisplay(
          receivedText: label,
          receivedTextSize: 15,
          receivedTextWeight: FontWeight.w500,
          receivedLetterSpacing: 0,
          receivedTextColor: const Color(0xFF3C4D48),
        ),
        const SizedBox(width: 20),
        const Spacer(),
        SizedBox(
          width: 165,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFE5E7EB),
              foregroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.zero,
            ),
            onPressed: onPressed,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
                right: 10,
                left: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CustomTextDisplay(
                    receivedText: value,
                    receivedTextSize: 16,
                    receivedTextWeight: FontWeight.w500,
                    receivedLetterSpacing: 0,
                    receivedTextColor: const Color(0xFF3C4D48),
                  ),
                  const Icon(
                    Icons.edit,
                    color: Color(0xFF3C4D48),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
