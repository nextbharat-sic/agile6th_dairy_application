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
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid != null) {
                            final nowIso = DateTime.now().toIso8601String();
                            await FirebaseFirestore.instance.collection('users').doc(uid).update({
                              'name': _nameCtrl.text.trim(),
                              // email is immutable per rules
                              'phoneNumber': _phoneCtrl.text.trim(),
                              'farmLocation': _locationCtrl.text.trim(),
                              'updatedAt': nowIso,
                            });
                          }
                          if (context.mounted) {
                            Navigator.pop(context, {
                              'name': _nameCtrl.text,
                              'email': _emailCtrl.text,
                              'phone': _phoneCtrl.text,
                              'location': _locationCtrl.text,
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


