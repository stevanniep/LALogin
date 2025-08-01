import 'package:flutter/material.dart';
import '../admin/admin_beranda.dart';
import '../admin/admin_project.dart';
import '../admin/admin_activity.dart';
import '../admin/admin_forum.dart';
import '../admin/admin_profile.dart';

class AdminHomePage extends StatefulWidget {
  final int initialIndex;
  const AdminHomePage({super.key, this.initialIndex = 0});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  late final List<Widget> _pages = const [
    AdminBeranda(),
    AdminProjectPage(),
    AdminActivityPage(), // Ganti ScanPage dengan ActivityPage
    AdminForumPage(),
    AdminProfilePage(),
  ];

  final List<String> _labels = [
    'Beranda',
    'Proyek',
    'Aktifitas',
    'Forum',
    'Profil',
  ];

  final List<List<String>> _iconPaths = [
    ['home.png', 'home_active.png'],
    ['project.png', 'project_active.png'],
    ['activity.png', 'activity_aktif.png'], // <- diubah
    ['forum.png', 'forum_active.png'],
    ['profile.png', 'profile_active.png'],
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
            final iconPath = isSelected
                ? 'assets/icons/${_iconPaths[index][1]}'
                : 'assets/icons/${_iconPaths[index][0]}';

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 4,
                      color: isSelected
                          ? const Color(0xFF4B2E2B)
                          : Colors.transparent,
                    ),
                    const SizedBox(height: 8),
                    Image.asset(iconPath, width: 24, height: 24),
                    const SizedBox(height: 4),
                    Text(
                      _labels[index],
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? const Color(0xFF4B2E2B)
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
}
