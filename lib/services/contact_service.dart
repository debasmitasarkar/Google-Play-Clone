import 'dart:async';
import 'package:flutter/services.dart';
import '../models/contact_model.dart';

class ContactsService {
  static const MethodChannel _channel =
      MethodChannel('github.com/clovisnicolas/flutter_contacts');

  /// Fetches all contacts, or when specified, the contacts with a name
  /// matching [query]
  static Future<Iterable<Contact>> getContacts({String query}) async {
    Iterable contacts = await _channel.invokeMethod('getContacts', query);
    return contacts.map((m) {
      return Contact.fromMap(m);
    });
  }

  /// Adds the [contact] to the device contact list
  static Future addContact(Contact contact) =>
      _channel.invokeMethod('addContact', Contact.toMap(contact));

  /// Deletes the [contact] if it has a valid identifier
  static Future deleteContact(Contact contact) =>
      _channel.invokeMethod('deleteContact', Contact.toMap(contact));
}


