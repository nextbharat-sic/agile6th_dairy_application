// lib/providers/auth_provider_google.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dairy_manager/presentation/dashboard_screen/dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';

import '../backend/repositories/user_repository.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active &&
            snapshot.data != null) {
          return const DashboardScreen();
        }

        return SignInScreen(
          providers: [
            // EmailAuthProvider(),
            GoogleProvider(clientId: clientId),
          ],
          actions: [
            AuthStateChangeAction<SignedIn>((context, state) async {
              try {
                FirebaseFirestore firestore = FirebaseFirestore.instance;
                await UserRepository(firestore).upsertUserOld();
              } catch (e) {
                debugPrint('upsertUserOld failed: $e');
              }
            }),
          ],
          headerBuilder: (context, constraints, shrinkOffset) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Welcome — sign in to continue',
                style: TextStyle(fontSize: 18),
              ),
            );
          },
          footerBuilder: (context, action) {
            return const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'By signing in, you agree to our terms and conditions.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          },
          sideBuilder: (context, shrinkOffset) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text(''),
            );
          },
        );
      },
    );
  }
}
