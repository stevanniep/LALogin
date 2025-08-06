import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart'; // Pastikan ini sudah benar

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

  // Fungsi untuk menampilkan snackbar (pengganti alert)
  void _showSnackBar(String message, {bool isError = false}) {
    // Pastikan widget masih ada di widget tree sebelum menampilkan snackbar
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF4B2E2B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 12,
                left: 16,
                right: 16,
                bottom: 12,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      'assets/icons/kembali.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Edit Profil',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF4B2E2B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        // Menghapus padding vertikal dari sini dan hanya menyisakan padding horizontal
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: Column(
            // Tambahkan SizedBox di sini untuk mengatur jarak
            children: [
              const SizedBox(height: 40),
              _buildField(
                'Nama Lengkap',
                fullNameController,
                'Masukkan nama lengkap',
                editable: true,
              ),
              _buildField(
                'Username',
                usernameController,
                'Masukkan username',
                maxLength: 15,
                editable: true,
              ),
              _buildField('NIM', nimController, 'Masukkan NIM', editable: true),
              _buildField('Email', emailController, '', editable: false),
              _buildField('Role', roleController, '', editable: false),
              const SizedBox(height: 30),
              SizedBox(
                width: 248,
                height: 38,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B2E2B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      : const Text(
                          "Simpan",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: 248,
            height: 30,
            child: TextField(
              controller: controller,
              readOnly: !editable,
              maxLength: maxLength,
              cursorColor: Colors.black,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: hint,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                filled: true,
                fillColor: editable
                    ? const Color(0xFF4B2E2B).withOpacity(0.2)
                    : const Color(0xFF4B2E2B).withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
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
      _showSnackBar(
        'Nama, Username, dan NIM tidak boleh kosong',
        isError: true,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await supabase
          .from('profiles')
          .update({'full_name': fullName, 'username': username, 'nim': nim})
          .eq('user_id', user.id);

      if (!mounted) return;
      _showSnackBar('Profil berhasil disimpan');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage(initialIndex: 4)),
        (route) => false,
      );
    } catch (e) {
      _showSnackBar('Gagal menyimpan profil: $e', isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
