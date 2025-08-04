import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/login_regist.dart';
import 'project_page.dart';
import 'scan_page.dart';
import 'forum_page.dart';
import 'profile_page.dart';
import 'riwayat_presensi_page.dart';

// Import the new pages you want to navigate to
import 'admin_contact.dart';
import 'activity_history.dart';
import 'assistant_stats.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;
  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;

  List<Map<String, dynamic>> _todaySchedules = [];
  bool _isLoading = true; // Set to true by default
  late final RealtimeChannel _scheduleChannel;
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _fetchTodaySchedules();
    _initializeSupabaseRealtime();
  }

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

  Future<void> _fetchTodaySchedules() async {
    // Pastikan _isLoading diatur ke true sebelum memulai fetching
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final supabase = Supabase.instance.client;

      final DateTime now = DateTime.now();
      final String todayDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      print('DEBUG: Memulai pengambilan jadwal untuk tanggal: $todayDate');

      final List<Map<String, dynamic>> data = await supabase
          .from('jadwal_kegiatan')
          .select('*')
          .eq('tanggal', todayDate)
          .order('waktu', ascending: true);

      print('DEBUG: Data yang diterima dari Supabase: $data');
      print('DEBUG: Jumlah jadwal yang ditemukan: ${data.length}');

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
      print('DEBUG ERROR: Gagal memuat jadwal hari ini: $e');
      _showSnackBar('Gagal memuat jadwal hari ini: $e', isError: true);
    } finally {
      // Pastikan _isLoading diatur ke false, terlepas dari keberhasilan atau kegagalan
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _initializeSupabaseRealtime() {
    final supabase = Supabase.instance.client;
    _scheduleChannel = supabase.channel('public:jadwal_kegiatan');
    _scheduleChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'jadwal_kegiatan',
          callback: (payload) {
            print('Realtime event received: ${payload.eventType}');
            _fetchTodaySchedules();
          },
        )
        .subscribe();
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year % 100}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildNoScheduleBox() {
    return Container(
      width: 305,
      height: 136,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
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
      child: const Center(
        child: Text(
          'Tidak ada jadwal hari ini',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scheduleChannel.unsubscribe();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginRegistPage()),
      (route) => false,
    );
  }

  final List<String> _titles = ['Beranda', 'Proyek', 'Scan', 'Forum', 'Profil'];

  List<Widget> get _pages => [
    _buildHomeScreen(), // Ini akan rebuild sesuai perubahan state
    const ProjectPage(),
    const ScanPage(),
    const ForumPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: List.generate(5, (index) {
            final isSelected = _selectedIndex == index;
            final iconNames = [
              ['home.png', 'home_active.png'],
              ['project.png', 'project_active.png'],
              ['scan.png', 'scan_active.png'],
              ['forum.png', 'forum_active.png'],
              ['profile.png', 'profile_active.png'],
            ];
            final labels = ['Beranda', 'Proyek', 'Scan', 'Forum', 'Profil'];
            final iconPath = isSelected
                ? 'assets/icons/${iconNames[index][1]}'
                : 'assets/icons/${iconNames[index][0]}';

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 4,
                      color: isSelected
                          ? const Color(0xFF5E4036)
                          : Colors.transparent,
                    ),
                    const SizedBox(height: 8),
                    Image.asset(iconPath, width: 24, height: 24),
                    const SizedBox(height: 4),
                    Text(
                      labels[index],
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? const Color(0xFF5E4036)
                            : Colors.grey,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHomeScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: SizedBox(
              height: 136,
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
                        return _ScheduleCard(
                          schedule: _todaySchedules[index],
                          index: index,
                          pageController: _pageController,
                          formatDate: _formatDate,
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.8,
                    children: [
                      _buildGridItem(
                        iconPath: 'assets/icons/contact.png',
                        label: 'Kontak Admin',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminContactPage(),
                          ),
                        ),
                      ),
                      _buildGridItem(
                        iconPath: 'assets/icons/clock.png',
                        label: 'Riwayat Presensi',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RiwayatPresensiPage(),
                          ),
                        ),
                      ),
                      _buildGridItem(
                        iconPath: 'assets/icons/bikeman.png',
                        label: 'Riwayat Aktivitas',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ActivityHistoryPage(),
                          ),
                        ),
                      ),
                      _buildGridItem(
                        iconPath: 'assets/icons/chart.png',
                        label: 'Statistik Asisten',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AssistantStatsPage(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem({
    required String iconPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              iconPath,
              width: 30,
              height: 30,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatefulWidget {
  final Map<String, dynamic> schedule;
  final int index;
  final PageController pageController;
  final String Function(String?) formatDate;

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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AnimatedBuilder(
      animation: widget.pageController,
      builder: (context, child) {
        double scale = 1.0;
        double opacity = 1.0;
        double offset = 0.0;

        if (widget.pageController.hasClients &&
            widget.pageController.position.haveDimensions &&
            widget.pageController.page != null) {
          offset = widget.pageController.page! - widget.index;
        } else {
          offset = 0.0 - widget.index;
        }

        final double normalizedOffset = offset.abs().clamp(0.0, 1.0);

        scale = 1.0 - (normalizedOffset * 0.15);
        scale = scale.clamp(0.85, 1.0);

        opacity = 1.0 - (normalizedOffset * 0.4);
        opacity = opacity.clamp(0.6, 1.0);

        double translateX = 0.0;
        if (offset < 0) {
          translateX = -30.0 * normalizedOffset;
        } else if (offset > 0) {
          translateX = 30.0 * normalizedOffset;
        }

        return Center(
          child: Transform.translate(
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
