import 'package:flutter/material.dart';

import 'data/app_state.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'theme.dart';

void main() {
  runApp(const SeekaApp());
}

class SeekaApp extends StatelessWidget {
  const SeekaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SEEKA',
      debugShowCheckedModeBanner: false,
      theme: seekaTheme,
      home: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          return AppState.instance.currentUser == null
              ? const LoginScreen()
              : const MainShell();
        },
      ),
    );
  }
}
