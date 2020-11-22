import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CLoading extends StatelessWidget {
  final String message;

  CLoading({this.message = "Loading"});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SpinKitRipple(
          color: Theme.of(context).primaryColorLight,
          size: 100.0,
        ),
        SizedBox(
          height: 30,
        ),
        Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    ));
  }
}
