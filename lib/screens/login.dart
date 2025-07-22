import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password wajib diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (response.session != null) {
        // Sukses login, arahkan ke halaman utama
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal login')));
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Terjadi kesalahan')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    );

    final placeholderStyle = const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: Color.fromRGBO(0, 0, 0, 0.4),
    );

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: const Color(0x334B2E2B),
      hintStyle: placeholderStyle,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide.none,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 200, 32, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 1),
                  child: Text(
                    'Selamat Datang di My IMV',
                    style: labelStyle.copyWith(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 3),
                const Padding(
                  padding: EdgeInsets.only(left: 1),
                  child: Text(
                    'Login Akun',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 38),
                Padding(
                  padding: const EdgeInsets.only(left: 1),
                  child: Text('E-mail', style: labelStyle),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 248,
                  height: 28,
                  child: TextField(
                    controller: _emailController,
                    style: labelStyle,
                    decoration: inputDecoration.copyWith(
                      hintText: 'Ketik e-mail anda',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 1),
                  child: Text('Password', style: labelStyle),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 248,
                  height: 28,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: labelStyle,
                    decoration: inputDecoration.copyWith(
                      hintText: 'Ketik Password anda',
                      suffixIcon: const Icon(
                        Icons.visibility_off,
                        color: Color(0xFF4B2E2B),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 38),
                SizedBox(
                  width: 248,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4B2E2B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 248,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Kembali',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B2E2B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
