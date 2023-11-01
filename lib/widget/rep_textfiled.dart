import 'package:flutter/material.dart';
//
import 'package:proyecto_flutter/utils/constants.dart';

class RepTextFiled extends StatelessWidget {
  final TextEditingController? controller;
  final IconData icon;
  final Widget? suficon;
  final String text;
  RepTextFiled({
    this.controller,
    required this.icon,
    required this.text,
    required this.suficon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: gHeight / 15,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 30,
            ),
            SizedBox(width: 10),
            SizedBox(
              height: 50,
              width: gWidth / 1.3,
              child: TextField(
                controller: controller,
                readOnly: false, // * Just for Debug
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black),
                showCursor: true,
                // cursorColor:Colors.red,
                decoration: InputDecoration(
                  suffixIcon: suficon,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2),
                  ),
                  labelText: text,
                  labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.w400),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
