import 'dart:async';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import '../scoped_models/auth.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  AuthModel model = AuthModel();
  startTime() async {
    var _duration = Duration(seconds: 2);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed('/password');
  }

  @override
  void initState() {
    super.initState();
    // startTime();
  }

  _buildSignInContainer(AuthModel model) {
    return Container(
        width: 200.0,
        height: 50.0,
        child: RaisedButton(
            elevation: 0.0,
            color: Colors.blue[500],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            onPressed: () {
              model.handleSignIn().then((_) {
                print(_);
                model.signInStatus
                    ? Navigator.pushReplacementNamed(context, '/password')
                    : '';
              });
            },
            child: Text(
              'Sign in with Google',
              style: TextStyle(color: Colors.white, fontSize: 15.0),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue[800],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Flexible(flex: 4, child: AppLogo()),
              Flexible(flex: 2, child: _buildSignInContainer(model))
            ],
          )),
    );
  }
}
