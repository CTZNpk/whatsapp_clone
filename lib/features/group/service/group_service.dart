import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/share/model/contact_model.dart';
import 'package:whatsapp_clone/share/model/group_model.dart';
import 'package:whatsapp_clone/share/services/shared_firebase_storage_services.dart';
import 'package:whatsapp_clone/share/utils/utils.dart';

final groupServiceProvider = Provider(
  (ref) => GroupService(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref,
  ),
);

class GroupService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ProviderRef ref;

  GroupService({
    required this.firestore,
    required this.auth,
    required this.ref,
  });

  void createGroup(BuildContext context, String name, File profilePic,
      List<ContactModel> selectedContacts) async {
    try {
      List<String> uids = [];
      for (int i = 0; i < selectedContacts.length; i++) {
        var userCollection = await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .collection('contacts')
            .where('phoneNumber', isEqualTo: selectedContacts[i].phoneNumber)
            .get();
        if (userCollection.docs.isNotEmpty && userCollection.docs[0].exists) {
          uids.add(userCollection.docs[0].data()['uid']);
        }
      }
      var groupId = const Uuid().v1();
      String profilePicUrl = await ref
          .read(sharedFirebaseStorageServiceProvider)
          .storeFileToFirebase('group/$groupId', profilePic);
      Group group = Group(
        senderId: auth.currentUser!.uid,
        name: name,
        groupId: groupId,
        lastmessage: '',
        groupPic: profilePicUrl,
        membersUid: [auth.currentUser!.uid, ...uids],
        timeSent: DateTime.now(),
      );

      await firestore.collection('groups').doc(groupId).set(group.toMap());
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
