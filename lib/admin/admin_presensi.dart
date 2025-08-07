import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'admin_qr_page.dart';
import 'admin_navbar.dart';

class AdminPresensi extends StatefulWidget {
  const AdminPresensi({super.key});

  @override
  State<AdminPresensi> createState() => _AdminPresensiState();
}

class _AdminPresensiState extends State<AdminPresensi> {
  final supabase = Supabase.instance.client;

  final jenisController = TextEditingController(text: 'harian');
  final hariController = TextEditingController();
  final judulController = TextEditingController();
  final tanggalController = TextEditingController();
  final waktuController = TextEditingController();
  final tempatController = TextEditingController();

  final listHari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

  DateTime? selectedDate;
  bool isLoading = false;

  @override
  void dispose() {
    jenisController.dispose();
    hariController.dispose();
    judulController.dispose();
    tanggalController.dispose();
    waktuController.dispose();
    tempatController.dispose();
    super.dispose();
  }

  // Fungsi untuk memilih tanggal, disesuaikan dengan tema
  Future<void> pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF4B2E2B),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4B2E2B),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedDate = picked;
      tanggalController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  // Fungsi untuk memilih waktu
  Future<void> pilihWaktu() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4B2E2B), // Warna utama time picker
              onPrimary: Colors.white, // Warna teks pada header
              surface: Colors.white, // Warna latar belakang time picker
              onSurface: Colors.black, // Warna teks pada jam
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = picked.format(context);
      waktuController.text = formatted;
    }
  }

  Future<void> _submit() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      _showSnackBar('Anda harus login untuk membuat presensi.', isError: true);
      return;
    }

    final jenis = jenisController.text;
    final judul = judulController.text.trim();
    final hari = hariController.text.trim();
    final tanggal = tanggalController.text.trim();
    final waktu = waktuController.text.trim();
    final tempat = tempatController.text.trim();

    if ((jenis == 'event' && judul.isEmpty) ||
        (jenis == 'harian' && hari.isEmpty) ||
        tanggal.isEmpty ||
        waktu.isEmpty ||
        tempat.isEmpty) {
      _showSnackBar('Semua kolom wajib diisi', isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final uuid = const Uuid().v4();
      final expired = DateTime.now().add(const Duration(minutes: 15));

      await supabase.from('events').insert({
        'id': uuid,
        'type': jenis,
        'title': jenis == 'event' ? judul : 'Harian',
        'day_of_week': jenis == 'harian' ? hari : null,
        'date': selectedDate?.toIso8601String(),
        'time': waktu,
        'location': tempat,
        'created_by': user.id,
        'created_at': DateTime.now().toIso8601String(),
        'expired_at': expired.toIso8601String(),
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdminQRPage(eventId: uuid)),
      );
    } catch (e) {
      _showSnackBar('Gagal menyimpan: $e', isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF4B2E2B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Widget pembantu untuk field input teks
  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint, {
    bool editable = true,
    Widget? suffixIcon,
    VoidCallback? onTap,
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
          child: TextField(
            controller: controller,
            readOnly: !editable && suffixIcon == null,
            onTap: onTap,
            cursorColor: Colors.black,
            style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              filled: true,
              fillColor: const Color(0xFF4B2E2B).withOpacity(0.2),
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

  // Widget pembantu untuk DropdownButtonFormField
  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
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
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF4B2E2B).withOpacity(0.2),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            items: items.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final jenis = jenisController.text;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar yang sudah diubah
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
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF4B2E2B),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Buat Presensi',
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 70),

                    // Dropdown Jenis Kegiatan
                    _buildDropdownField(
                      'Jenis Kegiatan',
                      jenis,
                      ['harian', 'event'],
                      (value) {
                        setState(() {
                          jenisController.text = value!;
                          hariController.clear();
                          judulController.clear();
                        });
                      },
                    ),

                    if (jenis == 'harian') ...[
                      // Dropdown untuk Hari
                      _buildDropdownField(
                        'Pilih Hari',
                        hariController.text.isEmpty
                            ? null
                            : hariController.text,
                        listHari,
                        (val) =>
                            setState(() => hariController.text = val ?? ''),
                      ),
                    ] else
                      // Input Judul Event
                      _buildField(
                        'Judul Event',
                        judulController,
                        'Masukkan nama event',
                      ),

                    // Input Tanggal
                    _buildField(
                      'Tanggal',
                      tanggalController,
                      'Pilih tanggal',
                      editable: false,
                      onTap: pilihTanggal,
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),

                    // Input Waktu
                    _buildField(
                      'Waktu',
                      waktuController,
                      'Contoh: 08:00',
                      editable: false,
                      onTap: pilihWaktu,
                      suffixIcon: const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),

                    // Input Tempat
                    _buildField('Tempat', tempatController, 'Masukkan tempat'),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: 248,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B2E2B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Tambah",
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
}
