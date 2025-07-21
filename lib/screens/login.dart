import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Gaya teks label
    final labelStyle = const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    );

    // Gaya teks placeholder
    final placeholderStyle = const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: Color.fromRGBO(0, 0, 0, 0.4),
    );

    // Dekorasi input box
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: const Color(0x334B2E2B), // Warna 20%
      hintStyle: placeholderStyle,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide.none,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // krem
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 200, 32, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Selamat Datang =====
                Padding(
                  padding: const EdgeInsets.only(left: 1),
                  child: Text(
                    'Selamat Datang di My IMV',
                    style: labelStyle.copyWith(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 3),

                // ===== Login Akun =====
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

                // ===== Email =====
                Padding(
                  padding: const EdgeInsets.only(left: 1),
                  child: Text('E-mail', style: labelStyle),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 248,
                  height: 28,
                  child: TextField(
                    style: labelStyle,
                    decoration: inputDecoration.copyWith(
                      hintText: 'Ketik e-mail anda',
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ===== Password =====
                Padding(
                  padding: const EdgeInsets.only(left: 1),
                  child: Text('Password', style: labelStyle),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 248,
                  height: 28,
                  child: TextField(
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

                // ===== Tombol Login =====
                SizedBox(
                  width: 248,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Tambahkan logika submit di sini
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4B2E2B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
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
                // ===== Tombol Kembali =====
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
