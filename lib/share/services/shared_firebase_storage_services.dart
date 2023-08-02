import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/share/model/user_model.dart';

final sharedFirebaseStorageServiceProvider =
    Provider((ref) => SharedFirebaseStorageService(
          firebaseStorage: FirebaseStorage.instance,
          firestore: FirebaseFirestore.instance,
        ));

class SharedFirebaseStorageService {
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firestore;

  SharedFirebaseStorageService(
      {required this.firebaseStorage, required this.firestore});

  Future<String> storeFileToFirebase(String storageLocation, File file) async {
    return await _StoreFileToFirebase(firebaseStorage: firebaseStorage)
        .storingFileAndReturnDownloadUrl(storageLocation, file);
  }

  Stream<UserModel> userDatabyId(String userId) {
    return _UserDataById(firestore: firestore).gettingData(userId);
  }
}

class _StoreFileToFirebase {
  final FirebaseStorage firebaseStorage;

  _StoreFileToFirebase({required this.firebaseStorage});

  Future<String> storingFileAndReturnDownloadUrl(
      String storageLocation, File file) async {
    UploadTask uploadTask =
        firebaseStorage.ref().child(storageLocation).putFile(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }
}

class _UserDataById {
  final FirebaseFirestore firestore;
  _UserDataById({required this.firestore});

  Stream<UserModel> gettingData(String userId) {
    return firestore.collection('users').doc(userId).snapshots().map(
          (event) => UserModel.fromMap(
            event.data()!,
          ),
        );
  }
}
