import 'package:flutter/material.dart';
import 'package:dormlanders/widgets/custom_button.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        if (_) {
          return;
        }
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // NO WIFI ICON
              const Icon(
                Icons.wifi_off_outlined,
                color: Color(0xFFBDBDC7),
                size: 90,
              ),

              // SIZED BOX: SPACING
              const SizedBox(height: 5),

              // MAIN TEXT
              const CustomTextDisplay(
                receivedText: "No internet connection",
                receivedTextSize: 20,
                receivedTextWeight: FontWeight.w700,
                receivedLetterSpacing: 0,
                receivedTextColor: Color(0xFF64666B),
              ),

              // SECONDARY TEXT
              const CustomTextDisplay(
                receivedText: "Reconnect your Wi-Fi and try again.",
                receivedTextSize: 15,
                receivedTextWeight: FontWeight.w500,
                receivedLetterSpacing: 0,
                receivedTextColor: Color(0xFF6E7174),
              ),

              // SIZED BOX: SPACING
              const SizedBox(height: 20),

              // TRY BUTTON
              Padding(
                padding: const EdgeInsets.only(left: 80, right: 80),
                child: PrimaryCustomButton(
                  buttonText: "Try again",
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  buttonHeight: 45,
                  buttonColor: const Color(0xFFF0F1F3),
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  fontColor: const Color(0xFF64666B),
                  elevation: 0,
                  borderRadius: 7,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
