import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import '../scoped_models/auth.dart';

class SplashScreen extends StatefulWidget {
  final AuthModel model;
  SplashScreen({this.model});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    var _duration = Duration(seconds: 1);
    await widget.model.ensureLoggedIn();
    widget.model.signInStatus
        ? Timer(_duration, navigateToPasswordPage)
        : Timer(_duration, navigateToSignInPage);
  }

  void navigateToSignInPage() {
    Navigator.of(context).pushReplacementNamed('/signin');
  }

  void navigateToPasswordPage() {
    Navigator.of(context).pushReplacementNamed('/password');
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return 
       Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue[800],
          ),
          child: AppLogo(),
        ),
      );
  }
}
