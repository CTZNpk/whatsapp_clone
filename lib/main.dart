import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/firebase_options.dart';
import 'package:whatsapp_clone/router.dart';
import 'package:whatsapp_clone/screens/home.dart';
import 'package:whatsapp_clone/share/widgets/error.dart';
import 'package:whatsapp_clone/share/widgets/loading_screen.dart';
import 'features/landing/screens/landing.dart';
import 'package:whatsapp_clone/themes/dark_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WhatsApp UI',
      onGenerateRoute: (settings) => generateRoute(settings),
      themeMode: ThemeMode.dark,
      darkTheme: MyAppTheme.dark,
      home: ref.watch(userDataAuthProvider).when(
        data: (user) {
          if (user == null) {
            return const LandingScreen();
          } else {
            return const HomeScreen();
          }
        },
        error: (error, trace) {
          return ErrorScreen(error: error.toString());
        },
        loading: () {
          return const LoadingScreen();
        },
      ),
    );
  }
}
