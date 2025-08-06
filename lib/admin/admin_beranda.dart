import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_tambah_jadwal.dart';
import 'admin_tambah_proyek.dart';
import 'admin_data_asisten.dart';
import 'admin_presensi.dart';

class AdminBeranda extends StatefulWidget {
  const AdminBeranda({super.key});

  @override
  State<AdminBeranda> createState() => _AdminBerandaState();
}

class _AdminBerandaState extends State<AdminBeranda> {
  // State untuk menyimpan daftar jadwal hari ini
  List<Map<String, dynamic>> _todaySchedules = [];
  // State untuk melacak apakah data sedang dimuat
  bool _isLoading = true;
  // Supabase Realtime Channel
  late final RealtimeChannel _scheduleChannel;

  // Controller untuk PageView agar bisa mengontrol halaman yang aktif
  final PageController _pageController = PageController(
    viewportFraction:
        0.85, // <-- Mengatur agar sebagian kartu berikutnya terlihat
    // cacheExtent dihapus karena menyebabkan error, diganti dengan AutomaticKeepAliveClientMixin
  );

  @override
  void initState() {
    super.initState();
    _fetchTodaySchedules(); // Ambil jadwal hari ini saat inisialisasi
    _initializeSupabaseRealtime(); // Inisialisasi Realtime
  }

  // Fungsi untuk menampilkan SnackBar
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    final Color backgroundColor = isError
        ? Colors.red
        : const Color(0xFF4B2E2B);
    final Color textColor = Colors.white;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Fungsi untuk mengambil semua jadwal hari ini dari Supabase dan mengurutkannya berdasarkan waktu
  Future<void> _fetchTodaySchedules() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final supabase = Supabase.instance.client;

      final DateTime now = DateTime.now();
      // Format tanggal hari ini menjadi 'YYYY-MM-DD'
      final String todayDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // --- DEBUGGING: Cetak tanggal yang digunakan untuk query ---
      print('DEBUG: Querying for date: $todayDate');

      // Mengambil semua baris jadwal untuk hari ini, diurutkan berdasarkan 'waktu'
      final List<Map<String, dynamic>> data = await supabase
          .from('jadwal_kegiatan')
          .select('*')
          .eq('tanggal', todayDate) // Filter berdasarkan tanggal hari ini
          .order('waktu', ascending: true); // Urutkan berdasarkan waktu ASC

      // --- DEBUGGING: Cetak data yang diterima dari Supabase ---
      print('DEBUG: Data received from Supabase: $data');

      // Mengurutkan ulang jika format waktu tidak standar (misal "HH.MM WIB")
      data.sort((a, b) {
        String timeA = (a['waktu'] as String? ?? '00.00')
            .replaceAll(' WIB', '')
            .replaceAll('.', ':');
        String timeB = (b['waktu'] as String? ?? '00.00')
            .replaceAll(' WIB', '')
            .replaceAll('.', ':');
        return timeA.compareTo(timeB);
      });

      if (mounted) {
        setState(() {
          _todaySchedules = data;
        });
      }
    } catch (e) {
      _showSnackBar('Gagal memuat jadwal hari ini: $e', isError: true);
      // --- DEBUGGING: Cetak error jika ada ---
      print('DEBUG ERROR fetching schedules: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Mengatur dan mendengarkan perubahan Realtime dari Supabase
  void _initializeSupabaseRealtime() {
    final supabase = Supabase.instance.client;

    _scheduleChannel = supabase.channel('public:jadwal_kegiatan');

    _scheduleChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'jadwal_kegiatan',
          callback: (payload) {
            print(
              'Realtime event received in AdminBeranda: ${payload.eventType}',
            );
            _fetchTodaySchedules(); // Ambil ulang semua jadwal hari ini saat ada perubahan
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _scheduleChannel.unsubscribe();
    _pageController.dispose(); // Penting: Buang PageController
    super.dispose();
  }

  // Helper untuk format tanggal
  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year % 100}';
    } catch (e) {
      return dateString;
    }
  }

  // Widget untuk menampilkan pesan "Tidak ada jadwal hari ini" dalam box coklat
  Widget _buildNoScheduleBox() {
    // Kita ingin box ini memiliki ukuran dasar yang sama dengan kartu jadwal
    return Container(
      width: 305,
      height: 136,
      padding: const EdgeInsets.all(16),
      // Memberikan margin horizontal agar terlihat konsisten dengan item PageView
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF4B2E2B), // warna coklat tua
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'Tidak ada jadwal hari ini',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600, // Semibold
            fontSize: 15,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian untuk menampilkan jadwal hari ini dalam PageView atau pesan jika kosong
              SizedBox(
                height: 136, // Tinggi tetap untuk PageView atau box kosong
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.brown),
                      )
                    : _todaySchedules.isEmpty
                    ? Center(child: _buildNoScheduleBox())
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: _todaySchedules.length,
                        itemBuilder: (context, index) {
                          // Menggunakan widget _ScheduleCard baru yang Stateful
                          return _ScheduleCard(
                            schedule: _todaySchedules[index],
                            index: index,
                            pageController: _pageController,
                            formatDate: _formatDate,
                          );
                        },
                      ),
              ),

              const SizedBox(
                height: 100,
              ), // Jarak antara carousel dan menu ikon
              // Menu ikon (tidak berubah)
              Center(
                child: Container(
                  width: 340,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _MenuIcon(
                          iconPath: 'assets/adm/tambah.png',
                          label: 'Tambah\nJadwal',
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TambahJadwalPage(),
                              ),
                            );
                            _fetchTodaySchedules(); // Refresh jadwal setelah kembali
                          },
                        ),
                        _MenuIcon(
                          iconPath: 'assets/adm/qr.png',
                          label: 'Membuat\nPresensi',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminPresensi(),
                              ),
                            );
                          },
                        ),
                        _MenuIcon(
                          iconPath: 'assets/adm/data.png',
                          label: 'Data\nAsisten',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AdminDataAsistenPage(),
                              ),
                            );
                          },
                        ),
                        _MenuIcon(
                          iconPath: 'assets/adm/proyek.png',
                          label: 'Tambah\nProyek',
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TambahProyekPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Komponen ikon + label (tidak berubah)
class _MenuIcon extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback? onTap;

  const _MenuIcon({required this.iconPath, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Image.asset(iconPath, width: 24, height: 24)),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 11,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Stateful baru untuk setiap kartu jadwal (menggantikan _buildScheduleCard method)
class _ScheduleCard extends StatefulWidget {
  final Map<String, dynamic> schedule;
  final int index;
  final PageController pageController;
  final String Function(String?) formatDate; // Meneruskan fungsi format tanggal

  const _ScheduleCard({
    required this.schedule,
    required this.index,
    required this.pageController,
    required this.formatDate,
  });

  @override
  State<_ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<_ScheduleCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Penting: Menjaga widget tetap hidup

  @override
  Widget build(BuildContext context) {
    super.build(
      context,
    ); // Panggil super.build untuk AutomaticKeepAliveClientMixin

    return AnimatedBuilder(
      animation: widget.pageController,
      builder: (context, child) {
        double scale = 1.0;
        double opacity = 1.0;
        double offset = 0.0;

        // Cek apakah PageController sudah memiliki dimensi untuk menghindari error
        if (widget.pageController.hasClients &&
            widget.pageController.position.haveDimensions &&
            widget.pageController.page != null) {
          offset = widget.pageController.page! - widget.index;
        } else {
          // Saat pertama kali, belum ada scroll jadi kita anggap page awal (index 0)
          offset = 0.0 - widget.index;
        }

        // --- Logika perbaikan untuk efek siluet ---
        // offset.abs() akan bernilai 0 untuk kartu aktif, 1 untuk kartu di sebelah, 2 untuk dua kartu di sebelah, dst.
        // Kita ingin kartu yang lebih jauh memiliki skala dan opasitas yang lebih kecil.

        // Batasi offset absolute agar tidak terlalu besar, cukup sampai 1.0 atau 2.0 untuk efek yang terlihat
        final double normalizedOffset = offset.abs().clamp(
          0.0,
          1.0,
        ); // Clamp ke 1.0 agar fokus pada kartu terdekat

        // Sesuaikan skala: dari 1.0 (aktif) turun ke 0.85 (siluet)
        scale =
            1.0 -
            (normalizedOffset *
                0.15); // Misalnya, menyusut 15% dari ukuran asli
        scale = scale.clamp(
          0.85,
          1.0,
        ); // Pastikan skala tidak lebih kecil dari 85%

        // Sesuaikan opasitas: dari 1.0 (aktif) turun ke 0.6 (siluet)
        opacity =
            1.0 - (normalizedOffset * 0.4); // Memudar 40% dari opasitas penuh
        opacity = opacity.clamp(
          0.6,
          1.0,
        ); // Pastikan opasitas tidak kurang dari 60%

        // --- Efek posisi horizontal agar kartu siluet terlihat sedikit di samping ---
        // Kita geser kartu yang tidak aktif sedikit ke samping
        double translateX = 0.0;
        if (offset < 0) {
          // Kartu ada di sebelah kanan (berikutnya)
          translateX = -30.0 * normalizedOffset; // Geser ke kiri sedikit
        } else if (offset > 0) {
          // Kartu ada di sebelah kiri (sebelumnya)
          translateX = 30.0 * normalizedOffset; // Geser ke kanan sedikit
        }

        return Center(
          child: Transform.translate(
            // Menggunakan Transform.translate untuk efek samping
            offset: Offset(translateX, 0.0),
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 330,
                  height: 136,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4B2E2B),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.schedule['nama'] ?? 'Nama Kegiatan',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.formatDate(
                              widget.schedule['tanggal'] as String?,
                            ),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.schedule['tempat'] ?? 'Tempat',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.schedule['waktu'] ?? 'Waktu',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
