import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './pages/password_screen.dart';
import './pages/splash_screen.dart';
import './pages/biometric_screen.dart';
import './pages/contacts_screen.dart';
import './pages/chat_screen.dart';
import './pages/sign_in_screen.dart';
import './pages/rewards_screen.dart';
import './scoped_models/auth.dart';
import './pages/qr_screen.dart';
import './pages/pay_screen.dart';
 
void main() {
  final AuthModel model = AuthModel();
  model.init();
  runApp(GlowPay(model));
}

class GlowPay extends StatefulWidget {
  final AuthModel model;
  GlowPay(this.model);
  @override
  State<StatefulWidget> createState() {
    return _GlowPayState();
  }
}

class _GlowPayState extends State<GlowPay> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          accentColor: Colors.blue[800],
          primarySwatch: Colors.blue,
          inputDecorationTheme: InputDecorationTheme(
              enabledBorder: UnderlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 0.0,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.white, width: 0.0)))),
      home: SplashScreen(
        model: widget.model,
      ),
      routes: <String, WidgetBuilder>{
        '/password': (BuildContext context) => PasswordScreen(),
        '/biometric': (BuildContext context) => BiometricScreen(),
        '/contact': (BuildContext context) => ContactsScreen(),
        '/chat': (BuildContext context) => ChatScreen(),
        '/signin': (BuildContext context) => SignInScreen(),
        '/rewards': (BuildContext context) => RewardsScreen(),
        '/qr': (BuildContext context) => QrScreen(),
        '/pay': (BuildContext context) => PayScreen(),
      },
    );
  }
}
