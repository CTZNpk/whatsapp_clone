import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    return Center(
      child: SpinKitRing(
        color: myTheme.colorScheme.onSurface,
      ),
    );
  }
}
