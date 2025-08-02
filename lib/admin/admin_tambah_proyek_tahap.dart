import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_navbar.dart';

class TambahProyekTahapanPage extends StatefulWidget {
  final int jumlahTahapan;
  // Mengubah nama parameter agar sesuai dengan yang diteruskan dari halaman sebelumnya
  final Map<String, dynamic> initialProyekData;

  const TambahProyekTahapanPage({
    super.key,
    required this.jumlahTahapan,
    // Mengubah nama parameter agar sesuai
    required this.initialProyekData,
  });

  @override
  State<TambahProyekTahapanPage> createState() =>
      _TambahProyekTahapanPageState();
}

class _TambahProyekTahapanPageState extends State<TambahProyekTahapanPage> {
  late List<TextEditingController> _tahapanControllers;
  bool _isLoading = false; // State untuk mengelola indikator loading

  @override
  void initState() {
    super.initState();
    _tahapanControllers = List.generate(
      widget.jumlahTahapan,
      (index) =>
          TextEditingController(), // Menghapus teks default, jadi kosong pada awalnya
    );
  }

  @override
  void dispose() {
    for (var controller in _tahapanControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Fungsi pembantu untuk mengurai string tanggal "DD/MM/YYYY" menjadi objek DateTime
  // Ini penting agar tanggal bisa diformat ulang ke ISO 8601 untuk Supabase
  DateTime _parseDate(String input) {
    try {
      final parts = input.split('/');
      // Memastikan ada 3 bagian (hari, bulan, tahun) sebelum parsing
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      } else {
        // Jika format tidak valid, log error dan kembalikan tanggal saat ini sebagai fallback
        print('Format tanggal tidak valid: $input. Diharapkan DD/MM/YYYY.');
        return DateTime.now();
      }
    } catch (e) {
      // Tangani kesalahan parsing (misalnya, nilai non-angka)
      print('Error parsing tanggal "$input": $e');
      return DateTime.now(); // Fallback ke tanggal saat ini
    }
  }

  // Fungsi untuk menyimpan seluruh data proyek ke Supabase
  Future<void> _saveProjectToSupabase() async {
    setState(() {
      _isLoading = true; // Aktifkan loading
    });

    try {
      final supabase = Supabase.instance.client;

      // Mengonversi string tanggal dari DD/MM/YYYY ke YYYY-MM-DD (ISO 8601)
      final String startDateIso = _parseDate(
        widget.initialProyekData['mulai'],
      ).toIso8601String().substring(0, 10);
      final String endDateIso = _parseDate(
        widget.initialProyekData['berakhir'],
      ).toIso8601String().substring(0, 10);

      // 1. Simpan Data Proyek ke tabel 'projects'
      final projectResponse = await supabase.from('projects').insert(
        {
          'title': widget.initialProyekData['judul'],
          'start_date': startDateIso, // Gunakan format ISO 8601
          'end_date': endDateIso, // Gunakan format ISO 8601
          'created_by':
              supabase.auth.currentUser?.id, // Dapatkan ID pengguna saat ini
        },
      ).select(); // Gunakan .select() untuk mengembalikan data yang dimasukkan, termasuk ID baru

      if (projectResponse.isEmpty) {
        throw Exception('Gagal memasukkan data proyek.');
      }
      final newProjectId =
          projectResponse[0]['id']; // Dapatkan ID proyek yang baru dibuat

      // Mengambil daftar kontributor dari initialProyekData
      final List<String> daftarKontributor = List<String>.from(
        widget.initialProyekData['daftarKontributor'] ?? [],
      );

      // 2. Simpan Kontributor ke tabel 'project_contributors'
      if (daftarKontributor.isNotEmpty) {
        final List<Map<String, dynamic>> contributorsToInsert =
            daftarKontributor.map((username) {
              return {
                'project_id': newProjectId,
                'contributor_username': username,
              };
            }).toList();
        await supabase
            .from('project_contributors')
            .insert(contributorsToInsert);
      }

      // 3. Simpan Tahapan ke tabel 'project_stages'
      if (_tahapanControllers.isNotEmpty) {
        final List<Map<String, dynamic>> stagesToInsert = [];
        for (int i = 0; i < _tahapanControllers.length; i++) {
          stagesToInsert.add({
            'project_id': newProjectId,
            'stage_name': _tahapanControllers[i].text,
            'order_index': i,
            'is_completed': false, // Default: belum selesai
            'completed_at': null, // Default: belum ada waktu selesai
          });
        }
        await supabase.from('project_stages').insert(stagesToInsert);
      }

      // Tampilkan pesan sukses
      // Memastikan widget masih mounted sebelum menggunakan context
      if (mounted) {
        _showMessage('Proyek berhasil disimpan!');
        // Navigasi kembali ke halaman AdminBeranda
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminHomePage(initialIndex: 0),
          ), // Ganti dengan kelas AdminBeranda Anda
          (Route<dynamic> route) =>
              false, // Hapus semua rute sebelumnya dari stack
        );
      }
    } on PostgrestException catch (e) {
      // Tangani error spesifik Supabase
      if (mounted) {
        _showMessage('Error Supabase: ${e.message}', isError: true);
      }
      print('Supabase Error: ${e.message}');
    } catch (e) {
      // Tangani error umum lainnya
      if (mounted) {
        _showMessage('Error menyimpan proyek: $e', isError: true);
      }
      print('General Error: $e');
    } finally {
      setState(() {
        _isLoading = false; // Nonaktifkan loading
      });
    }
  }

  // Fungsi untuk menampilkan snackbar
  void _showMessage(String message, {bool isError = false}) {
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
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      'assets/icons/kembali.png', // Pastikan path benar
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

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 70),
                    // Loop untuk membuat TextField sesuai jumlah tahapan
                    ..._tahapanControllers.asMap().entries.map((entry) {
                      int idx = entry.key;
                      TextEditingController controller = entry.value;
                      return _inputField('Tahap ${idx + 1}', controller);
                    }).toList(),
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
                        // Tombol dinonaktifkan saat loading
                        onPressed: _isLoading ? null : _saveProjectToSupabase,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : const Text(
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

  // Widget pembantu untuk membuat TextField
  Widget _inputField(
    String label,
    TextEditingController controller, {
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
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
