import 'package:flutter/material.dart';

class NoServiceAvailable extends StatelessWidget {
  const NoServiceAvailable({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.only(top: 200, bottom: 10),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFc2c3c3),
                  width: 2,
                )),
            child: const Icon(
              Icons.archive,
              color: Color(0xFFc2c3c3),
              size: 40,
            ),
          ),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: "No services available\n",
                  style: TextStyle(
                    color: Color(0xFFc2c3c3),
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text:
                  "\nWhen you have services available, you'll see\nthem here.",
                  style: TextStyle(
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
