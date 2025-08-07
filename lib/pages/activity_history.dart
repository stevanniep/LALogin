import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Halaman Riwayat Aktivitas
class ActivityHistoryPage extends StatefulWidget {
  const ActivityHistoryPage({super.key});

  @override
  State<ActivityHistoryPage> createState() => _ActivityHistoryPageState();
}

class _ActivityHistoryPageState extends State<ActivityHistoryPage> {
  // Inisialisasi Supabase client
  final SupabaseClient _supabase = Supabase.instance.client;

  // Future untuk menyimpan hasil pengambilan data aktivitas
  late Future<List<Map<String, dynamic>>> _futureActivities;

  @override
  void initState() {
    super.initState();
    // Memuat data aktivitas saat widget diinisialisasi
    _futureActivities = _fetchActivities();
  }

  // Fungsi asinkron untuk mengambil data aktivitas dari Supabase
  Future<List<Map<String, dynamic>>> _fetchActivities() async {
    try {
      // Mendapatkan ID pengguna yang sedang login
      final userId = _supabase.auth.currentUser!.id;

      // Melakukan kueri ke tabel 'contribution_history'
      // dan melakukan JOIN dengan tabel 'users_contribution'
      // Mengambil semua kolom dari kedua tabel
      final data = await _supabase
          .from('contribution_history')
          .select(
            '*, users_contribution(*)',
          ) // Mengambil semua kolom dari contribution_history dan users_contribution
          .eq('user_id', userId) // Memfilter berdasarkan user yang sedang login
          .order(
            'date',
            ascending: false,
          ); // Mengurutkan berdasarkan tanggal terbaru

      return data;
    } catch (e) {
      // Menangani error jika terjadi masalah saat mengambil data
      print('Error fetching activities: $e');
      return []; // Mengembalikan list kosong jika ada error
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
                    // Ganti dengan path aset yang benar untuk ikon kembali Anda
                    child: Image.asset(
                      'assets/icons/kembali.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Riwayat Aktivitas',
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
            // Body Content
            Expanded(
              // Menggunakan FutureBuilder untuk menampilkan data secara asinkron
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _futureActivities,
                builder: (context, snapshot) {
                  // Menampilkan indikator loading saat data sedang dimuat
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Menampilkan pesan error jika terjadi kesalahan
                  else if (snapshot.hasError) {
                    return Center(
                      child: Text('Terjadi error: ${snapshot.error}'),
                    );
                  }
                  // Menampilkan pesan jika tidak ada data
                  else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada riwayat aktivitas.'),
                    );
                  }
                  // Menampilkan daftar aktivitas jika data berhasil dimuat
                  else {
                    final activities = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ListView.separated(
                        itemCount: activities.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 15),
                        itemBuilder: (context, index) {
                          final activity = activities[index];
                          // Mengakses data dari tabel users_contribution yang digabungkan
                          final contribution = activity['users_contribution'];

                          // Pastikan data 'contribution' tidak null sebelum mengaksesnya
                          if (contribution == null) {
                            return const SizedBox.shrink(); // Atau tampilkan placeholder
                          }

                          return _buildActivityItem(
                            title:
                                contribution['activity_kind'] as String? ??
                                'N/A',
                            description:
                                contribution['activity_desc'] as String? ??
                                'Tidak ada deskripsi',
                            duration:
                                '${contribution['time_length'] as int? ?? 0} jam', // Sesuaikan format durasi
                            date:
                                contribution['date'] as String? ??
                                'Tanggal tidak diketahui',
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembangun untuk setiap item aktivitas
  Widget _buildActivityItem({
    required String title,
    required String description,
    required String duration,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4B2E2B), // Mengganti warna coklat
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                duration,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
