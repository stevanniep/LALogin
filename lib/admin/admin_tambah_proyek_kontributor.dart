import 'package:flutter/material.dart';
import 'admin_tambah_proyek_tahap.dart'; // Pastikan path ini benar dan mengarah ke file tahapan

class TambahProyekKontributorPage extends StatefulWidget {
  final int jumlahKontributor;
  final Map<String, dynamic>
  initialProyekData; // Data proyek dari halaman sebelumnya

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
  late List<TextEditingController>
  _kontributorControllers; // Mengganti _controllers menjadi _kontributorControllers untuk kejelasan

  @override
  void initState() {
    super.initState();
    _kontributorControllers = List.generate(
      // Menggunakan _kontributorControllers
      widget.jumlahKontributor,
      (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (var controller in _kontributorControllers) {
      // Menggunakan _kontributorControllers
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
                      'assets/icons/kembali.png', // Pastikan path aset ini benar
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Tambah Proyek', // Judul halaman
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

            // Form Input Kontributor
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    // Loop untuk membuat TextField sesuai jumlah kontributor
                    for (int i = 0; i < widget.jumlahKontributor; i++)
                      _inputField(
                        'Username Kontributor ${i + 1}',
                        _kontributorControllers[i], // Menggunakan _kontributorControllers
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
                          // Mengumpulkan username kontributor dari semua TextEditingController
                          final List<String> daftarKontributor =
                              _kontributorControllers
                                  .map(
                                    (c) => c.text.trim(),
                                  ) // Ambil teks dan hapus spasi di awal/akhir
                                  .where(
                                    (text) => text.isNotEmpty,
                                  ) // Hanya ambil yang tidak kosong
                                  .toList();

                          // Siapkan data yang akan diteruskan ke halaman tahapan
                          // Gabungkan data proyek awal + data kontributor
                          Map<String, dynamic> dataUntukTahapan = Map.from(
                            widget.initialProyekData,
                          );
                          dataUntukTahapan['daftarKontributor'] =
                              daftarKontributor;

                          // Navigasi ke halaman TambahProyekTahapanPage
                          // dan tunggu hasil (yang mungkin berisi sinyal bahwa penyimpanan sudah selesai)
                          final resultTahapan = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TambahProyekTahapanPage(
                                // Ambil jumlah tahapan dari initialProyekData
                                jumlahTahapan:
                                    widget.initialProyekData['jumlahTahapan'],
                                // Teruskan data gabungan (proyek awal + kontributor)
                                initialProyekData: dataUntukTahapan,
                              ),
                            ),
                          );

                          // Setelah kembali dari halaman tahapan,
                          // kembalikan hasil (jika ada) ke TambahProyekPage
                          if (resultTahapan != null) {
                            Navigator.pop(context, resultTahapan);
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

  // Widget pembantu untuk membuat field input teks
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
