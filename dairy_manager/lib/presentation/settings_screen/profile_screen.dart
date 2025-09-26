import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final fallbackName = authProvider.userName ?? 'User';
    final fallbackEmail = authProvider.userEmail ?? 'user@example.com';
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 180,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        title: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseAuth.instance.currentUser == null
              ? null
              : FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data() ?? const <String, dynamic>{};
            final liveName = (data['name'] ?? fallbackName).toString();
            return Stack(
          clipBehavior: Clip.none,
          children: [
            // Back button
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Center avatar and name (force centered alignment)
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  CircleAvatar(
                    radius: 54,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.black,
                      child: Text(
                        liveName.isNotEmpty ? liveName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    liveName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Edit icon on right
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTapDown: (_) {},
                  onTap: () async {
                    final updated = await Navigator.pushNamed(context, '/profile-edit') as Map<String, String>?;
                    if (updated != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated')),
                      );
                    }
                  },
                  child: Image.asset(
                    'assets/images/edit.png',
                    width: 28,
                    height: 28,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
            );
          },
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseAuth.instance.currentUser == null
              ? null
              : FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data() ?? {};
            final name = (data['name'] ?? fallbackName).toString();
            final email = (data['email'] ?? fallbackEmail).toString();
            final phone = (data['phoneNumber'] ?? '---').toString();
            final location = (data['farmLocation'] ?? '---').toString();
            final age = (data['age'] != null) ? data['age'].toString() : '—';
            final cattleOwned = (data['cattleOwned'] != null) ? data['cattleOwned'].toString() : '—';
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Update header name live when stream updates
                  if (name != fallbackName) ...[
                    const SizedBox(height: 0),
                  ],
                  _label(l10n.emailAddress),
                  _input(context, value: email),
                  const SizedBox(height: 12),
                  _label(l10n.phoneNumber),
                  _input(context, value: phone),
                  const SizedBox(height: 12),
                  _label(l10n.age),
                  _input(context, value: age),
                  const SizedBox(height: 12),
                  _label(l10n.cattleOwned),
                  _input(context, value: cattleOwned),
                  const SizedBox(height: 12),
                  _label(l10n.location),
                  _input(context, value: location),
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      width: 180,
                      child: OutlinedButton(
                        onPressed: () => _showLogoutDialog(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          side: const BorderSide(color: Colors.black, width: 1.5),
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                        ),
                        child: Text(
                          l10n.logout,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0, bottom: 6.0, top: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _input(BuildContext context, {required String value}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile-edit'),
            child: const Icon(Icons.edit, size: 18, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          l10n.logout,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          l10n.logoutConfirmation,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              Navigator.pushReplacementNamed(context, '/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: AppTheme.whiteColor,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
} 