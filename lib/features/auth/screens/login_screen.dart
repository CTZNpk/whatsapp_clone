import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/share/spacing.dart';
import 'package:whatsapp_clone/share/utils/utils.dart';
import 'package:whatsapp_clone/share/widgets/custom_button.dart';
import 'package:whatsapp_clone/share/widgets/loading_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login-screen';
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();
  String? countryCode;
  bool loading = false;
  bool canSendMessage = true;
  bool format = true; 

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void toggleCanSendMessage() {
    canSendMessage = !canSendMessage;
  }

  void toggleLoadingScreen() {
    setState(() {
      loading = !loading;
    });
  }

  void pickCountry() {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      onSelect: (Country country) {
        setState(
          () {
            countryCode = country.phoneCode;
          },
        );
      },
    );
  }

  void sendPhoneNumberToOTP() {
    String phoneNumber = phoneController.text.trim();
    if (countryCode != null && phoneNumber.isNotEmpty && canSendMessage) {
      toggleLoadingScreen();
      ref.read(authControllerProvider).signInWithPhone(
          context,
          '+$countryCode$phoneNumber',
          toggleLoadingScreen,
          toggleCanSendMessage);
    } else if (!canSendMessage) {
      showSnackBar(
          context: context,
          content: 'Wait for 30 seconds after sending sms to send another sms');
    } else {
      showSnackBar(context: context, content: 'Fill out all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    return loading
        ? const LoadingScreen()
        : Scaffold(
            appBar: AppBar(
              title: const Text('Enter your phone number'),
              backgroundColor: myTheme.scaffoldBackgroundColor,
            ),
            body: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PickCountryAndEnterPhoneNumber(
                    pickCountry: pickCountry,
                    countryCode: countryCode,
                    phoneController: phoneController,
                  ),
                  SizedBox(
                    width: 90,
                    child: CustomButton(
                      text: 'Next',
                      onPressed: sendPhoneNumberToOTP,
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

class _PickCountryAndEnterPhoneNumber extends StatelessWidget {
  final VoidCallback pickCountry;
  final String? countryCode;
  final TextEditingController phoneController;

  const _PickCountryAndEnterPhoneNumber(
      {required this.pickCountry,
      required this.countryCode,
      required this.phoneController});

  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Whatsapp will need to verify your phone number.',
          style: myTheme.textTheme.labelMedium,
        ),
        const VerticalSpacing(10),
        _PickCountryButton(pickCountry: pickCountry),
        const VerticalSpacing(5),
        _PhoneNumberInputField(
            phoneController: phoneController, countryCode: countryCode),
      ],
    );
  }
}

class _PickCountryButton extends StatelessWidget {
  final VoidCallback pickCountry;
  const _PickCountryButton({required this.pickCountry});

  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    return TextButton(
      onPressed: pickCountry,
      child: Text(
        'Pick country',
        style: myTheme.textTheme.labelMedium?.copyWith(color: Colors.blue),
      ),
    );
  }
}

class _PhoneNumberInputField extends StatelessWidget {
  final TextEditingController phoneController;
  final String? countryCode;
  const _PhoneNumberInputField(
      {required this.phoneController, required this.countryCode});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        _ShowCountryCode(countryCode: countryCode),
        const HorizontalSpacing(10),
        SizedBox(
          width: size.width * 0.7,
          child: TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              hintText: 'phone number',
            ),
          ),
        ),
      ],
    );
  }
}

class _ShowCountryCode extends StatelessWidget {
  final String? countryCode;
  const _ShowCountryCode({required this.countryCode});

  @override
  Widget build(BuildContext context) {
    return countryCode == null
        ? const SizedBox.shrink()
        : Text('+$countryCode');
  }
}
