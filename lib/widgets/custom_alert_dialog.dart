import 'package:flutter/material.dart';
import 'package:dormlanders/widgets/custom_button.dart';
import 'package:dormlanders/widgets/custom_image_display.dart';

// ALERT DIALOG CUSTOM CLASS
class CustomAlertDialog extends StatelessWidget {
  final String message;
  final Color backGroundColor;
  final VoidCallback onPressed;

  const CustomAlertDialog({
    super.key,
    required this.message,
    required this.backGroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: backGroundColor,
      elevation: 10.0,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: CustomImageDisplay(
              receivedImageLocation: "images/dormlanders_logo.png",
              receivedPaddingLeft: 0,
              receivedPaddingRight: 0,
              receivedPaddingTop: 0,
              receivedPaddingBottom: 0,
              receivedImageWidth: 140,
              receivedImageHeight: 50,
            ),
          ),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3C3C40),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        PrimaryCustomButton(
          buttonText: "OK",
          onPressed: onPressed,
          buttonHeight: 55,
          buttonColor: const Color(0xFF193147),
          fontWeight: FontWeight.normal,
          fontSize: 13,
          fontColor: Colors.white,
          elevation: 1,
          borderRadius: 10,
        ),
      ],
    );
  }
}
