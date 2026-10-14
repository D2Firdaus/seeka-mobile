import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'data/auth_store.dart';
import 'features/auth/login_screen.dart';
import 'features/shell/main_shell.dart';

class SeekaApp extends StatelessWidget {
  const SeekaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SEEKA',
      debugShowCheckedModeBanner: false,
      theme: seekaTheme,
      home: ListenableBuilder(
        listenable: AuthStore.instance,
        builder: (context, _) {
          return AuthStore.instance.currentUser == null
              ? const LoginScreen()
              : const MainShell();
        },
      ),
    );
  }
}
