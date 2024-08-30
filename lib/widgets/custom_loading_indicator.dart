import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class CustomLoadingIndicator extends StatelessWidget {
  const CustomLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
        ),
        width: 50,
        height: 50,
        child: const LoadingIndicator(
          indicatorType: Indicator.ballSpinFadeLoader,
          colors: [Color(0xFF193147)],
        ),
      ),
    );
  }
}
