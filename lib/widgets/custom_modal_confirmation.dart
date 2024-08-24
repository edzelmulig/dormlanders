import 'package:flutter/material.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';

// MODAL BOTTOM FOR ACTION CONFIRMATION
void showConfirmationModal(
    BuildContext context,
    String textReminder,
    String textAction,
    Widget destinationScreen,
    ) {
  showModalBottomSheet(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(10),
      ),
    ),
    context: context,
    isDismissible: true,
    backgroundColor: Colors.white,
    elevation: 0,
    builder: (context) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 5),
              child: Center(
                child: CustomTextDisplay(
                  receivedText: textReminder,
                  receivedTextSize: 14,
                  receivedTextWeight: FontWeight.normal,
                  receivedLetterSpacing: 0,
                  receivedTextColor: const Color(0xFF868686),
                ),
              ),
            ),
            const Divider(
              color: Color(0xFFF7F5F5),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFE7E7E9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: CustomTextDisplay(
                  receivedText: textAction,
                  receivedTextSize: 16,
                  receivedTextWeight: FontWeight.w500,
                  receivedLetterSpacing: 0,
                  receivedTextColor: const Color(0xFFe91b4f),
                ),
              ),
            ),
            Container(
              height: 10,
              color: const Color(0xFFF5F5F5),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFE7E7E9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const CustomTextDisplay(
                  receivedText: "Cancel",
                  receivedTextSize: 16,
                  receivedTextWeight: FontWeight.normal,
                  receivedLetterSpacing: 0,
                  receivedTextColor: Color(0xFF3C3C40),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      );
    },
  );
}