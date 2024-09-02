import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, {bool isError = true}) {
  SnackBar snackBar = SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 5),
    behavior: SnackBarBehavior.floating,
    backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade800,
    // close on tap
    action: SnackBarAction(
      label: '關閉',
      textColor: Colors.white,
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
  );
  // hide snackbar if there is already a snackbar
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    snackBar,
  );
}
