import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped_models/auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScreen extends StatelessWidget {
  AuthModel model = AuthModel();
  TextStyle _displayNameStyle = TextStyle(
      color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.w600);
  TextStyle _emailStyle = TextStyle(
      color: Colors.grey, fontSize: 15.0, fontWeight: FontWeight.w400);

  _buildUserAvatar(AuthModel model) {
    return Container(
      margin: EdgeInsets.only(top: 50.0, bottom: 20.0),
      height: 60.0,
      width: 60.0,
      child: CircleAvatar(
        backgroundImage: NetworkImage(model.fetchCurrentUser.photoUrl),
      ),
    );
  }

  _buildUserInfoContainer(AuthModel model) {
    return Container(
      margin: EdgeInsets.only(bottom: 30.0),
      child: Column(
        children: <Widget>[
          Text(model.fetchCurrentUser.displayName, style: _displayNameStyle),
          Text(model.fetchCurrentUser.email, style: _emailStyle),
        ],
      ),
    );
  }

  _buildQrContainer(AuthModel model) {
    return QrImage(
      data: model.fetchCurrentUser.email,
      size: 250,
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.clear,
                color: Colors.grey,
                size: 25.0,
              ),
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
          ),
          body: Container(
              alignment: Alignment.topCenter,
              child: Column(
                children: <Widget>[
                  _buildUserAvatar(model),
                  _buildUserInfoContainer(model),
                  _buildQrContainer(model)
                ],
              )));
    
  }
}
