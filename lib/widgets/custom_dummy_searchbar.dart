import 'package:flutter/material.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';

class DummySearchBar extends StatelessWidget {
  final String hintText;
  final VoidCallback onPressed;

  const DummySearchBar({
    super.key,
    required this.hintText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 45),
      ),
      onPressed: onPressed,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // SEARCH ICON
          Padding(
            padding: EdgeInsets.only(left: 15, right: 10),
            child: Icon(
              Icons.search_rounded,
              size: 30,
              color: Color(0xFF7C7C7D),
            ),
          ),

          // HINT TEXT
          CustomTextDisplay(
            receivedText: "Search dormitory or location",
            receivedTextSize: 15,
            receivedTextWeight: FontWeight.normal,
            receivedLetterSpacing: 0,
            receivedTextColor: Color(0xFF7C7C7D),
          ),
        ],
      ),
    );
  }
}
