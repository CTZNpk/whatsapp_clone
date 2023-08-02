import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String error;
  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    return Center(
      child: Text(
        error,
        style: myTheme.textTheme.displayLarge,
      ),
    );
  }
}
