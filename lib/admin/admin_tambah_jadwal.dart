import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Asumsi admin_navbar.dart ada di path yang sama atau sudah ditambahkan ke pubspec.yaml
import 'admin_navbar.dart';

class TambahJadwalPage extends StatefulWidget {
  const TambahJadwalPage({super.key});

  @override
  State<TambahJadwalPage> createState() => _TambahJadwalPageState();
}

class _TambahJadwalPageState extends State<TambahJadwalPage> {
  // Controllers untuk input text fields
  final TextEditingController namaController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController tempatController = TextEditingController();
  final TextEditingController waktuController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Mengatur teks awal untuk tanggal menjadi tanggal hari ini
    // Format: DD/MM/YYYY
    tanggalController.text =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
  }

  // Fungsi untuk mengurai string tanggal "DD/MM/YYYY" menjadi objek DateTime
  DateTime _parseDate(String input) {
    // Memisahkan string berdasarkan karakter '/'
    final parts = input.split('/');
    // Mengonversi bagian-bagian string menjadi integer
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    // Mengembalikan objek DateTime
    return DateTime(year, month, day);
  }

  @override
  void dispose() {
    // Penting: Membuang controllers untuk mencegah kebocoran memori
    namaController.dispose();
    tanggalController.dispose();
    tempatController.dispose();
    waktuController.dispose();
    super.dispose();
  }

  // Fungsi untuk menampilkan snackbar (pengganti alert)
  void _showSnackBar(String message, {bool isError = false}) {
    // Pastikan widget masih ada di widget tree sebelum menampilkan snackbar
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF4B2E2B),
      ),
    );
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
              padding: const EdgeInsets.only(
                top: 12,
                left: 16,
                right: 16,
                bottom: 12,
              ),
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
                      // Menggunakan pushReplacement untuk kembali ke halaman AdminHomePage
                      // ini akan menggantikan rute saat ini di stack navigasi
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AdminHomePage(initialIndex: 0),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/icons/kembali.png', // Pastikan path aset ini benar
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Tambah Jadwal',
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

            // Body content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 70), // Jarak dari AppBar
                    _inputField('Nama Kegiatan', namaController),
                    _inputField('Tanggal', tanggalController),
                    _inputField('Tempat', tempatController),
                    _inputField('Waktu', waktuController),
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
                          // Inisialisasi klien Supabase
                          final supabase = Supabase.instance.client;

                          try {
                            // Memasukkan data ke tabel 'jadwal_kegiatan'
                            // Supabase secara otomatis akan mengonversi DateTime ke tipe 'date' atau 'timestamp'
                            await supabase.from('jadwal_kegiatan').insert({
                              'nama': namaController.text,
                              'tanggal': _parseDate(
                                tanggalController.text,
                              ).toIso8601String(), // Konversi ke ISO 8601 string untuk konsistensi
                              'tempat': tempatController.text,
                              'waktu': waktuController.text,
                              'user_id': supabase.auth.currentUser!.id,
                            });

                            // Menampilkan snackbar sukses
                            _showSnackBar('Jadwal berhasil ditambahkan');

                            // Kembali ke halaman sebelumnya setelah berhasil menyimpan
                            // Pastikan widget masih ada sebelum pop
                            if (!mounted) return;
                            Navigator.pop(context);
                          } catch (e) {
                            // Menampilkan snackbar error jika terjadi kesalahan
                            _showSnackBar(
                              'Gagal menambahkan jadwal: $e',
                              isError: true,
                            );
                          }
                        },
                        child: const Text(
                          'Tambah',
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
            // Jika label adalah 'Tanggal', maka field akan readOnly agar hanya bisa dipilih dari date picker
            // Jika tidak, field bisa diedit manual
            readOnly: label == 'Tanggal',
            onTap:
                label ==
                    'Tanggal' // Menambahkan onTap agar date picker muncul saat di-tap
                ? () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _parseDate(
                        tanggalController.text,
                      ), // Set initial date from current value
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      // Format tanggal ke DD/MM/YYYY
                      String formattedDate =
                          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      // Memperbarui controller teks dengan tanggal yang dipilih
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
              // Menampilkan ikon kalender hanya untuk field 'Tanggal'
              suffixIcon: label == 'Tanggal'
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
