import 'package:flutter/material.dart';

import '../../providers/auth_provider_google.dart';


class LoginScreenGoogle extends StatelessWidget {
  const LoginScreenGoogle({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AuthGate(clientId: clientId),
    );
  }
}