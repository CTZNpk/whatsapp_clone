import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SpinKitRing(
          color: myTheme.colorScheme.onSurface,
          size: 50,
        ),
      ),
    );
  }
}
