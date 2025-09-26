import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../l10n/app_localizations.dart';
// Removed direct dependency on app AuthProvider; we use FirebaseAuth directly for prefills

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _cattleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  File? _imageFile;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameCtrl.text = user?.displayName ?? '';
    _emailCtrl.text = user?.email ?? '';
    _phoneCtrl.text = '';
    _ageCtrl.text = '';
    _cattleCtrl.text = '';
    _locationCtrl.text = '';

    // Load existing Firestore profile to prefill fields to prevent overwriting with blanks
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = snap.data();
      if (data == null) return;
      if (mounted) {
        setState(() {
          _nameCtrl.text = (data['name'] as String?)?.trim().isNotEmpty == true
              ? (data['name'] as String)
              : _nameCtrl.text;
          _emailCtrl.text = (data['email'] as String?)?.trim().isNotEmpty == true
              ? (data['email'] as String)
              : _emailCtrl.text;
          _phoneCtrl.text = (data['phoneNumber'] as String?) ?? _phoneCtrl.text;
          _locationCtrl.text = (data['farmLocation'] as String?) ?? _locationCtrl.text;
          final dynamic ageVal = data['age'];
          if (ageVal != null) {
            _ageCtrl.text = ageVal.toString();
          }
          final dynamic cattleVal = data['cattleOwned'];
          if (cattleVal != null) {
            _cattleCtrl.text = cattleVal.toString();
          }
        });
      }
    } catch (_) {
      // Ignore prefill errors; user can still edit
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    _cattleCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 90,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                      child: _imageFile == null
                          ? const Icon(Icons.person, size: 48, color: Colors.black54)
                          : null,
                    ),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                        child: Center(
                          child: Image.asset('assets/images/edit.png', width: 18, height: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _label(l10n.name),
                _field(_nameCtrl, validator: (v) => v!.trim().isEmpty ? l10n.enterName : null),
                _label(l10n.emailAddress),
                _field(_emailCtrl, keyboardType: TextInputType.emailAddress, validator: (v) => v!.contains('@') ? null : l10n.invalidEmail),
                _label(l10n.phoneNumber),
                _field(_phoneCtrl, keyboardType: TextInputType.phone),
                _label(l10n.age),
                _field(_ageCtrl, keyboardType: TextInputType.number),
                _label(l10n.cattleOwned),
                _field(_cattleCtrl, keyboardType: TextInputType.number),
                _label(l10n.location),
                _field(_locationCtrl),
                const SizedBox(height: 24),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          // Force-refresh auth token to avoid permission issues with stale credentials
                          await FirebaseAuth.instance.currentUser?.getIdToken(true);
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid != null) {
                            final nowIso = DateTime.now().toIso8601String();
                            // Upsert user profile with merge to ensure doc exists and fields update
                            // Read existing to perform selective updates (avoid blank overwrites)
                            final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
                            final existing = await docRef.get();
                            final bool exists = existing.exists;
                            final existingData = existing.data() ?? const <String, dynamic>{};

                            final String newName = _nameCtrl.text.trim();
                            final String newPhone = _phoneCtrl.text.trim();
                            final String newLocation = _locationCtrl.text.trim();
                            final String newAgeStr = _ageCtrl.text.trim();
                            final String newCattleStr = _cattleCtrl.text.trim();
                            final String? authEmail = FirebaseAuth.instance.currentUser?.email;
                            if (!exists) {
                              // Strict create per rules with only allowed keys
                              final user = FirebaseAuth.instance.currentUser;
                              final int ageForCreate = (int.tryParse(newAgeStr) ?? 0);
                              final int cattleForCreate = (int.tryParse(newCattleStr) ?? 0);
                              final Map<String, dynamic> createData = {
                                'uid': uid,
                                'name': newName.isNotEmpty ? newName : (user?.displayName ?? ''),
                                'email': user?.email ?? '',
                                'phoneNumber': newPhone,
                                'farmLocation': newLocation,
                                'costPerLiterCow': 50.0,
                                'costPerLiterBuffalo': 55.0,
                                'age': ageForCreate,
                                'cattleOwned': cattleForCreate,
                                'createdAt': nowIso,
                                'updatedAt': nowIso,
                              };
                              await docRef.set(createData);
                            } else {
                              // Build full document for update to satisfy strict rules
                              final int ageUpdated = int.tryParse(newAgeStr) ?? (existingData['age'] as num? ?? 0).toInt();
                              final int cattleUpdated = int.tryParse(newCattleStr) ?? (existingData['cattleOwned'] as num? ?? 0).toInt();
                              final String nameUpdated = newName.isNotEmpty ? newName : (existingData['name'] as String? ?? '');
                              final String phoneUpdated = newPhone.isNotEmpty ? newPhone : (existingData['phoneNumber'] as String? ?? '');
                              final String locationUpdated = newLocation.isNotEmpty ? newLocation : (existingData['farmLocation'] as String? ?? '');
                              final double cowCost = (existingData['costPerLiterCow'] as num?)?.toDouble() ?? 50.0;
                              final double buffaloCost = (existingData['costPerLiterBuffalo'] as num?)?.toDouble() ?? 55.0;
                              final String createdAt = (existingData['createdAt'] as String?) ?? nowIso;
                              final String emailPersist = authEmail ?? (existingData['email'] as String? ?? '');

                              final Map<String, dynamic> fullData = {
                                'uid': uid,
                                'name': nameUpdated,
                                'email': emailPersist,
                                'phoneNumber': phoneUpdated,
                                'farmLocation': locationUpdated,
                                'costPerLiterCow': cowCost,
                                'costPerLiterBuffalo': buffaloCost,
                                'age': ageUpdated,
                                'cattleOwned': cattleUpdated,
                                'createdAt': createdAt,
                                'updatedAt': nowIso,
                              };
                              await docRef.set(fullData);
                            }

                            // Also update FirebaseAuth displayName so app surfaces remain consistent
                            final current = FirebaseAuth.instance.currentUser;
                            if (current != null && current.displayName != _nameCtrl.text.trim()) {
                              await current.updateDisplayName(_nameCtrl.text.trim());
                            }
                          }
                          if (context.mounted) {
                            Navigator.pop(context, {
                              'name': _nameCtrl.text,
                              'email': _emailCtrl.text,
                              'phone': _phoneCtrl.text,
                              'location': _locationCtrl.text,
                              'age': _ageCtrl.text,
                              'cattle': _cattleCtrl.text,
                            });
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to save: $e')),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Colors.black, width: 1.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(l10n.save, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(left: 6.0, bottom: 6.0, top: 16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.black)),
        ),
      );

  Widget _field(TextEditingController controller, {TextInputType? keyboardType, String? Function(String?)? validator}) => TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.transparent)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.transparent)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.black87, width: 1)),
          suffixIcon: const Icon(Icons.edit, size: 18, color: Colors.black87),
        ),
      );
}


