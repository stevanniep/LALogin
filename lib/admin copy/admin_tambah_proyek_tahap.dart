// admin_tambah_proyek_tahap.dart

import 'package:flutter/material.dart';

class TambahProyekTahapanPage extends StatefulWidget {
  final int jumlahTahapan;
  final Map<String, dynamic> dataProyekDanKontributor; // Tambahkan ini

  const TambahProyekTahapanPage({
    super.key,
    required this.jumlahTahapan,
    required this.dataProyekDanKontributor, // Inisialisasi di constructor
  });

  @override
  State<TambahProyekTahapanPage> createState() =>
      _TambahProyekTahapanPageState();
}

class _TambahProyekTahapanPageState extends State<TambahProyekTahapanPage> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.jumlahTahapan,
      (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar Kustom
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              child: Row(
                children: [
                  GestureDetector(
                    // Tombol kembali di sini akan kembali ke TambahProyekKontributorPage
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      'assets/icons/kembali.png', // Pastikan path icon benar
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Tambah Proyek 3', // Ubah sesuai desain Anda
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

            // Form Input Tahapan
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    for (int i = 0; i < widget.jumlahTahapan; i++)
                      _inputField('Tahap ${i + 1}', _controllers[i]),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 248,
                      height: 38,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B2E2B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          final tahapan = _controllers
                              .map((controller) => controller.text)
                              .toList();
                          Navigator.pop(
                            context,
                            tahapan,
                          ); // Kembali ke TambahProyekKontributorPage dengan data tahapan
                        },
                        child: const Text(
                          'Tambah', // Ubah teks tombol sesuai desain Anda
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
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return Column(
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
            cursorColor: Colors.black,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF4B2E2B).withOpacity(0.2),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
