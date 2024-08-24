import 'package:flutter/material.dart';

class CustomCameraIcon extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomCameraIcon({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      width: 37,
      height: 35,
      decoration: BoxDecoration(
        color: const Color(0xFF3C3C40),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFF5F5F5),
          width: 3.0,
        ),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.camera_alt,
          size: 15,
          color: Colors.white,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
