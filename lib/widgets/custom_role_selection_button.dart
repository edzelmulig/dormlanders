import 'package:flutter/material.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';

class CustomRoleSelectionButton extends StatefulWidget {
  // PARAMETERS NEEDED
  final bool isSelected;
  final String role;
  final String firstText;
  final String secondText;
  final IconData icon;
  final VoidCallback onPressed;


  const CustomRoleSelectionButton({
    super.key,
    required this.isSelected,
    required this.role,
    required this.firstText,
    required this.secondText,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<CustomRoleSelectionButton> createState() => _CustomRoleSelectionButtonState();
}

class _CustomRoleSelectionButtonState extends State<CustomRoleSelectionButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25),
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isSelected
              ? const Color(0xFFD7F5EC)
              : const Color(0xFFf7f7f7),
          foregroundColor: const Color(0xFFD7F5EC),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: widget.isSelected
                  ? const Color(0xFF279778)
                  : Colors.grey,
              width: 2.5,
            ),
          ),
        ),
        onPressed: widget.onPressed,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // CLIENT ICON
                Container(
                  margin: const EdgeInsets.only(
                    top: 20,
                    bottom: 10,
                  ),
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isSelected
                          ? const Color(0xFF279778)
                          : const Color(0xFF3C3C40),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  child: CustomTextDisplay(
                    receivedText: widget.firstText,
                    receivedTextSize: 19,
                    receivedTextWeight: FontWeight.w500,
                    receivedLetterSpacing: 0,
                    receivedTextColor: const Color(0xFF3C3C40),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  alignment: Alignment.topLeft,
                  child: CustomTextDisplay(
                    receivedText: widget.secondText,
                    receivedTextSize: 19,
                    receivedTextWeight: FontWeight.w500,
                    receivedLetterSpacing: 0,
                    receivedTextColor: const Color(0xFF3C3C40),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
