import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/chat/screens/chat.dart';
import 'package:whatsapp_clone/share/model/contact_model.dart';

final selectContactServiceProvider = Provider(
  (ref) => SelectContactsService(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class SelectContactsService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  SelectContactsService({required this.firestore, required this.auth});

  Future syncContacts() async {
    await _SavingContactsToFireStore(firestore: firestore, auth: auth)
        .syncContacts();
  }

  Future<List<ContactModel>> getContacts() async {
    return await _GettingContactsFromFirestore(auth: auth, firestore: firestore)
        .gettingContacts();
  }


  void selectContact(ContactModel selectedContact, BuildContext context) async {
    Navigator.pushNamed(
      context,
      ChatScreen.routeName,
      arguments: selectedContact.toMap(),
    );
  }
}

class _GettingContactsFromFirestore {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  _GettingContactsFromFirestore({required this.firestore, required this.auth});

  Future<List<ContactModel>> gettingContacts() async {
    List<ContactModel> userContacts = [];
    var contacts = await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('contacts')
        .get();
    for (var doc in contacts.docs) {
      userContacts.add(ContactModel.fromMap(doc.data()));
    }
    return userContacts;
  }
}

class _SavingContactsToFireStore {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  _SavingContactsToFireStore({required this.firestore, required this.auth});

  Future syncContacts() async {
    Map<String, String> contactNumbers = await _getContactNumbersAndNames();
    List<ContactModel> foundContacts = [];

    List<List<String>> subList =
        _makingBatchesOf10OfThePhoneNumbers(contactNumbers);

    for (var sub in subList) {
      await _gettingMatchedDataAndStoringFoundContacts(
        contactNumbers: contactNumbers,
        list: sub,
        foundContacts: foundContacts,
      );
    }
    for (var contact in foundContacts) {
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('contacts')
          .doc(contact.uid)
          .set(contact.toMap());
    }
  }

  Future _gettingMatchedDataAndStoringFoundContacts({
    required Map<String, String> contactNumbers,
    required List<String> list,
    required List<ContactModel> foundContacts,
  }) async {
    var querySnapshot = await firestore
        .collection('users')
        .where(
          'phoneNumber',
          whereIn: list,
        )
        .get();

    for (var document in querySnapshot.docs) {
      final userPhoneNumber = document['phoneNumber'];
      foundContacts.add(
        ContactModel(
          uid: document['uid'],
          profilePic: document['profilePic'],
          phoneNumber: userPhoneNumber,
          name: contactNumbers[userPhoneNumber]!,
        ),
      );
    }
  }

  Future<Map<String, String>> _getContactNumbersAndNames() async {
    Map<String, String> contactNumbers = {};
    try {
      contactNumbers = await _getContactsAndStoreNameAndNumberInAMap();
    } catch (e) {
      debugPrint(e.toString());
    }
    return contactNumbers;
  }

  Future<Map<String, String>> _getContactsAndStoreNameAndNumberInAMap() async {
    Map<String, String> contactNumbers = {};
    List<Contact> contacts =
        await FlutterContacts.getContacts(withProperties: true);
    for (var contact in contacts) {
      if (contact.phones.isEmpty) {
        continue;
      }
      contactNumbers[contact.phones[0].normalizedNumber] = contact.displayName;
    }
    return contactNumbers;
  }

  List<List<String>> _makingBatchesOf10OfThePhoneNumbers(
      Map<String, String> contactNumbers) {
    List<List<String>> subList = [];
    for (var i = 0; i < contactNumbers.length; i += 10) {
      subList.add(
        contactNumbers.entries.map((entry) => entry.key).toList().sublist(
            i, i + 10 > contactNumbers.length ? contactNumbers.length : i + 10),
      );
    }
    return subList;
  }
}
