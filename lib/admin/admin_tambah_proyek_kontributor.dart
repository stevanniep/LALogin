// admin_tambah_proyek_kontributor.dart

import 'package:flutter/material.dart';
import 'admin_tambah_proyek_tahap.dart'; // Import halaman tahapan

class TambahProyekKontributorPage extends StatefulWidget {
  final int jumlahKontributor;
  final Map<String, dynamic> initialProyekData; // Tambahkan ini

  const TambahProyekKontributorPage({
    super.key,
    required this.jumlahKontributor,
    required this.initialProyekData, // Inisialisasi di constructor
  });

  @override
  State<TambahProyekKontributorPage> createState() =>
      _TambahProyekKontributorPageState();
}

class _TambahProyekKontributorPageState
    extends State<TambahProyekKontributorPage> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.jumlahKontributor,
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
                    onTap: () =>
                        Navigator.pop(context), // Kembali ke TambahProyekPage
                    child: Image.asset(
                      'assets/icons/kembali.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Tambah Proyek 2', // Ubah judul jika perlu
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

            // Form Input
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    for (int i = 0; i < widget.jumlahKontributor; i++)
                      _inputField(
                        'Username Kontributor ${i + 1}',
                        _controllers[i],
                      ),
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
                        onPressed: () async {
                          final usernames = _controllers
                              .map((controller) => controller.text)
                              .toList();

                          // Siapkan data yang akan diteruskan ke halaman tahapan
                          // Gabungkan data proyek awal + data kontributor
                          Map<String, dynamic> dataUntukTahapan = Map.from(
                            widget.initialProyekData,
                          );
                          dataUntukTahapan['daftarKontributor'] = usernames;

                          // Push ke halaman tahapan
                          final resultTahapan = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TambahProyekTahapanPage(
                                jumlahTahapan: widget
                                    .initialProyekData['jumlahTahapan'], // Ambil dari data awal
                                dataProyekDanKontributor:
                                    dataUntukTahapan, // Teruskan data gabungan
                              ),
                            ),
                          );

                          // Setelah kembali dari halaman tahapan,
                          // kembalikan semua data ke TambahProyekPage
                          if (resultTahapan != null &&
                              resultTahapan is List<String>) {
                            // Gabungkan semua data untuk dikembalikan ke TambahProyekPage
                            Map<String, dynamic> completeProyekData = Map.from(
                              dataUntukTahapan,
                            );
                            completeProyekData['daftarTahapan'] = resultTahapan;
                            Navigator.pop(context, completeProyekData);
                          }
                        },
                        child: const Text(
                          'Lanjut',
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
