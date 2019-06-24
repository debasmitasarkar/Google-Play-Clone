import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_logo.dart';
import 'package:local_auth/local_auth.dart';

class PasswordScreen extends StatefulWidget {
  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

void _onPressed(context) {
  Navigator.of(context).pushReplacementNamed('/contact');
}

class _PasswordScreenState extends State<PasswordScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  _buildLogoContainer() {
    return Container(
      child: Column(
        children: <Widget>[
          AppLogo(),
          SizedBox(height: 20.0),
          Icon(
            Icons.fingerprint,
            color: Colors.white,
            size: 50.0,
          ),
        ],
      ),
    );
  }

  _buildFormContainer() {
    return Container(
        child: Column(
      children: <Widget>[
        Form(
            key: formKey,
            child: Container(
                width: 160.0,
                child: TextFormField(
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    new LengthLimitingTextInputFormatter(4),
                  ],
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 35.0,
                  ),
                  maxLengthEnforced: false,
                  onFieldSubmitted: (String value) {
                    print(value);
                    if (value == '1234') {
                      print(value);
                      formKey.currentState.save();
                      Navigator.of(context).pushReplacementNamed('/contact');
                    }
                  },
                ))),
        SizedBox(
          height: 20.0,
        ),
        FlatButton(
          onPressed: () {
            _onPressed(context);
          },
          child: new Text('Forget Password'),
          textColor: Colors.white,
        )
      ],
    ));
  }

  Future<Null> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: true,
          stickyAuth: false);
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    if (authenticated) {
      Navigator.of(context).pushReplacementNamed('/contact');
    }

    // setState(() {
    //   _authorized = authenticated ? 'Authorized' : 'Not Authorized';
    // });
  }

  _buildFloatingActionButton() {
    return FloatingActionButton(
      elevation: 0.0,
      onPressed: () {
        //to do pass _selectedOption
        this._authenticate();
      },
      child: Icon(
        Icons.fingerprint,
        size: 25.0,
      ),
      backgroundColor: Colors.blue[900],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this._authenticate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue[800],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[_buildLogoContainer(), _buildFormContainer()],
          ),
        ),
      ),
      floatingActionButton: this._buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
