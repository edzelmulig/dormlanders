import 'package:flutter/material.dart';

// FLOATING SNACK BAR WITH ICON
void showFloatingSnackBarWithIcon(BuildContext context, String message, IconData icon, int duration) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(
              icon,
              color: Colors.white60,
            ),
          ),
          Text(message),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: const Color(0xFF333536),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: duration),
    ),
  );
}