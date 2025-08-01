import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/login_regist.dart';
import 'project_page.dart';
import 'scan_page.dart';
import 'forum_page.dart';
import 'profile_page.dart';

// Import the new pages you want to navigate to
import 'admin_contact.dart';
import 'attendance_history.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
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

  late final List<Widget> _pages = [
    _buildHomeScreen(),
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
          // Bagian atas (Study Group card)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF5E4036),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              height: 120,
              child: Center(
                child: Text(
                  'Tidak ada jadwal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Grid icon dan teks
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
                    // Tambahkan childAspectRatio di sini
                    childAspectRatio:
                        0.8, // Sesuaikan nilai ini sesuai kebutuhan Anda
                    children: [
                      // Using Image.asset for custom icons
                      _buildGridItem(
                        iconPath:
                            'assets/icons/contact.png', // Changed to image asset
                        label: 'Kontak Admin',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminContactPage(),
                          ),
                        ),
                      ),
                      _buildGridItem(
                        iconPath:
                            'assets/icons/clock.png', // Changed to image asset
                        label: 'Riwayat Presensi',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AttendanceHistoryPage(),
                          ),
                        ),
                      ),
                      _buildGridItem(
                        iconPath:
                            'assets/icons/bikeman.png', // Changed to image asset
                        label: 'Riwayat Aktivitas',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ActivityHistoryPage(),
                          ),
                        ),
                      ),
                      _buildGridItem(
                        iconPath:
                            'assets/icons/chart.png', // Changed to image asset
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

  // Modified _buildGridItem to accept an iconPath instead of IconData
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
            // Use Image.asset here
            child: Image.asset(
              iconPath,
              width: 30,
              height: 30,
              color: Colors.grey[700],
            ), // Apply color filter
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
