import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './text_bar.dart';
import '../scoped_models/auth.dart';

class ChatScreenBottomBar extends StatefulWidget {
  final Function navigateToPayScreen;
  ChatScreenBottomBar(this.navigateToPayScreen);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ChatScreenBottomBarState();
  }
}

class _ChatScreenBottomBarState extends State<ChatScreenBottomBar> {
  bool isTextBarExpanded = false;

  TextStyle _payButtonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 15,
  );

  Widget _buildPayButton() {
    print('navigate to pay screen');
    return RaisedButton(
      onPressed: () => widget.navigateToPayScreen(),
      elevation: 0.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      padding: EdgeInsets.all(10.0),
      color: Colors.blue[800],
      child: Text('Pay', style: _payButtonTextStyle),
    );
  }

  _buildCollapseButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isTextBarExpanded = false;
        });
      },
      child: Container(
          padding: EdgeInsets.all(0.0),
          margin: EdgeInsets.all(0.0),
          width: 33.0,
          height: 33.0,
          decoration: BoxDecoration(
            color: Colors.blue[800],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.keyboard_arrow_right,
            color: Colors.white,
            size: 30.0,
          )),
    );
  }

  _buildExpandedTextBar() {
    //To Do pass functions
    return Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width - 20.0 - 33.0 - 20.0,
        child: TextBar(
          isTextBarExpanded: isTextBarExpanded,
          sendTextMessage: _sendMessage,
        ));
  }

  _buildCollapsedTextBar() {
    return GestureDetector(
        onTap: () {
          setState(() {
            isTextBarExpanded = true;
          });
        },
        child: Container(
            width: 150.0,
            child: TextBar(isTextBarExpanded: isTextBarExpanded)));
  }

  Widget _buildBottomBarRow(context) {
    return Row(
      mainAxisAlignment:
          isTextBarExpanded ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        isTextBarExpanded ? _buildCollapseButton() : _buildPayButton(),
        SizedBox(width: 10.0),
        isTextBarExpanded ? _buildExpandedTextBar() : _buildCollapsedTextBar()
      ],
    );
  }

  _sendMessage({String message, String imageUrl, AuthModel model}) {
    print('calling send message');
    print(model.signInStatus);
    Map<String, dynamic> newMessage = {
      'message': message,
      'userName': model.fetchCurrentUser.displayName,
      'recieverSenderEmail': model.selectedContact.emails.first.value +
          model.fetchCurrentUser.email,
      'senderEmail': model.fetchCurrentUser.email,
      'userPhotoUrl': model.fetchCurrentUser.photoUrl,
      'imageUrl': imageUrl,
      'timestamp': new DateTime.now()
    };
    model.chatRef.add(newMessage);
    model.singleMessageScroll = true;
    model.selectedContact.emails.isNotEmpty == true
        ? model.sendPushNotification("You got a message !!")
        : '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.0,
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]))),
      child: _buildBottomBarRow(context),
    );
  }
}
