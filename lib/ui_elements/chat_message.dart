import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../scoped_models/auth.dart';
import 'package:scoped_model/scoped_model.dart';
import '../models/chat_info.dart';

class ChatMessage extends StatelessWidget {
  final ChatInfoModel chatInfoModel;
  AuthModel model = AuthModel();
  ChatMessage({this.chatInfoModel});

  bool notNull(Object o) => o != null;
  TextStyle _scratchLinkStyle = TextStyle(
    color: Colors.blue,
    fontSize: 15.0,
  );
  // Widget _buildProfilePic() {
  //   return new Container(
  //     child: CircleAvatar(
  //       backgroundImage: NetworkImage(chatInfoModel.userImageUrl),
  //     ),
  //   );
  // }

  _getBoxConstraints(context) {
    return BoxConstraints(
        minWidth: 40.0,
        maxWidth: MediaQuery.of(context).size.width * 0.8,
        minHeight: 40.0,
        maxHeight: double.infinity);
  }

  _getSentMessageChatLayout() {
    return BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.all(Radius.elliptical(10.0, 10.0)),
        color: Colors.white);
  }

  _getRecievedMessageLayout() {
    return BoxDecoration(
        borderRadius: BorderRadius.all(Radius.elliptical(10.0, 10.0)),
        color: Colors.grey[200]);
  }

  _getMessagelayoutPadding() {
    return EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0);
  }

  Widget _buildUserName() {
    return new Text(
      chatInfoModel.userName,
      style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextMessage() {
    return new Container(
      margin: const EdgeInsets.only(top: 5.0),
      child: new Text(
        chatInfoModel.text,
        style: TextStyle(fontSize: 15.0),
      ),
    );
  }

  Widget _buildImageMessage() {
    return new Container(
      width: 250.0,
      height: 250.0,
      margin: const EdgeInsets.only(top: 5.0),
      child: Image.network(chatInfoModel.imageUrl),
    );
  }

  Widget _getTemplateForSentMessages(context) {
    print(chatInfoModel.transactionAmt);
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
      Column(children: <Widget>[
        Container(
            constraints: _getBoxConstraints(context),
            padding: _getMessagelayoutPadding(),
            decoration: _getSentMessageChatLayout(),
            child: chatInfoModel.transactionAmt != null
                ? _buildPaymentMessage(false)
                : (chatInfoModel.imageUrl != null
                    ? _buildImageMessage()
                    : _buildTextMessage())),
        chatInfoModel.transactionAmt != null &&
                double.parse(chatInfoModel.transactionAmt) >= 150.0
            ? _buildNavigationContainer(context)
            : null
      ].where(notNull).toList())
    ]);
  }

  Widget _getTemplateForRecivedMessages(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      Container(
          constraints: _getBoxConstraints(context),
          padding: _getMessagelayoutPadding(),
          decoration: _getRecievedMessageLayout(),
          child: Column(
              children: <Widget>[
            chatInfoModel.transactionDesc == null
                ? (chatInfoModel.text != null
                    ? _buildTextMessage()
                    : _buildImageMessage())
                : _buildPaymentMessage(true),
            chatInfoModel.transactionAmt != null &&
                    double.parse(chatInfoModel.transactionAmt) >= 150.0
                ? _buildNavigationContainer(context)
                : null
          ].where(notNull).toList()))
    ]);
  }

  _buildNavigationContainer(context) {
    return Container(
      height: 30.0,
      child: FlatButton(
        onPressed:()=> _navigateToRewardsScreen(context),
        child: Text("You earned a scratch card!!", style: _scratchLinkStyle),
      ),
    );
  }

  _navigateToRewardsScreen(context) {
    Navigator.pushNamed(context, '/rewards');
  }

  _buildAmountContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(r'₹ ', style: TextStyle(color: Colors.black, fontSize: 20.0)),
        Text(
          '${chatInfoModel.transactionAmt}',
          style: TextStyle(
              color: Colors.black, fontSize: 60.0, fontWeight: FontWeight.w300),
        )
      ],
    );
  }

  _buildDescContainer() {
    return Text(
      chatInfoModel.transactionDesc,
      overflow: TextOverflow.ellipsis,
    );
  }

  _buildDateInfoContainer(bool isRecivedMessage) {
    var now = new DateTime.now();
    var msgTime = chatInfoModel.timestamp;
    var difference = now.difference(msgTime).inDays;
    var dateToShow;
    var formatter = new DateFormat('MMMM');
    difference > 365
        ? dateToShow = Text('${msgTime.day}'
            ' '
            '${formatter.format(msgTime)}'
            '/'
            '${msgTime.year}')
        : dateToShow =
            Text('${msgTime.day}' ' ' '${formatter.format(msgTime)}');
    return Row(
      children: <Widget>[
        Text(
          isRecivedMessage ? 'Recieved .' : 'Paid .',
          style: TextStyle(color: Colors.blueGrey, fontSize: 15.0),
        ),
        dateToShow
      ],
    );
  }

  _buildPaymentMessage(bool isRecivedMessage) {
    return Container(
      width: 150.0,
      margin: const EdgeInsets.only(top: 5.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildAmountContainer(),
          _buildDescContainer(),
          SizedBox(
            height: 10.0,
          ),
          _buildDateInfoContainer(isRecivedMessage)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: (chatInfoModel.senderEmail == null) ||
                chatInfoModel.senderEmail != model.fetchCurrentUser.email
            ? _getTemplateForRecivedMessages(context)
            : _getTemplateForSentMessages(context),
      );
  }
}
