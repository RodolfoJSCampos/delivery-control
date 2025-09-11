import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: [
        EmailAuthProvider(),
      ],
      actions: [
        // Action executed after a user signs in
        AuthStateChangeAction<SignedIn>((context, state) {
          // Since AuthGate handles navigation, we don't need to do anything here.
        }),
      ],
    );
  }
}