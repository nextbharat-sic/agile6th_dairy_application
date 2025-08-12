import 'package:flutter/material.dart';

import 'login_screen.dart';


class LoginScreenGoogle extends StatelessWidget {
  const LoginScreenGoogle({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    // Use the custom LoginScreen UI
    return const LoginScreen();
  }
}