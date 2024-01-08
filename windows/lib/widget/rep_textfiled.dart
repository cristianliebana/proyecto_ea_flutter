import 'package:flutter/material.dart';
import 'package:proyecto_flutter/utils/constants.dart';

class RepTextFiled extends StatefulWidget {
  final TextEditingController? controller;
  final TextEditingController? controller2;
  final IconData icon;
  final Widget? suficon;
  final String text;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final ValueSetter<String>? onChanged;

  RepTextFiled({
    this.controller,
    this.controller2,
    required this.icon,
    required this.text,
    this.suficon,
    this.obscureText = false,
    this.onToggleVisibility,
    this.onChanged,
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
              color: Theme.of(context).colorScheme.onPrimary,
              size: 30,
            ),
            SizedBox(width: 10),
            SizedBox(
              height: 50,
              width: gWidth / 1.3,
              child: GestureDetector(
                onTap: () {
                  if (widget.onToggleVisibility != null) {
                    widget.onToggleVisibility!();
                  }
                },
                child: TextField(
                  controller: widget.controller,
                  onChanged: (text) {
                    if (widget.onChanged != null) {
                      widget.onChanged!(text);
                    }
                    if (widget.controller2 != null) {
                      widget.controller2!.text = text;
                    }
                  },
                  readOnly: false,
                  cursorColor: Theme.of(context).primaryColor,
                  style: TextStyle(color: Theme.of(context).primaryColor),
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
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).secondaryHeaderColor,
                          width: 2),
                    ),
                    labelText: widget.text,
                    labelStyle: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
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
