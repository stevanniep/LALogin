import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'register.dart';
import 'login.dart';
import '../pages/home_page.dart'; // Asumsikan ini adalah halaman utama setelah login

class LoginRegistPage extends StatefulWidget {
  const LoginRegistPage({super.key});

  @override
  State<LoginRegistPage> createState() => _LoginRegistPageState();
}

class _LoginRegistPageState extends State<LoginRegistPage> {
  final supabase = Supabase.instance.client;
  final localAuth = LocalAuthentication();
  final secureStorage = const FlutterSecureStorage();
  bool isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final token = await secureStorage.read(key: 'biometric_token');
    print('biometric_token: $token');
    setState(() {
      isBiometricEnabled = token != null;
    });
  }

  Future<void> _signInWithBiometric() async {
    try {
      final isAuthenticated = await localAuth.authenticate(
        localizedReason: 'Pindai biometrik Anda untuk masuk',
      );

      if (isAuthenticated) {
        final refreshToken = await secureStorage.read(key: 'biometric_token');
        if (refreshToken != null) {
          try {
            // Perubahan utama di sini:
            // 1. setSession sekarang menerima refresh token sebagai argumen posisi
            // 2. Tidak perlu lagi memeriksa 'response.error' karena akan langsung melempar exception
            await supabase.auth.setSession(refreshToken);

            // Jika tidak ada exception, berarti login berhasil
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
              );
            }
          } on AuthException catch (e) {
            // Tangani AuthException secara spesifik
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Sesi kedaluwarsa. Silakan masuk secara manual. Error: ${e.message}',
                  ),
                ),
              );
              await secureStorage.delete(key: 'biometric_token');
              _checkBiometricStatus();
            }
          } catch (e) {
            // Tangani exception lainnya
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error saat mencoba set sesi: $e')),
              );
              // Hapus token jika ada masalah lain
              await secureStorage.delete(key: 'biometric_token');
              _checkBiometricStatus();
            }
          }
        }
      }
    } catch (e) {
      // Tangani error dari localAuth.authenticate
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Otentikasi biometrik gagal: $e')),
        );
      }
    }
  }

  void _showEnableBiometricPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const Text(
                  'Aktifkan Akses Pintar',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Akses akun lebih mudah dengan mengaktifkan masuk menggunakan biometrik pada menu profil',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 248,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4B2E2B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Mengerti',
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/logo_lab.png',
              width: 235,
              height: 111,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 50),

            // Baris tombol Masuk + fingerprint
            // Stack wrapper
            Stack(
              alignment: Alignment.center,
              children: [
                // Tombol Masuk (posisi utama, tetap di tengah)
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: Container(
                      width: 248,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4B2E2B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Tombol Biometrik (posisi melayang, disamping tombol Masuk)
                Positioned(
                  right:
                      MediaQuery.of(context).size.width / 2 -
                      248 / 2 -
                      48, // posisi di kiri tombol Masuk
                  top: 0, // sesuaikan ketinggiannya
                  child: GestureDetector(
                    onTap: () {
                      print('Fingerprint tapped');
                      if (isBiometricEnabled) {
                        _signInWithBiometric();
                      } else {
                        _showEnableBiometricPopup();
                      }
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/fingerprint.png',
                          width: 20,
                          height: 20,
                          color: const Color(0xFF4B2E2B),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tombol Belum punya akun -> ke RegistPage
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegistPage()),
                );
              },
              child: Container(
                width: 248,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Belum punya akun',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF4B2E2B),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
