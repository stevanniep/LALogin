import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../admin/admin_navbar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final supabase = Supabase.instance.client;

  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final nimController = TextEditingController();
  final emailController = TextEditingController();
  final roleController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('profiles')
        .select('full_name, username, nim, email, role')
        .eq('user_id', user.id)
        .maybeSingle();

    if (response != null) {
      fullNameController.text = response['full_name'] ?? '';
      usernameController.text = response['username'] ?? '';
      nimController.text = response['nim'] ?? '';
      emailController.text = response['email'] ?? '';
      roleController.text = response['role'] ?? '';
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    nimController.dispose();
    emailController.dispose();
    roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profil",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          children: [
            _buildField('Nama Lengkap', fullNameController, 'Masukkan nama lengkap', editable: true),
            _buildField('Username', usernameController, 'Masukkan username', maxLength: 15, editable: true),
            _buildField('NIM', nimController, 'Masukkan NIM', editable: true),
            _buildField('Email', emailController, '', editable: false),
            _buildField('Role', roleController, '', editable: false),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B2E2B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Simpan", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint, {
    bool editable = true,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          SizedBox(
            height: 38,
            child: TextField(
              controller: controller,
              readOnly: !editable,
              maxLength: maxLength,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: hint,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: editable ? const Color(0xFFF0F0F0) : const Color(0xFFEDEDED),
                border: const OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final fullName = fullNameController.text.trim();
    final username = usernameController.text.trim();
    final nim = nimController.text.trim();

    if (fullName.isEmpty || username.isEmpty || nim.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama, Username, dan NIM tidak boleh kosong')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await supabase.from('profiles').update({
        'full_name': fullName,
        'username': username,
        'nim': nim,
      }).eq('user_id', user.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil disimpan')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AdminHomePage(initialIndex: 4)),
        (route) => false,
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan profil: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
