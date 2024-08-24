import 'package:flutter/material.dart';

class NoAvailableData extends StatelessWidget {
  final IconData icon;
  final String text;
  const NoAvailableData({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFc2c3c3),
                width: 2.0,
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFc2c3c3),
              size: 30,
            ),
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: <TextSpan>[
                const TextSpan(
                  text: "No data found\n",
                  style: TextStyle(
                    color: Color(0xFFc2c3c3),
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text:
                  "\nWhen you have $text you'll see\nthem here.",
                  style: const TextStyle(
                    color: Color(0xFFc2c3c3),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
