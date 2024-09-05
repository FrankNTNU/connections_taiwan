import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final bool isPrimary;
  final String text;
  final void Function() onPressed;
  final Color? backColor;
  final Color? foreColor;
  const ActionButton(
      {super.key,
      required this.text,
      this.isPrimary = true,
      required this.onPressed,
      this.foreColor,
      this.backColor});

  @override
  Widget build(BuildContext context) {
    final textWidget = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style:  TextStyle(fontSize: 16, color: foreColor),
      ),
    );
    return isPrimary || backColor != null
        ? ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(backColor),
            ),
            onPressed: onPressed,
            child: textWidget,
          )
        : OutlinedButton(
            onPressed: onPressed,
            child: textWidget,
          );
  }
}
