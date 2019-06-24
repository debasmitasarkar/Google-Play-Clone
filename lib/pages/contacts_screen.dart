import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission/permission.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import '../scoped_models/auth.dart';
import '../services/contact_service.dart';
import '../models/contact_model.dart';

class ContactsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ContactsScreenState();
  }
}

class _ContactsScreenState extends State<ContactsScreen> {
  AuthModel model = AuthModel();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  BuildContext scaffoldContext;
  String barcode = '';
  Iterable<Contact> _contacts = [];
  Iterable<Contact> _cachedContacts;
  PermissionStatus status;
  bool searchButtonPressed = false;
  static TextStyle _appbarTextStyle = TextStyle(
      color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.normal);
  static Widget initialAppbarTitle =
      Text('Start a payment', style: _appbarTextStyle);
  Widget appBarTitle = initialAppbarTitle;

  static Widget initialAppBarLeading = Container(width: 0.0);
  Widget appBarLeading = initialAppBarLeading;
  GlobalKey refreshKey = GlobalKey<RefreshIndicatorState>();

  TextEditingController _searchFilter = TextEditingController();
  String _searchText = '';

  set resetSearchText(String value) {
    _searchText = value;
  }

  get getContacts {
    return _contacts;
  }

  Future getPermissionStatus() async {
    var res = await Permission.getPermissionStatus([PermissionName.Contacts]);
    return res[0].permissionStatus;
  }

  void init(AuthModel model) => getPermissionStatus().then((res) {
        print(res);
        setState(() {
          status = res;
        });
        res == PermissionStatus.allow
            ? _loadCachedContacts(model)
            : requestPermission().then((permission) {
                setState(() {
                  status = res;
                });
                permission == PermissionStatus.allow
                    ? refreshContacts()
                    : Navigator.pushReplacementNamed(context, '/password');
              });
      });

  Future requestPermission() async {
    final res =
        await Permission.requestSinglePermission(PermissionName.Contacts);
    return res;
  }

  _filterContacts() async {
    var contacts = model.contacts.where((c) => c.displayName.toLowerCase().contains(_searchText.toLowerCase()) == true).toList(); 
    setState(() {
      _contacts = contacts;
    });
  }

  Future<dynamic> refreshContactList() async =>
      _searchText.isEmpty ? refreshContacts() : await _filterContacts();

  _loadCachedContacts(AuthModel model) {
    var contacts = model.contacts;
    _contacts = null;
    resetSearchText = '';
    setState(() {
      _cachedContacts = contacts;
      _contacts = contacts;
    });
  }

  refreshContacts() async {
    var contacts = await ContactsService.getContacts();
    contacts = contacts
        .where((c) => c.emails.length > 0 && c.phones.length > 0)
        .toList();
    _contacts = null;
    resetSearchText = '';
    setState(() {
      _cachedContacts = contacts;
      _contacts = contacts;
    });
  }

  _buildContactList(AuthModel model) {
    _contacts.length == 0 ? init(model) : '';
    return SafeArea(
      bottom: true,
      child: _contacts != null
          ? RefreshIndicator(
              displacement: 100.0,
              color: Theme.of(context).accentColor,
              key: refreshKey,
              onRefresh: refreshContactList,
              child: ListView.builder(
                itemCount: _contacts?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  Contact contact = _contacts?.elementAt(index);
                  return ListTile(
                    onTap: () {
                      model.selectedContact = contact;
                      Navigator.pushNamed(context, '/chat');
                    },
                    leading:
                        (contact.avatar != null && contact.avatar.length > 0)
                            ? CircleAvatar(
                                backgroundImage: MemoryImage(contact.avatar))
                            : CircleAvatar(
                                child: Text(contact.displayName.length > 1
                                    ? contact.displayName?.substring(0, 2)
                                    : "")),
                    title: Text(contact.displayName ?? ""),
                  );
                },
              ))
          : Center(child: CircularProgressIndicator()),
    );
  }

  _onSearchButtonPressed() {
    setState(() {
      appBarTitle = TextField(
        autofocus: true,
        controller: _searchFilter,
        style: TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
            hintText: "Search for a contact",
            hintStyle: TextStyle(color: Colors.blue[100])),
      );
      appBarLeading = IconButton(
          onPressed: _onSearchBackArrowPressed, icon: Icon(Icons.arrow_back));
    });
  }

  _onSearchBackArrowPressed() {
    _contacts = _cachedContacts;
    resetSearchText = '';
    setState(() {
      appBarTitle = initialAppbarTitle;
      appBarLeading = initialAppBarLeading;
    });
  }

  _buildAppBar() {
    return AppBar(
      elevation: 0.0,
      backgroundColor: Colors.blue[800],
      title: appBarTitle,
      leading: appBarLeading,
      actions: <Widget>[
        IconButton(
          onPressed: _onSearchButtonPressed,
          icon: Icon(Icons.search),
          iconSize: 30.0,
        ),
        PopupMenuButton(
          onSelected: (result) {
            result == 0 ? Navigator.pushNamed(context, '/qr') : '';
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<dynamic>>[
                const PopupMenuItem<dynamic>(
                  value: 0,
                  child: Text('Display QR code'),
                ),
              ],
          icon: Icon(Icons.more_vert),
        )
      ],
    );
  }

  _buildBody(model) {
    return SingleChildScrollView(
        child: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 30.0,
      child: _buildContactList(model),
    ));
  }

  _addListenerToSearchFilter() {
    _searchFilter.addListener(() {
      print(_searchFilter.text);
      setState(() {
        resetSearchText = _searchFilter.text;
      });
      _searchFilter.text.isNotEmpty
          ? _filterContacts()
          : _contacts = _cachedContacts;
      ;
    });
  }

  void scanAndValidate(AuthModel model, scaffoldContextt) {
    scaffoldContext = scaffoldContextt;
    scan().then((_) {
      if (!model.isUserUnique(barcode)) {
        _cachedContacts.where((contact) {
          contact.displayName == barcode ? model.selectedContact = contact : '';
        });
        Navigator.pushNamed(context, '/pay');
      } else {
        createSnackBar('Barcode invalid !!');
      }
    });
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  void createSnackBar(String message) {
    final snackBar = new SnackBar(
      content: new Text(message),
      backgroundColor: Colors.black,
      duration: Duration(seconds: 2),
    );
    Scaffold.of(scaffoldContext).showSnackBar(snackBar);
  }

  @override
  initState() {
    super.initState();
    _addListenerToSearchFilter();
  }

  @override
  Widget build(BuildContext context) {
    
      return Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(model),
        floatingActionButton: Builder(
            builder: (scaffoldContext) => FloatingActionButton(
                  backgroundColor: Colors.blue[800],
                  elevation: 2.0,
                  onPressed: () => scanAndValidate(model, scaffoldContext),
                  child: Icon(
                    Icons.crop_free,
                    color: Colors.white,
                  ),
                )),
      );
  }
}
