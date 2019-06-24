import 'dart:math';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped_models/auth.dart';
import '../pages/scratch_rough_page.dart';
import '../models/scratch_card_model.dart';
import '../ui_elements/transparent_page_route.dart';

class PayScreen extends StatefulWidget {
  PayScreen();
  @override
  State<StatefulWidget> createState() {
    return _PayScreenState();
  }
}

class _PayScreenState extends State<PayScreen> {
  AuthModel model = AuthModel();
  TextEditingController _amountTextController = TextEditingController();
  TextEditingController _descTextController = TextEditingController();
  bool notNull(Object o) => o != null;

  _payInfoContainer(AuthModel model) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(model.fetchCurrentUser.photoUrl),
            ),
            Icon(
              Icons.chevron_right,
              size: 20.0,
              color: Colors.white,
            ),
            model.selectedContact.avatar != null &&
                    model.selectedContact.avatar.length > 0
                ? CircleAvatar(
                    backgroundImage: MemoryImage(model.selectedContact.avatar))
                : CircleAvatar(
                    child: Text(model.selectedContact.displayName.length > 1
                        ? model.selectedContact.displayName?.substring(0, 2)
                        : "")),
          ],
        ),
        SizedBox(height: 10.0),
        Text(
          'Paying ${model.selectedContact.displayName}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.0,
          ),
        )
      ],
    );
  }

  _amountTextField() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Flexible(
          child: TextField(
        controller: _amountTextController,
        maxLength: 6,
        maxLengthEnforced: true,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        // maxLines: null,
        onSubmitted: (_) {},
        autofocus: true,
        cursorColor: Colors.white,
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 60.0),
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: TextStyle(color: Colors.white70),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent)),
          enabledBorder: InputBorder.none,
          border: InputBorder.none,
        ),
      )),
    ]);
  }

  _descContainer() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Flexible(
          child: Container(
              alignment: Alignment.center,
              width: 150.0,
              height: 50.0,
              decoration: BoxDecoration(
                  color: Colors.lightBlue[900],
                  borderRadius: BorderRadius.circular(25.0)),
              child: TextField(
                controller: _descTextController,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.0),
                decoration: InputDecoration(
                  hintText: 'What\'s this for?',
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                  enabledBorder: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 15.0, color: Colors.white70),
                ),
              )))
    ]);
  }

  _sendPayment({AuthModel model}) {
    addPaymentMessageToDb(model);
    addScratchCardToDb(model);
    Navigator.pushReplacementNamed(context, '/chat');
    model.singleMessageScroll = true;
    model.selectedContact.emails.isNotEmpty == true
        ? model.sendPushNotification('You got a payment !!')
        : '';
  }

  addPaymentMessageToDb(model) {
    Map<String, dynamic> newMessage = {
      'transactionAmt': _amountTextController.text,
      'transactionDesc': _descTextController.text,
      'userName': model.fetchCurrentUser.displayName,
      'senderEmail': model.fetchCurrentUser.email,
      'recieverSenderEmail': model.selectedContact.emails.first.value +
          model.fetchCurrentUser.email,
      'userPhotoUrl': model.fetchCurrentUser.photoUrl,
      'timestamp': new DateTime.now()
    };
    model.chatRef.add(newMessage);
  }

  addScratchCardToDb(AuthModel model) async {
    var randomNumber = getRandomAmountNumber().toString();
    if (int.parse(_amountTextController.text) >= 150) {
      Map<String, dynamic> scratchCard = {
        'amount': randomNumber,
        'imageUrl': '',
        'senderEmail': model.fetchCurrentUser.email,
        'recieverSenderEmail': model.selectedContact.emails.first.value +
            model.fetchCurrentUser.email,
        'scratched': false,
      };
      var docRef = await model.scratchCardRef.add(scratchCard);
      print(docRef.documentID);
    }
  }

  getRandomAmountNumber() {
    int min = 10;
    int max = 200;
    return min + (Random().nextInt(max - min));
  }

  _buildBody(model) {
    return Container(
      color: Colors.blue[800],
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 80.0,
          ),
          _payInfoContainer(model),
          SizedBox(height: 20.0),
          _amountTextField(),
          _descContainer(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.blue[800],
      ),
      body: _buildBody(model),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _amountTextController.text.isNotEmpty &&
                  _descTextController.text.isNotEmpty
              ? _sendPayment(model: model)
              : '';
        },
        child: _amountTextController.text.isNotEmpty &&
                _descTextController.text.isNotEmpty
            ? Icon(Icons.check, color: Colors.blue)
            : Icon(Icons.arrow_forward, color: Colors.blue),
        backgroundColor: Colors.white,
      ),
    );
  }
}
