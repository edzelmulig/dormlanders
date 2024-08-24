import 'package:flutter/material.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';

class CustomAppBar extends StatelessWidget {
  // PARAMETERS NEEDED
  final Color backgroundColor;
  final String titleText;
  final VoidCallback onLeadingPressed;

  // CONSTRUCTORS FOR CREATING NEW INSTANCE/OBJECT
  const CustomAppBar({
    super.key,
    required this.backgroundColor,
    this.titleText = "",
    required this.onLeadingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0.0,
      leading: IconButton(
        onPressed: onLeadingPressed,
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 25,
        ),
      ),
      centerTitle: true,
      title: CustomTextDisplay(
        receivedText: titleText,
        receivedTextSize: 17,
        receivedTextWeight: FontWeight.w500,
        receivedLetterSpacing: 0,
        receivedTextColor: const Color(0xFF3C3C40),
      ),
    );
  }
}
