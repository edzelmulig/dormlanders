import 'package:flutter/material.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';

class CustomButtonWithNumber extends StatefulWidget {
  // PARAMETERS NEEDED
  final int numberOfServices;
  final String buttonText;
  final VoidCallback onPressed;

  const CustomButtonWithNumber({
    super.key,
    required this.numberOfServices,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  State<CustomButtonWithNumber> createState() => _CustomButtonWithNumberState();
}

class _CustomButtonWithNumberState extends State<CustomButtonWithNumber> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: const Color(0xFF3C4D48),
          foregroundColor: const Color(0xFFE7E7E9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: widget.onPressed,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                // NUMBER
                Container(
                  padding: const EdgeInsets.only(
                    left: 12,
                    top: 5,
                    right: 12,
                    bottom: 5,
                  ),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: CustomTextDisplay(
                    receivedText: "${widget.numberOfServices}",
                    receivedTextSize: 20,
                    receivedTextWeight: FontWeight.w900,
                    receivedLetterSpacing: 0,
                    receivedTextColor: const Color(
                        0xFF3C4D48),
                  ),
                ),

                // MY SERVICES TEXTS
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      const TextSpan(
                        text: "My\n",
                        style: TextStyle(
                          // Specify the style for "My"
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: widget.buttonText,
                        style: const TextStyle(
                          // Specify the style for "Services"
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // SPACER
                const Spacer(),

                Container(
                  margin: const EdgeInsets.only(
                    top: 20,
                    right: 10,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: Colors.white,
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

