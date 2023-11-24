import 'package:flutter/material.dart';

class ChatMessageItem extends StatelessWidget {
  final bool isMeChatting;
  final String messageBody;

  const ChatMessageItem({
    Key? key,
    required this.isMeChatting,
    required this.messageBody,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMeChatting ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.65,
        ),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: isMeChatting
              ? BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                )
              : BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
          color: isMeChatting ? Color(0xFF486D28) : Color.fromARGB(255, 97, 76, 61),
        ),
        margin: EdgeInsets.all(10),
        child: Text(
          messageBody,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isMeChatting ? Color(0xFFFFFCEA) : Color(0xFFFFFCEA),
          ),
          textAlign: TextAlign.start,
        ),
      ),
    );
  }
}
