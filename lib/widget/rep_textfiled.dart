import 'package:flutter/material.dart';
import 'package:proyecto_flutter/utils/constants.dart';

class RepTextFiled extends StatefulWidget {
  final TextEditingController? controller;
  final TextEditingController? controller2;
  final IconData icon;
  final Widget? suficon;
  final String text;
  final bool obscureText;
  final VoidCallback?
      onToggleVisibility; // Agregamos esta función de control de visibilidad

  RepTextFiled({
    this.controller,
    this.controller2,
    required this.icon,
    required this.text,
    this.suficon,
    this.obscureText = false,
    this.onToggleVisibility,
  });

  @override
  _RepTextFiledState createState() => _RepTextFiledState();
}

class _RepTextFiledState extends State<RepTextFiled> {
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
              widget.icon,
              color: iconColor,
              size: 30,
            ),
            SizedBox(width: 10),
            SizedBox(
              height: 50,
              width: gWidth / 1.3,
              child: GestureDetector(
                onTap: () {
                  if (widget.onToggleVisibility != null) {
                    widget
                        .onToggleVisibility!(); // Llamamos a la función de control de visibilidad
                  }
                },
                child: TextField(
                  controller: widget.controller,
                  onChanged: (text) {
                    // Actualiza el segundo controlador si es necesario
                    if (widget.controller2 != null) {
                      widget.controller2!.text = text;
                    }
                    // Puedes realizar otras lógicas aquí si es necesario
                  },
                  readOnly: false,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black),
                  showCursor: true,
                  obscureText: widget.obscureText,
                  decoration: InputDecoration(
                    suffixIcon: widget.suficon != null
                        ? GestureDetector(
                            onTap: () {
                              if (widget.onToggleVisibility != null) {
                                widget.onToggleVisibility!();
                              }
                            },
                            child: widget.suficon,
                          )
                        : null,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),
                    labelText: widget.text,
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
