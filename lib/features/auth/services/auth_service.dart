import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/screens/user_information_screen.dart';
import 'package:whatsapp_clone/features/select_contacts/controller/select_contact_controller.dart';
import 'package:whatsapp_clone/screens/home.dart';
import 'package:whatsapp_clone/share/model/user_model.dart';
import 'package:whatsapp_clone/share/services/shared_firebase_storage_services.dart';
import 'package:whatsapp_clone/share/utils/utils.dart';
import 'package:whatsapp_clone/features/auth/screens/otp_screen.dart';

final authServiceProvider = Provider(
  (ref) => AuthService(
      auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance),
);

class AuthService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  AuthService({required this.auth, required this.firestore});

  Future<UserModel?> getCurrentUserData() async {
    return await _GetCurrentUserData(firestore: firestore, auth: auth)
        .gettingData();
  }

  Future signInWithPhone(BuildContext context, String phoneNumber,
      Function toggleLoadingScreen, Function toggleCanSendMessage) async {
    await _AuthSignInWithPhone(auth: auth).verifyPhoneNumber(
        context: context,
        phoneNumber: phoneNumber,
        toggleLoadingScreen: toggleLoadingScreen,
        toggleCanSendMessage: toggleCanSendMessage);
  }

  Future verifyOTP(
      {required BuildContext context,
      required String verificationId,
      required String userOTP}) async {
    await _AuthVerifyOTP(auth: auth).signInWithCredential(
      context: context,
      verificationId: verificationId,
      userOTP: userOTP,
    );
  }

  Future saveUserData(
      {required BuildContext context,
      required String name,
      required File? profilePic,
      required ProviderRef ref}) async {
    await _AuthSaveUserData(auth: auth, firestore: firestore).savingData(
        context: context, name: name, profilePic: profilePic, ref: ref);
  }

  void setUserState(bool isOnline) async {
    await firestore.collection('users').doc(auth.currentUser!.uid).update({
      'isOnline': isOnline,
    });
  }
}

class _GetCurrentUserData {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  _GetCurrentUserData({
    required this.firestore,
    required this.auth,
  });

  Future<UserModel?> gettingData() async {
    var userData =
        await firestore.collection('users').doc(auth.currentUser?.uid).get();
    UserModel? user;

    if (userData.data() != null) {
      user = UserModel.fromMap(userData.data()!);
    }
    return user;
  }
}

class _AuthSignInWithPhone {
  final FirebaseAuth auth;
  _AuthSignInWithPhone({required this.auth});

  Future verifyPhoneNumber({
    required BuildContext context,
    required String phoneNumber,
    required Function toggleLoadingScreen,
    required Function toggleCanSendMessage,
  }) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) =>
            _signInWithVerifiedCredentials(credential),
        verificationFailed: (e) =>
            _throwException(context, e, toggleLoadingScreen),
        codeSent: (String verificationId, int? resendToken) =>
            _redirectToOTPScreen(
                context: context,
                arguments: verificationId,
                toggleLoadingScreen: toggleLoadingScreen,
                toggleCanSendMessage: toggleCanSendMessage),
        codeAutoRetrievalTimeout: (String verificationId) =>
            toggleCanSendMessage(),
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Future _signInWithVerifiedCredentials(PhoneAuthCredential credential) async {
    await auth.signInWithCredential(credential);
  }

  void _throwException(BuildContext context, FirebaseAuthException e,
      Function toggleLoadingScreen) {
    toggleLoadingScreen();
    showSnackBar(context: context, content: e.message!);
  }

  void _redirectToOTPScreen(
      {required BuildContext context,
      required String arguments,
      required Function toggleLoadingScreen,
      required Function toggleCanSendMessage}) async {
    toggleCanSendMessage();
    await Navigator.pushNamed(
      context,
      OTPScreen.routeName,
      arguments: arguments,
    );
    toggleLoadingScreen();
  }
}

class _AuthVerifyOTP {
  final FirebaseAuth auth;

  _AuthVerifyOTP({required this.auth});

  Future signInWithCredential(
      {required BuildContext context,
      required String verificationId,
      required String userOTP}) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOTP);
      await auth.signInWithCredential(credential);
      if (context.mounted) {
        _goingToUserInformationScreen(context: context);
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void _goingToUserInformationScreen({required BuildContext context}) {
    Navigator.pushNamedAndRemoveUntil(
        context, UserInformationScreen.routeName, (route) => false);
  }
}

class _AuthSaveUserData {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  _AuthSaveUserData({
    required this.auth,
    required this.firestore,
  });

  Future savingData(
      {required BuildContext context,
      required String name,
      required File? profilePic,
      required ProviderRef ref}) async {
    try {
      String uid = auth.currentUser!.uid;
      String photoUrl =
          await _ifProfilePicNotNullStoreFileToFirebaseAndReturnDownloadURL(
              uid: uid, profilePic: profilePic, ref: ref);

      var user = UserModel(
        name: name,
        uid: uid,
        profilePic: photoUrl,
        phoneNumber: auth.currentUser!.phoneNumber!,
        isOnline: true,
        groupId: [],
      );

      await firestore.collection('users').doc(uid).set(user.toMap());
      await ref.read(selectContactControllerProvider).syncContacts();
      if (context.mounted) {
        _movingToHomeScreen(context: context);
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Future<String> _ifProfilePicNotNullStoreFileToFirebaseAndReturnDownloadURL(
      {required String uid,
      required File? profilePic,
      required ProviderRef ref}) async {
    if (profilePic == null) {
      return 'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';
    } else {
      return await ref
          .read(sharedFirebaseStorageServiceProvider)
          .storeFileToFirebase(
            'profilePic/$uid',
            profilePic,
          );
    }
  }

  void _movingToHomeScreen({required BuildContext context}) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false);
  }
}
