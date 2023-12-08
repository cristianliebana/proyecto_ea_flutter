import 'package:flutter/material.dart';
import 'package:proyecto_flutter/screens/review.dart';
import 'package:get/get.dart';

class ChatMessageItem extends StatelessWidget {
  final bool isMeChatting;
  final String messageBody;
  final bool isReviewLink;

  ChatMessageItem({
    required this.isMeChatting,
    required this.messageBody,
    required this.isReviewLink,
  });

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
          color: isReviewLink
              ? Color.fromARGB(255, 34, 230, 184) // Color para mensajes de revisión
              : isMeChatting
                  ? Color(0xFF486D28)
                  : Color.fromARGB(255, 97, 76, 61),
        ),
        margin: EdgeInsets.all(10),
        child: isReviewLink
            ? GestureDetector(
                onTap: () {
                  if (!isMeChatting) {
                    print("Review Link Tapped");
                    Get.to(ReviewScreen());
                  }
                },
                child: Text(
                  messageBody,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isReviewLink
                        ? Color(0xFFFFFCEA) // Cambiado el color del texto para mensajes de revisión
                        : isMeChatting
                            ? Color(0xFFFFFCEA)
                            : Colors.black,
                  ),
                  textAlign: TextAlign.start,
                ),
              )
            : Text(
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
