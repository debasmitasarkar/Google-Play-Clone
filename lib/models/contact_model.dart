import 'dart:typed_data';

class Contact {
  // to do data modify
  Contact(
      {this.givenName,
      this.middleName,
      this.prefix,
      this.suffix,
      this.familyName,
      this.company,
      this.jobTitle,
      this.emails,
      this.phones,
      this.avatar});

  String identifier,
      displayName,
      givenName,
      middleName,
      prefix,
      suffix,
      familyName,
      company,
      jobTitle;
  Iterable<Item> emails = [];
  Iterable<Item> phones = [];
  Uint8List avatar;

  Contact.fromMap(Map m) {
    identifier = m["identifier"];
    displayName = m["displayName"];  
    givenName = m["givenName"];
    middleName = m["middleName"];
    familyName = m["familyName"];
    emails = (m["emails"] as Iterable)?.map((m) => Item.fromMap(m));
    phones = (m["phones"] as Iterable)?.map((m) => Item.fromMap(m));
    avatar = m["avatar"];
  }

  static Map toMap(Contact contact) {
    var emails = [];
    for (Item email in contact.emails ?? []) {
      emails.add(Item._toMap(email));
    }
    var phones = [];
    for (Item phone in contact.phones ?? []) {
      phones.add(Item._toMap(phone));
    }
    return {
      "identifier": contact.identifier,
      "displayName": contact.displayName,
      "givenName": contact.givenName,
      "middleName": contact.middleName,
      "familyName": contact.familyName,
      "emails": emails,
      "phones": phones,
      "avatar": contact.avatar
    };
  }
}


/// Item class used for contact fields which only have a [label] and
/// a [value], such as emails and phone numbers
class Item {
  Item({this.label, this.value});
  String label, value;

  Item.fromMap(Map m) {
    label = m["label"];
    value = m["value"];
  }

  static Map _toMap(Item i) => {"label": i.label, "value": i.value};
}