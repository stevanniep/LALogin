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

  Future<void> pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      selectedDate = picked;
      tanggalController.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  Future<void> pilihWaktu() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final formatted = picked.format(context);
      waktuController.text = formatted;
    }
  }

  Future<void> _submit() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final jenis = jenisController.text;
    final judul = judulController.text.trim();
    final hari = hariController.text.trim();
    final tanggal = tanggalController.text.trim();
    final waktu = waktuController.text.trim();
    final tempat = tempatController.text.trim();

    if ((jenis == 'event' && judul.isEmpty) ||
        (jenis == 'harian' && hari.isEmpty) ||
        tanggal.isEmpty || waktu.isEmpty || tempat.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom wajib diisi')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildField(String label, TextEditingController controller, String hint,
      {bool editable = true, Widget? suffixIcon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          SizedBox(
            height: 38,
            child: TextField(
              controller: controller,
              readOnly: !editable && suffixIcon == null,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: hint,
                suffixIcon: suffixIcon,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: editable ? const Color(0xFFF0F0F0) : const Color(0xFFEDEDED),
                border: const OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jenis = jenisController.text;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Buat Presensi',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: jenis,
              decoration: const InputDecoration(
                labelText: 'Jenis Kegiatan',
                labelStyle: TextStyle(fontSize: 12),
                filled: true,
                fillColor: Color(0xFFF0F0F0),
                border: OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'harian', child: Text('Harian')),
                DropdownMenuItem(value: 'event', child: Text('Event')),
              ],
              onChanged: (value) {
                setState(() {
                  jenisController.text = value!;
                  hariController.clear();
                  judulController.clear();
                });
              },
            ),
            const SizedBox(height: 20),

            if (jenis == 'harian') ...[
              DropdownButtonFormField<String>(
                value: hariController.text.isEmpty ? null : hariController.text,
                decoration: const InputDecoration(
                  labelText: 'Pilih Hari',
                  labelStyle: TextStyle(fontSize: 12),
                  filled: true,
                  fillColor: Color(0xFFF0F0F0),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: listHari
                    .map((hari) => DropdownMenuItem(value: hari, child: Text(hari)))
                    .toList(),
                onChanged: (val) => setState(() => hariController.text = val ?? ''),
              ),
              const SizedBox(height: 20),
            ] else
              _buildField('Judul Event', judulController, 'Masukkan nama event'),

            _buildField(
              'Tanggal',
              tanggalController,
              'Pilih tanggal',
              editable: false,
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today, size: 18),
                onPressed: pilihTanggal,
              ),
            ),
            _buildField(
              'Waktu',
              waktuController,
              'Contoh: 08:00',
              suffixIcon: IconButton(
                icon: const Icon(Icons.access_time, size: 18),
                onPressed: pilihWaktu,
              ),
            ),
            _buildField('Tempat', tempatController, 'Masukkan tempat'),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B2E2B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Tambah", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
