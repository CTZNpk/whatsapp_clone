import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/services/auth_service.dart';
import 'package:whatsapp_clone/share/model/user_model.dart';

final authControllerProvider = Provider(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    return AuthController(authService: authService, ref: ref);
  },
);

final userDataAuthProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider);
  return authController.getUserData();
});

class AuthController {
  final AuthService authService;
  final ProviderRef ref;

  AuthController({required this.authService, required this.ref});

  Future<UserModel?> getUserData() async {
    UserModel? user = await authService.getCurrentUserData();
    return user;
  }

  void signInWithPhone(BuildContext context, String phoneNumber,
      Function toggleLoadingScreen, Function toggleCanSendMessage) {
    authService.signInWithPhone(
        context, phoneNumber, toggleLoadingScreen, toggleCanSendMessage);
  }

  void verifyOTP(BuildContext context, String verificationId, String userOTP) {
    authService.verifyOTP(
      verificationId: verificationId,
      context: context,
      userOTP: userOTP,
    );
  }

  void saveUserDataToFirebase(
      BuildContext context, String name, File? profilePic) {
    authService.saveUserData(
      context: context,
      name: name,
      profilePic: profilePic,
      ref: ref,
    );
  }
  void setUserState(bool isOnline){
    authService.setUserState(isOnline);
  }
}
