import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    return ElevatedButton(
      onPressed: () => onPressed(),
      style: myTheme.elevatedButtonTheme.style,
      child: Text(
        text,
      ),
    );
  }
}
