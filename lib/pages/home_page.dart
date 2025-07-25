import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/login_regist.dart';
import 'project_page.dart';
import 'scan_page.dart';
import 'forum_page.dart';
import 'profile_page.dart';

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

  final List<String> _titles = [
    'Beranda',
    'Proyek',
    'Scan',
    'Forum',
    'Profil',
  ];

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
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                    Image.asset(
                      iconPath,
                      width: 24,
                      height: 24,
                    ),
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
    final userEmail =
        Supabase.instance.client.auth.currentUser?.email ?? 'Pengguna';
    return Center(
      child: Text(
        'Selamat datang, $userEmail!',
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
