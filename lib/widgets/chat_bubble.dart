import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            isCurrentUser ? const Color(0xFF193147) : const Color(0xFFF1F0F5),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 12, left: 15, right: 15),
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 25),
      child: Text(
        message,
        style: TextStyle(
          color: isCurrentUser ? Colors.white : const Color(0xFF3C3C40),
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
