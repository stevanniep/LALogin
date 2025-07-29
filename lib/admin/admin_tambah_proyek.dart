// admin_tambah_proyek.dart

import 'package:flutter/material.dart';
import 'admin_navbar.dart';
import 'admin_tambah_proyek_kontributor.dart';

class TambahProyekPage extends StatefulWidget {
  const TambahProyekPage({super.key});

  @override
  State<TambahProyekPage> createState() => _TambahProyekPageState();
}

class _TambahProyekPageState extends State<TambahProyekPage> {
  final TextEditingController judulController = TextEditingController();
  final TextEditingController tanggalMulaiController = TextEditingController();
  final TextEditingController tanggalBerakhirController =
      TextEditingController();
  final TextEditingController jumlahKontributorController =
      TextEditingController();
  final TextEditingController tahapanController = TextEditingController();

  List<String> _daftarKontributor = []; // Untuk menyimpan daftar kontributor
  List<String> _daftarTahapan = []; // Untuk menyimpan daftar tahapan

  @override
  void initState() {
    super.initState();
    tanggalMulaiController.text =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
  }

  @override
  void dispose() {
    judulController.dispose();
    tanggalMulaiController.dispose();
    tanggalBerakhirController.dispose();
    jumlahKontributorController.dispose();
    tahapanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
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
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AdminHomePage(initialIndex: 0),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/icons/kembali.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Tambah Proyek',
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

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 70),
                    _inputField('Judul Proyek', judulController),
                    _inputField(
                      'Tanggal mulai',
                      tanggalMulaiController,
                      isTanggal: true,
                    ),
                    _inputField(
                      'Tanggal berakhir',
                      tanggalBerakhirController,
                      isTanggal: true,
                    ),
                    _inputField(
                      'Jumlah kontributor',
                      jumlahKontributorController,
                      keyboardType: TextInputType.number,
                    ),
                    _inputField(
                      'Jumlah Tahapan',
                      tahapanController,
                      keyboardType: TextInputType.number,
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
                          final jumlahKontributor =
                              int.tryParse(jumlahKontributorController.text) ??
                              0;
                          final jumlahTahapan =
                              int.tryParse(tahapanController.text) ?? 0;

                          // Siapkan data proyek awal untuk diteruskan
                          final initialProyekData = {
                            'judul': judulController.text,
                            'mulai': tanggalMulaiController.text,
                            'berakhir': tanggalBerakhirController.text,
                            'jumlahKontributor': jumlahKontributor,
                            'jumlahTahapan': jumlahTahapan,
                          };

                          // Hanya push ke halaman kontributor.
                          // Halaman kontributor yang akan melanjutkan ke halaman tahapan
                          // dan mengembalikan semua data.
                          final resultCompleteData = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TambahProyekKontributorPage(
                                jumlahKontributor: jumlahKontributor,
                                initialProyekData:
                                    initialProyekData, // Teruskan data awal
                              ),
                            ),
                          );

                          if (resultCompleteData != null &&
                              resultCompleteData is Map<String, dynamic>) {
                            setState(() {
                              _daftarKontributor =
                                  resultCompleteData['daftarKontributor'] ?? [];
                              _daftarTahapan =
                                  resultCompleteData['daftarTahapan'] ?? [];
                            });

                            print(
                              "Data proyek lengkap diterima di TambahProyekPage: $resultCompleteData",
                            );
                            // Lakukan proses penyimpanan di sini
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

  Widget _inputField(
    String label,
    TextEditingController controller, {
    bool isTanggal = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
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
            readOnly: false, // Kembalikan ke isTanggal untuk readOnly tanggal
            keyboardType: keyboardType,
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
              suffixIcon: isTanggal
                  ? IconButton(
                      icon: const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.black,
                      ),
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          String formattedDate =
                              "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                          setState(() {
                            controller.text = formattedDate;
                          });
                        }
                      },
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
