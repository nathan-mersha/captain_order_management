import 'package:flutter/material.dart';

class CNotifications {
  static void showSnackBar(BuildContext context, String message, String actionLabel, Function action, {seconds = 3, Color backgroundColor}) {
    Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: backgroundColor == null ? Theme.of(context).accentColor : backgroundColor,
        content: Text(message),
        duration: Duration(seconds: seconds),
        action: SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          onPressed: action,
        )));
  }
}
