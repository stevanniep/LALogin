import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

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

  // Inisialisasi Supabase client
  final SupabaseClient supabase = Supabase.instance.client;

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
        ).format(picked); // Format tanggal untuk ditampilkan di UI
      });
    }
  }

  // Fungsi untuk menyimpan data ke Supabase
  Future<void> _saveActivityToSupabase() async {
    // Validasi input
    if (_jenisKegiatanController.text.isEmpty ||
        _deskripsiAktivitasController.text.isEmpty ||
        _lamaWaktuController.text.isEmpty ||
        _tanggalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field harus diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Mengambil nilai dari controller
      final String activityKind = _jenisKegiatanController.text;
      final String activityDescription = _deskripsiAktivitasController.text;
      final double timeLength = double.parse(
        _lamaWaktuController.text,
      ); // Pastikan ini bisa di-parse sebagai double
      final String date = DateFormat(
        'yyyy-MM-dd',
      ).format(_selectedDate!); // Format tanggal untuk Supabase

      // Menyisipkan data ke tabel 'users_contribution'
      await supabase.from('users_contribution').insert({
        'activity_kind': activityKind,
        'activity_description': activityDescription,
        'time_length': timeLength,
        'date': date,
      });

      // Tampilkan SnackBar sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aktivitas Berhasil Ditambahkan!'),
          backgroundColor: Colors.green,
        ),
      );

      // Kosongkan field setelah ditambah
      _jenisKegiatanController.clear();
      _deskripsiAktivitasController.clear();
      _lamaWaktuController.clear();
      _tanggalController.clear();
      setState(() {
        _selectedDate = null;
      });
    } on FormatException {
      // Tangani error jika lama waktu tidak bisa di-parse sebagai double
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lama waktu harus berupa angka (mis: 2.5)!'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // Tangani error lain dari Supabase
      debugPrint('Error saving to Supabase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan aktivitas: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
                label: 'Lama waktu (Jam)',
                hintText: 'Gunakan bilangan bulat/desimal (mis : 2.5)',
                keyboardType:
                    TextInputType.number, // Ubah ke number untuk input angka
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
                  onPressed:
                      _saveActivityToSupabase, // Panggil fungsi penyimpanan data
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
