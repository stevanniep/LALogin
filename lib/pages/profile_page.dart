import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'faceid_page.dart';
import '../screens/login_regist.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isBiometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              // card profile
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4B2E2B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    const CircleAvatar(
                      radius: 45,
                      backgroundImage: AssetImage('assets/images/photoprofile.png'),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'NAMA SAYA SIAPA YA',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text('Asisten', style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 4),
                        Text('saya@gmail.com', style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 4),
                        Text('101012340000', style: TextStyle(color: Colors.white70)),
                      ],
                    )
                  ],
                ),
              ),

            // Login Biometrik
            _buildCard(
            icon: 'biometrik.png',
            label: 'Login Biometrik',
            trailing: Switch(
                value: isBiometricEnabled,
                activeColor: const Color(0xFF4B2E2B),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.shade300,
                onChanged: (val) {
                setState(() {
                    isBiometricEnabled = val;
                });
                if (val) {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FaceIDPage()),
                    );
                }
                },
            ),
            ),

            // Kehadiran
            _buildCard(
                icon: 'kehadiran.png',
                label: 'Kehadiran',
                trailing: const Text("100%"),
            ),

            // Aktivitas
            _buildCard(
                icon: 'aktivitas.png',
                label: 'Aktivitas',
                child: SizedBox(height: 150, child: _buildActivityChart()),
            ),

            // Edit Profil
            _buildCard(
            icon: 'edit_profil.png',
            label: 'Edit Profil',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
            ),
            ),

            // Logout
            _buildCard(
            icon: 'logout.png',
            label: 'Logout',
            onTap: () {
                Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginRegistPage()),
                (route) => false,
                );
            },
            ),

              const SizedBox(height: 16),
              const Text(
                "Terakhir diakses pada 29 Februari 2025",
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String icon,
    required String label,
    Widget? trailing,
    Widget? child,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/icons/$icon',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    if (trailing != null) trailing,
                  ],
                ),
                if (child != null) ...[
                  const SizedBox(height: 12),
                  child,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final values = [5, 9, 13, 17, 20, 24];
    final colors = [
      Color(0xFFCEB9AF),
      Color(0xFFC4A793),
      Color(0xFFB8937D),
      Color(0xFFA87664),
      Color(0xFF8F5744),
      Color(0xFF5E4036),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(days.length, (i) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 20,
              height: values[i] * 5.0,
              decoration: BoxDecoration(
                color: colors[i],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              days[i],
              style: const TextStyle(fontSize: 10),
            )
          ],
        );
      }),
    );
  }
}
