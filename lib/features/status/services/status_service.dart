import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/share/model/contact_model.dart';
import 'package:whatsapp_clone/share/model/status_model.dart';
import 'package:whatsapp_clone/share/services/shared_firebase_storage_services.dart';
import 'package:whatsapp_clone/share/utils/utils.dart';

final statusServiceProvider = Provider(
  (ref) => StatusService(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref,
  ),
);

class StatusService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ProviderRef ref;

  StatusService({
    required this.firestore,
    required this.auth,
    required this.ref,
  });

  Future uploadStatus({
    required String username,
    required String profilePic,
    required String phoneNumber,
    required File statusImage,
    required BuildContext context,
  }) async {
    try {
      var statusId = const Uuid().v1();
      List<String> uidWhoCanSee = [];
      String uid = auth.currentUser!.uid;
      String imageUrl = await ref
          .read(sharedFirebaseStorageServiceProvider)
          .storeFileToFirebase('/status/$statusId$uid', statusImage);
      final contactsDoc = await firestore
          .collection('users')
          .doc(uid)
          .collection('contacts')
          .get();
      for (var doc in contactsDoc.docs) {
        uidWhoCanSee.add(doc['uid']);
      }

      List<String> statusImageUrls = [];
      var statusesSnapshot = await firestore
          .collection('status')
          .where('uid', isEqualTo: auth.currentUser!.uid)
          .get();


      if (statusesSnapshot.docs.isNotEmpty) {
        Status status = Status.fromMap(statusesSnapshot.docs[0].data());
        statusImageUrls = status.photoUrl;
        statusImageUrls.add(imageUrl);
        await firestore
            .collection('status')
            .doc(statusesSnapshot.docs[0].id)
            .update({'photoUrl': statusImageUrls});
        return;
      }
      statusImageUrls = [imageUrl];
      Status status = Status(
        uid: uid,
        username: username,
        phoneNumber: phoneNumber,
        photoUrl: statusImageUrls,
        createdAt: DateTime.now(),
        profilepic: profilePic,
        statusId: statusId,
        whoCanSee: uidWhoCanSee,
      );
      await firestore.collection('status').doc(statusId).set(status.toMap());
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Future<List<Status>> getStatus(BuildContext context) async {
    List<Status> statusData = [];
    String uid = auth.currentUser!.uid;
    try {
      List<ContactModel> contacts = [];
      final contactsDoc = await firestore
          .collection('users')
          .doc(uid)
          .collection('contacts')
          .get();
      for (var doc in contactsDoc.docs) {
        contacts.add(ContactModel.fromMap(doc.data()));
      }
      for (var contact in contacts) {
        var statusesSnapshot = await firestore
            .collection('status')
            .where('uid', isEqualTo: contact.uid)
            .where(
              'createdAt',
              isGreaterThan: DateTime.now()
                  .subtract(const Duration(hours: 24))
                  .millisecondsSinceEpoch,
            )
            .get();
        for (var tempData in statusesSnapshot.docs) {
          Status tempStatus = Status.fromMap(tempData.data());
          tempStatus.username = contact.name;
          if(tempStatus.whoCanSee.contains(auth.currentUser!.uid)){
            statusData.add(tempStatus);
          }
        }
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
      return statusData;
  }
}
