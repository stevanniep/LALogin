import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

class DailyActivityPage extends StatefulWidget {
  const DailyActivityPage({super.key});

  @override
  State<DailyActivityPage> createState() => _DailyActivityPageState();
}

class _DailyActivityPageState extends State<DailyActivityPage> {
  // TextEditingController untuk setiap input field
  final TextEditingController _jenisKegiatanController =
      TextEditingController();
  final TextEditingController _deskripsiAktivitasController =
      TextEditingController();
  final TextEditingController _lamaWaktuController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();

  // Variabel untuk menyimpan tanggal yang dipilih
  DateTime? _selectedDate;

  @override
  void dispose() {
    // Pastikan untuk membuang controller saat widget dihapus
    _jenisKegiatanController.dispose();
    _deskripsiAktivitasController.dispose();
    _lamaWaktuController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  // Fungsi untuk memilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF5E4036), // Warna header date picker
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5E4036),
            ), // Warna elemen date picker
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalController.text = DateFormat(
          'dd MMMM yyyy',
        ).format(picked); // Format tanggal
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5E4036)),
          onPressed: () {
            Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
          },
        ),
        title: const Text(
          'Aktivitas Harian',
          style: TextStyle(
            color: Color(0xFF5E4036),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Ratakan ke kiri
            children: [
              const Text(
                'Aktivitas Harian',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5E4036),
                ),
              ),
              const SizedBox(height: 30),

              // Input Jenis Kegiatan
              _buildInputField(
                controller: _jenisKegiatanController,
                label: 'Jenis Kegiatan',
                hintText: 'Mis: Rapat Proyek, Belajar Mandiri',
              ),
              const SizedBox(height: 20),

              // Input Deskripsi Aktivitas
              _buildInputField(
                controller: _deskripsiAktivitasController,
                label: 'Deskripsi Aktivitas',
                hintText: 'Jelaskan aktivitas Anda',
                maxLines: 4, // Biarkan lebih banyak baris untuk deskripsi
              ),
              const SizedBox(height: 20),

              // Input Lama Waktu
              _buildInputField(
                controller: _lamaWaktuController,
                label: 'Lama waktu',
                hintText: 'Mis: 2 jam, 30 menit',
                keyboardType: TextInputType
                    .text, // Teks biasa karena bisa "jam" atau "menit"
              ),
              const SizedBox(height: 20),

              // Input Tanggal (dengan date picker)
              _buildInputField(
                controller: _tanggalController,
                label: 'Tanggal',
                hintText: 'Pilih tanggal',
                readOnly: true, // Tidak bisa diketik langsung
                onTap: () =>
                    _selectDate(context), // Panggil date picker saat ditap
                suffixIcon: Icons.calendar_today, // Ikon kalender
              ),
              const SizedBox(height: 50),

              // Tombol "Tambah"
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Logika yang dijalankan saat tombol "Tambah" ditekan
                    // Anda bisa mendapatkan nilai dari controller:
                    final String jenisKegiatan = _jenisKegiatanController.text;
                    final String deskripsiAktivitas =
                        _deskripsiAktivitasController.text;
                    final String lamaWaktu = _lamaWaktuController.text;
                    final String tanggal = _tanggalController.text;

                    debugPrint('Jenis Kegiatan: $jenisKegiatan');
                    debugPrint('Deskripsi Aktivitas: $deskripsiAktivitas');
                    debugPrint('Lama Waktu: $lamaWaktu');
                    debugPrint('Tanggal: $tanggal');

                    // Tampilkan SnackBar atau lakukan navigasi/simpan data
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Aktivitas Berhasil Ditambahkan!'),
                      ),
                    );
                    // Opsional: Kosongkan field setelah ditambah
                    _jenisKegiatanController.clear();
                    _deskripsiAktivitasController.clear();
                    _lamaWaktuController.clear();
                    _tanggalController.clear();
                    setState(() {
                      _selectedDate = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E4036),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Tambah',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pembangun untuk setiap input field (textbox)
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    int? maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            fillColor: Colors.grey[100], // Warna latar belakang textbox
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), // Sudut membulat
              borderSide: BorderSide.none, // Hilangkan border default
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF5E4036), // Warna border saat fokus
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: Colors.grey[600])
                : null,
          ),
          style: TextStyle(color: Colors.grey[900], fontSize: 16),
        ),
      ],
    );
  }
}
