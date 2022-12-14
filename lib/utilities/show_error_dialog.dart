import 'dart:ffi';

import 'package:flutter/material.dart';

Future<Void?> showErrorDialog(BuildContext context, String text) {
  return showDialog<Void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error occured"),
          content: Text(text),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'))
          ],
        );
      },
      useSafeArea: false,
      barrierDismissible: false);
}
