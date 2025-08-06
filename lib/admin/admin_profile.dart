import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_profile_page.dart';
import 'faceid_page.dart';
import '../screens/login_regist.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final supabase = Supabase.instance.client;
  bool isBiometricEnabled = false;
  Map<String, dynamic>? profileData;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('profiles')
        .select('full_name, nim, role, email, username, created_at')
        .eq('user_id', user.id)
        .single();

    setState(() {
      profileData = Map<String, dynamic>.from(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (profileData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4B2E2B)),
          ),
        ),
      );
    }

    final fullName = profileData!['full_name'];
    final nim = profileData!['nim'] ?? '-';
    final roleRaw = profileData!['role'];
    final role = (roleRaw == 'Pengguna') ? 'Asisten' : 'Admin';
    final email = profileData!['email'];
    final usernameRaw = profileData!['username'];
    final username = (usernameRaw == null || usernameRaw.isEmpty)
        ? email.split('@')[0]
        : usernameRaw;

    final createdAt = profileData!['created_at'];
    final createdText =
        "Dibuat pada ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.parse(createdAt))}";

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4B2E2B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 45,
                      backgroundImage: AssetImage(
                        'assets/images/photoprofile.png',
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            role,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: const TextStyle(color: Colors.white70),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nim,
                            style: const TextStyle(color: Colors.white70),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              _buildCard(
                icon: 'biometrik.png',
                label: 'Login Biometrik',
                trailing: Switch(
                  value: isBiometricEnabled,
                  activeColor: const Color(0xFF4B2E2B),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.shade300,
                  onChanged: (val) {
                    setState(() => isBiometricEnabled = val);
                    if (val) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FaceIDPage()),
                      );
                    }
                  },
                ),
              ),

              _buildCard(
                icon: 'kehadiran.png',
                label: 'Kehadiran',
                trailing: const Text("100%"),
              ),

              _buildCard(
                icon: 'aktivitas.png',
                label: 'Aktivitas',
                child: SizedBox(height: 150, child: _buildActivityChart()),
              ),

              _buildCard(
                icon: 'edit_profil.png',
                label: 'Edit Profil',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                ),
              ),

              _buildCard(
                icon: 'logout.png',
                label: 'Logout',
                onTap: () {
                  supabase.auth.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginRegistPage()),
                    (route) => false,
                  );
                },
              ),

              const SizedBox(height: 16),
              Text(
                createdText,
                style: const TextStyle(fontSize: 12, color: Colors.black),
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
        color: Colors.white,
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
                    Image.asset('assets/icons/$icon', width: 24, height: 24),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (trailing != null) trailing,
                  ],
                ),
                if (child != null) ...[const SizedBox(height: 12), child],
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
      const Color(0xFFCEB9AF),
      const Color(0xFFC4A793),
      const Color(0xFFB8937D),
      const Color(0xFFA87664),
      const Color(0xFF8F5744),
      const Color(0xFF5E4036),
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
            Text(days[i], style: const TextStyle(fontSize: 10)),
          ],
        );
      }),
    );
  }
}
