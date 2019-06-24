import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:permission/permission.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../services/contact_service.dart';
import '../models/contact_model.dart';

class AuthModel {

  static final AuthModel _model = new AuthModel._internal();

  factory AuthModel() {
    //_model.init();
    return _model;
  }

  AuthModel._internal();

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference usersRef = Firestore.instance.collection('users');

  final chatMessages = Firestore.instance
      .collection('chatMessages')
      .orderBy('timestamp', descending: true);

  final CollectionReference chatRef =
      Firestore.instance.collection('chatMessages');
  String userToken;

  CollectionReference scratchCardRef = Firestore.instance.collection('scratchCards');

  //google signin related variables
  static GoogleSignInAccount _currentUser;
  GoogleSignInAuthentication _googleAuth;
  final GoogleSignIn _googleSignIn = new GoogleSignIn(
    scopes: <String>[
      'email',
      // 'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  bool _isUserSignedIn = false;

  // contact related variables
  ContactsService contactsService = ContactsService();
  Contact _selectedContact;
  var contacts;
  PermissionStatus contactStatus;

  //scroll variables
  ScrollController _scrollController = new ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );
  bool singleMessageScroll = false;

  //scratch variable
  int totalReward = 0;

  init() {
    initContacts();
    ensureLoggedIn();
  }

  addUserToUsersCollection() async {
    Map<String, dynamic> user = {
      'userEmail': fetchCurrentUser.email,
      'userToken': userToken
    };
    await isUserUnique(fetchCurrentUser.email) == true
        ? usersRef.add(user)
        : usersRef
            .where('userEmail', isEqualTo: fetchCurrentUser.email)
            .getDocuments()
            .then((qs) {
            usersRef
                .document(qs.documents[0].documentID)
                .updateData({'userToken': userToken});
          });
  }

  firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iOSPermission();

    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  sendPushNotification(message) async {
    var usertoken;
    await getUserTokenOfSelectedUser().then((value) {
      usertoken = value;
    });

    print(usertoken);
    var postData = {
      'to': userToken,
      'data': {'message': 'This is a Firebase Cloud Messaging Topic Message!'},
      'notification': {'title': 'Notification!!', 'body': message}
    };

    http.Response response = await http.post(
        'https://fcm.googleapis.com/fcm/send',
        body: json.encode(postData),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAs_zG5vs:APA91bG3lE_GUNuchuEd2O0g9XPl3GLdgHxmyQ3xi945nuhvnehdEdWxlvWhkBjDFbf2QF1KdksngZeaiYCWz9wjJFssKOmnia4e3pX3dxX8g95k9xMGqfelxhoomyOxiY4xly_PVbYLON5gL62S2bjGPq5oADBJLA'
        });
    print(json.decode(response.body));
  }

  iOSPermission() {
    firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  isUserUnique(String barcode) async {
    bool isUniq = false;
    QuerySnapshot users =
        await usersRef.where('userEmail', isEqualTo: barcode).getDocuments();
    isUniq = users.documents.length > 0 ? false : true;

    return isUniq;
  }

  getFCMToken() async {
    await firebaseMessaging.getToken().then((token) {
      userToken = token;
  
    });
    print(userToken);
  }

  getUserTokenOfSelectedUser() async {
    QuerySnapshot userDocs = await usersRef
        .where('userEmail', isEqualTo: selectedContact.emails.first.value)
        .getDocuments();
    return userDocs.documents[0].data['userToken']; //to do all token
  }

  set selectedContact(Contact contact) {
    _selectedContact = contact;

  }

  get selectedContact {
    return _selectedContact;
  }

  Future<Null> handleSignIn() async {
    try {
      await _googleSignIn.signIn().then((GoogleSignInAccount user) {
        setCurrentUser(user);
        _isUserSignedIn = true;
    
      });
      _googleAuth = await _currentUser.authentication;
      await _auth.signInWithGoogle(
        accessToken: _googleAuth.accessToken,
        idToken: _googleAuth.idToken,
      );
      await getFCMToken();
      firebaseCloudMessagingListeners();
      await addUserToUsersCollection();
    } catch (error) {
      print(error);
    }
  }

  Future<Null> handleSignOut(context) async {
    _isUserSignedIn = false;
    _googleSignIn.disconnect();
    Navigator.pushReplacementNamed(context, '/').then((onValue) {
      setCurrentUser(null);
    });
  }

  Future<Null> ensureLoggedIn() async {
    try {
      await _googleSignIn.signInSilently().then((GoogleSignInAccount account) {
        setCurrentUser(account);
        _isUserSignedIn = true;
        getFCMToken();
      });
      _googleAuth = await _currentUser.authentication;
      await _auth.signInWithGoogle(
        accessToken: _googleAuth.accessToken,
        idToken: _googleAuth.idToken,
      );
    } catch (error) {
      _isUserSignedIn = false;
    }
  }

  bool get signInStatus {
    return _isUserSignedIn;
  }

  void setCurrentUser(user) {
    _currentUser = user;
  }

  getTotalRewards() async {
    var total = 0;
    var docs = await scratchCardRef
        .where('recieverSenderEmail',
            isEqualTo: selectedContact.emails.first.value + _currentUser.email)
        .getDocuments();

    docs.documents.forEach((card) {
      card['scratched'] == true
          ? total = total + int.parse(card["amount"])
          : '';
    });
    totalReward = total;
    print(totalReward);

  }

  getAllContacts() async {
    contacts = await ContactsService.getContacts();
    contacts = contacts
        .where((c) => c.emails.length > 0 && c.phones.length > 0)
        .toList();
    print(contacts.length);
  }

  GoogleSignInAccount get fetchCurrentUser {
    return _currentUser;
  }

  void scrollAnimation( ) {
    // _scrollController.animateTo(
    //   _scrollController.position.maxScrollExtent + 500.0,
    //   duration: const Duration(milliseconds: 300),
    //   curve: Curves.ease,
    // );
  }

  void singleMessageAnimation() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  ScrollController get getScrollController {
    return _scrollController;
  }

  Future getPermissionStatus() async {
    var res = await Permission.getPermissionStatus([PermissionName.Contacts]);
    return res[0].permissionStatus;
  }

  void initContacts() => getPermissionStatus().then((res) {
        contactStatus = res;
        res == PermissionStatus.allow
            ? getAllContacts()
            : requestPermission().then((permission) {
                contactStatus = res;
                permission == PermissionStatus.allow ? getAllContacts() : '';
              });
      });

  Future requestPermission() async {
    final res =
        await Permission.requestSinglePermission(PermissionName.Contacts);
    return res;
  }
}
