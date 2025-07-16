import 'package:flutter/material.dart';
import 'register.dart';

class LoginRegist extends StatelessWidget {
  const LoginRegist({super.key});

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

            // Baris tombol Masuk dan fingerprint
            SizedBox(
              width: 248,
              height: 38,
              child: Stack(
                clipBehavior: Clip.none, // biarkan isi boleh keluar
                children: [
                  // Tombol Masuk penuh
                  Container(
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

                  // Fingerprint digeser keluar ke kanan
                  Positioned(
                    right: -50, // geser keluar dari batas 248 px
                    top: 0,
                    child: GestureDetector(
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
                            color: Color(0xFF4B2E2B),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tombol Belum punya akun
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
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
