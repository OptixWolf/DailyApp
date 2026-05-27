import 'package:flutter/material.dart';

class Snackbar {
  void show(BuildContext context, String snackbarContent) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(snackbarContent),
        action: SnackBarAction(
            label: 'OK', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }
}
