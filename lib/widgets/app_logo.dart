import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Glow',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22.0),
        ),
        Text(
          'Pay',
          style: TextStyle(color: Colors.lightBlue[100], fontSize: 22.0),
        ),
      ],
    );
  }
}
