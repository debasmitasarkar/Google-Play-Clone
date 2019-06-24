import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../scoped_models/auth.dart';
import '../ui_elements/chat_message.dart';
import '../ui_elements/chat_screen_bottombar.dart';
import '../models/chat_info.dart';

class ChatScreen extends StatefulWidget {
  final AuthModel model = AuthModel();
  ChatScreen();

  @override
  State<StatefulWidget> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  TextStyle _appBarInfoStyle = TextStyle(
      color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.normal);
  TextStyle _appBarInfoNoStyle = TextStyle(
      color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.normal);
  //To do fetch per contact
  ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  Widget _buildAppbarImageCircle(model) {
    return model.selectedContact.avatar != null &&
            model.selectedContact.avatar.length > 0
        ? CircleAvatar(
            backgroundImage: MemoryImage(model.selectedContact.avatar))
        : CircleAvatar(
            child: Text(model.selectedContact.displayName.length > 1
                ? model.selectedContact.displayName?.substring(0, 2)
                : ""));
  }

  Widget _buildAppbarInfo(model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            width: 200.0,
            child: Text(
              model.selectedContact.displayName,
              maxLines: 1,
              softWrap: false,
              style: _appBarInfoStyle,
              overflow: TextOverflow.ellipsis,
            )),
        Text(
            model.selectedContact.phones.length == 0
                ? ''
                : model.selectedContact.phones.first.value,
            style: _appBarInfoNoStyle)
      ],
    );
  }

  Widget _buildAppBar(model) {
    return AppBar(
      backgroundColor: Theme.of(context).accentColor,
      title: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _buildAppbarImageCircle(model),
            SizedBox(width: 10),
            _buildAppbarInfo(model)
          ],
        ),
      ),
      actions: <Widget>[
        Builder(builder: (BuildContext context) {
          return IconButton(
              iconSize: 30.0, onPressed: () {}, icon: Icon(Icons.more_vert));
        })
      ],
    );
  }

  _buildBody(AuthModel model) {
    model.getTotalRewards();
    return Container(
        color: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        child: Column(children: <Widget>[
          Expanded(
              child: StreamBuilder(
                  stream: model.chatRef
                      .where('recieverSenderEmail',
                          isEqualTo: model.selectedContact.emails.first.value +
                              model.fetchCurrentUser.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());
                    else if (snapshot.data.documents.length == 0) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            model.selectedContact.displayName,
                            style: TextStyle(fontSize: 20.0),
                          ),
                          Text(
                            model.selectedContact.phones.first.value,
                            style: TextStyle(fontSize: 15.0),
                          ),
                          Text(model.selectedContact.emails.first.value,
                              style: TextStyle(fontSize: 15.0)),
                          FlatButton(
                            color: Colors.blue[800],
                            onPressed: () {},
                            child: Text(
                              'Say Hello',
                              style: TextStyle(color: Colors.white),
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          )
                        ],
                      );
                    }
                    return ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        reverse: true,
                        shrinkWrap: true,
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          model.scrollAnimation();
                          DocumentSnapshot ds = snapshot.data.documents[index];
                          return ChatMessage(
                              chatInfoModel: ChatInfoModel(
                            text: ds['message'],
                            userName: ds['userName'],
                            imageUrl: ds['imageUrl'],
                            recieverSenderEmail: ds['recieverSenderEmail'],
                            senderEmail: ds['senderEmail'],
                            userImageUrl: ds['userPhotoUrl'],
                            transactionAmt: ds['transactionAmt'],
                            transactionDesc: ds['transactionDesc'],
                            timestamp: DateTime.now(),
                          ));
                        });
                  })),
          Container(
            child: ChatScreenBottomBar(navigateToPayScreen),
          )
        ]));
  }

  navigateToPayScreen() {
    Navigator.pushNamed(context, '/pay');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(widget.model), body: _buildBody(widget.model));
  }
}
