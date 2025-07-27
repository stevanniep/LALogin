import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;

    final email = user?.email ?? '';
    final defaultDisplay = email.contains('@') ? email.split('@')[0] : 'Pengguna';
    final displayName = user?.userMetadata?['display_name'] ?? defaultDisplay;
    final phone = user?.userMetadata?['phone'] ?? '-';

    usernameController.text = displayName;
    emailController.text = email;
    phoneController.text = phone;
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width / 2 - 124;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 3,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Edit Profil", style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 50, bottom: 24),
        child: Column(
          children: [
            _buildField(
              label: 'Username',
              controller: usernameController,
              hint: 'Masukkan nama anda',
              paddingLeft: horizontalPadding,
              maxLength: 15,
            ),
            _buildField(
              label: 'Email',
              controller: emailController,
              hint: 'nama@email.com',
              paddingLeft: horizontalPadding,
              readOnly: true,
            ),
            _buildField(
              label: 'No. Telepon',
              controller: phoneController,
              hint: '08XXXXXXXXXX',
              paddingLeft: horizontalPadding,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 248,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B2E2B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _saveProfile,
                child: const Text("Simpan", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required double paddingLeft,
    bool readOnly = false,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: paddingLeft),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(label, style: const TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 248,
            height: 28,
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              maxLength: maxLength,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: hint,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: const Color(0xFFF0F0F0),
                border: const OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    final newName = usernameController.text.trim();
    final newPhone = phoneController.text.trim();

    if (user != null) {
      try {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(
            data: {
              'display_name': newName,
              'phone': newPhone,
            },
          ),
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil disimpan')),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage(initialIndex: 4)),
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: ${e.toString()}')),
        );
      }
    }
  }
}
