import 'package:flutter/material.dart';
import 'admin_navbar.dart'; // Pastikan path ini benar
import 'admin_tambah_proyek_kontributor.dart'; // Pastikan path ini benar

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

  // Daftar ini tidak lagi digunakan untuk penyimpanan langsung di sini,
  // tetapi bisa digunakan jika Anda ingin menampilkan data yang dikumpulkan
  // setelah proses penyimpanan selesai di halaman lain.
  List<String> _daftarKontributor = [];
  List<String> _daftarTahapan = [];

  @override
  void initState() {
    super.initState();
    // Mengatur tanggal mulai default ke tanggal hari ini
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

  // Fungsi pembantu untuk mengurai string tanggal "DD/MM/YYYY" menjadi objek DateTime
  DateTime _parseDate(String input) {
    try {
      final parts = input.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (e) {
      // Jika parsing gagal (misalnya string kosong atau format salah), kembalikan tanggal hari ini
      return DateTime.now();
    }
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
                      // Kembali ke AdminHomePage
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AdminHomePage(initialIndex: 0),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/icons/kembali.png', // Pastikan path benar
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
                    // Input Judul Proyek
                    _inputField('Judul Proyek', judulController),
                    // Input Tanggal Mulai (dengan date picker)
                    _inputField(
                      'Tanggal mulai',
                      tanggalMulaiController,
                      isTanggal: true,
                    ),
                    // Input Tanggal Berakhir (dengan date picker)
                    _inputField(
                      'Tanggal berakhir',
                      tanggalBerakhirController,
                      isTanggal: true,
                    ),
                    // Input Jumlah Kontributor (hanya angka)
                    _inputField(
                      'Jumlah kontributor',
                      jumlahKontributorController,
                      keyboardType: TextInputType.number,
                    ),
                    // Input Jumlah Tahapan (hanya angka)
                    _inputField(
                      'Jumlah Tahapan',
                      tahapanController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 30),
                    // Tombol Lanjut
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
                          // Mengambil nilai jumlah kontributor dan tahapan
                          final jumlahKontributor =
                              int.tryParse(jumlahKontributorController.text) ??
                              0;
                          final jumlahTahapan =
                              int.tryParse(tahapanController.text) ?? 0;

                          // Siapkan data proyek awal untuk diteruskan ke halaman kontributor
                          final initialProyekData = {
                            'judul': judulController.text,
                            'mulai': tanggalMulaiController.text,
                            'berakhir': tanggalBerakhirController.text,
                            'jumlahKontributor': jumlahKontributor,
                            'jumlahTahapan': jumlahTahapan,
                          };

                          // Navigasi ke halaman TambahProyekKontributorPage
                          // dan tunggu hasil pengumpulan data dari halaman tahapan
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

                          // Jika ada data lengkap yang dikembalikan dari halaman tahapan (setelah penyimpanan)
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
                            // Pada titik ini, data proyek seharusnya sudah disimpan di Supabase oleh TambahProyekTahapanPage.
                            // Anda bisa menambahkan logika lain di sini jika diperlukan setelah penyimpanan.
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

  // Widget pembantu untuk membuat TextField
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
            // Mengatur readOnly berdasarkan isTanggal
            readOnly: isTanggal,
            keyboardType: keyboardType,
            // Menambahkan onTap agar date picker muncul saat di-tap jika ini adalah field tanggal
            onTap: isTanggal
                ? () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      // Menggunakan _parseDate untuk mengatur initialDate dari nilai controller saat ini
                      initialDate: _parseDate(controller.text),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      // Format tanggal yang dipilih ke DD/MM/YYYY
                      String formattedDate =
                          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      setState(() {
                        controller.text = formattedDate;
                      });
                    }
                  }
                : null,
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
              // Menambahkan ikon kalender jika isTanggal true
              suffixIcon: isTanggal
                  ? const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.black,
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
