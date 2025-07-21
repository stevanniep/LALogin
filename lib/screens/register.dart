import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'email_verification.dart';

class RegistPage extends StatefulWidget {
  const RegistPage({super.key});

  @override
  State<RegistPage> createState() => _RegistPageState();
}

class _RegistPageState extends State<RegistPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String? _namaError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  Future<void> _signUp() async {
    setState(() {
      _namaError = _namaController.text.isEmpty ? 'Wajib diisi' : null;
      _emailError = !_emailController.text.contains('@')
          ? 'Masukkan email yang valid'
          : null;
      _passwordError = _passwordController.text.length < 6
          ? 'Minimal 6 karakter'
          : null;
      _confirmPasswordError =
          _confirmPasswordController.text != _passwordController.text
          ? 'Password tidak cocok'
          : null;
    });

    if (_namaError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      return;
    }

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'myapp://login-callback',
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerificationNoticePage(email: email),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Terjadi kesalahan")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget buildFormInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    bool isPasswordToggle = false,
    void Function()? toggleVisibility,
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        const SizedBox(height: 6),
        Container(
          height: 28,
          width: 248,
          decoration: BoxDecoration(
            color: const Color(0x334B2E2B),
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  obscureText: obscure,
                  cursorColor: Colors.black,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(0, 0, 0, 0.4),
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
              if (isPasswordToggle)
                GestureDetector(
                  onTap: toggleVisibility,
                  child: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    size: 16,
                    color: const Color(0xFF4B2E2B),
                  ),
                ),
            ],
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              error,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 11,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 200, 32, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selamat Datang di My IMV',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Daftar Akun',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 38),

                  buildFormInput(
                    label: 'Nama',
                    hint: 'Ketik nama lengkap anda',
                    controller: _namaController,
                    error: _namaError,
                  ),

                  buildFormInput(
                    label: 'E-mail',
                    hint: 'Ketik e-mail anda',
                    controller: _emailController,
                    error: _emailError,
                  ),

                  buildFormInput(
                    label: 'Password',
                    hint: 'Ketik Password anda',
                    controller: _passwordController,
                    obscure: !_isPasswordVisible,
                    isPasswordToggle: true,
                    toggleVisibility: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                    error: _passwordError,
                  ),

                  buildFormInput(
                    label: 'Konfirmasi Password',
                    hint: 'Ketik ulang Password anda',
                    controller: _confirmPasswordController,
                    obscure: !_isConfirmPasswordVisible,
                    isPasswordToggle: true,
                    toggleVisibility: () => setState(
                      () => _isConfirmPasswordVisible =
                          !_isConfirmPasswordVisible,
                    ),
                    error: _confirmPasswordError,
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: 248,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4B2E2B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Daftar',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
