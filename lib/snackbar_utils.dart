import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message) {
  SnackBar snackBar = SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 5),
    behavior: SnackBarBehavior.floating,
  );
  // hide snackbar if there is already a snackbar
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    snackBar,
  );
}
