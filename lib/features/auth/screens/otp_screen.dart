import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/share/spacing.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';

class OTPScreen extends ConsumerWidget {
  static const String routeName = '/otp-screen';
  final String verificationId;
  const OTPScreen({super.key, required this.verificationId});

  void verifyOTP(WidgetRef ref, BuildContext context, String userOTP) {
    ref
        .read(authControllerProvider)
        .verifyOTP(context, verificationId, userOTP);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myTheme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifying your number'),
        centerTitle: true,
        backgroundColor: myTheme.scaffoldBackgroundColor,
      ),
      body: Center(
        child: Column(
          children: [
            const VerticalSpacing(20),
            const Text('We have sent an SMS with a code.'),
            _OTPTextField(verifyOTP: verifyOTP),
          ],
        ),
      ),
    );
  }
}

class _OTPTextField extends ConsumerWidget {
  final Function verifyOTP;
  const _OTPTextField({required this.verifyOTP});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.5,
      child: TextField(
        textAlign: TextAlign.center,
        maxLength: 6,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        decoration: const InputDecoration(
          hintText: '- - - - - -',
          hintStyle: TextStyle(
            fontSize: 30,
          ),
        ),
        keyboardType: TextInputType.number,
        onChanged: (val) {
          if (val.length == 6) {
            verifyOTP(ref, context, val);
          }
        },
      ),
    );
  }
}
