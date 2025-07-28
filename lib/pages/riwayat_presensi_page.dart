import 'package:flutter/material.dart';
import 'home_page.dart';

class RiwayatPresensiPage extends StatelessWidget {
  const RiwayatPresensiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header putih + shadow
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(initialIndex: 2),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/icons/kembali.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Riwayat Presensi',
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

            // ListView content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(40),
                children: const [
                  CustomExpansionTile(title: 'Presensi Harian'),
                  SizedBox(height: 16),
                  CustomExpansionTile(title: 'Event Dadakan'),
                  SizedBox(height: 16),
                  CustomExpansionTile(title: 'Event Penting'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }
}

class CustomExpansionTile extends StatefulWidget {
  final String title;

  const CustomExpansionTile({super.key, required this.title});

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 320,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              initiallyExpanded: _isExpanded,
              onExpansionChanged: (value) {
                setState(() {
                  _isExpanded = value;
                });
              },
              title: SizedBox(
                height: 40,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Color(0xFF4B2E2B),
                    ),
                  ),
                ),
              ),
              trailing: AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0.0, // 0.5 = 180 derajat
                duration: const Duration(milliseconds: 200),
                child: Image.asset(
                  'assets/icons/detail.png',
                  width: 20,
                  height: 20,
                  color: const Color(0xFF4B2E2B),
                ),
              ),

              children: const [
                Text(
                  'Belum ada data.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildBottomNavBar(BuildContext context) {
  const selectedIndex = 2; // Scan tab

  final iconNames = [
    ['home.png', 'home_active.png'],
    ['project.png', 'project_active.png'],
    ['scan.png', 'scan_active.png'],
    ['forum.png', 'forum_active.png'],
    ['profile.png', 'profile_active.png'],
  ];

  final labels = ['Beranda', 'Proyek', 'Scan', 'Forum', 'Profil'];

  return Container(
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
        final isSelected = selectedIndex == index;
        final iconPath = isSelected
            ? 'assets/icons/${iconNames[index][1]}'
            : 'assets/icons/${iconNames[index][0]}';

        return Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomePage(initialIndex: index),
                ),
              );
            },
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
                    color: isSelected ? const Color(0xFF5E4036) : Colors.grey,
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
  );
}
