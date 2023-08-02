import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/auth/screens/login_screen.dart';
import 'package:whatsapp_clone/share/spacing.dart';
import 'package:whatsapp_clone/share/widgets/custom_button.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void navigateToLoginScreen(BuildContext context) {
    Navigator.pushNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            VerticalSpacing(size.height / 15),
            const _WelcomeText(),
            VerticalSpacing(size.height / 15),
            const _WelcomeImage(),
            VerticalSpacing(size.height / 15),
            const _TermsOfServiceText(),
            const VerticalSpacing(10),
            _AgreeAndContinueButton(
              navigateToLoginScreen: navigateToLoginScreen,
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeText extends StatelessWidget {
  const _WelcomeText();

  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    return Center(
      child: Text(
        'Welcome to WhatsApp',
        style: myTheme.textTheme.displayLarge,
      ),
    );
  }
}

class _WelcomeImage extends StatelessWidget {
  const _WelcomeImage();

  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    return Image.asset(
      'assets/bg.png',
      height: 340,
      width: 340,
      color: myTheme.colorScheme.onSurface,
    );
  }
}

class _TermsOfServiceText extends StatelessWidget {
  const _TermsOfServiceText();

  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        'Read our Privacy Policy. Tap "Agree and continue" to accept the Terms of Service',
        style: myTheme.textTheme.labelSmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _AgreeAndContinueButton extends StatelessWidget {
  final Function navigateToLoginScreen;
  const _AgreeAndContinueButton({required this.navigateToLoginScreen});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.75,
      child: CustomButton(
        text: 'AGREE AND CONTINUE',
        onPressed: () => navigateToLoginScreen(context),
      ),
    );
  }
}
