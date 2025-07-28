import 'package:flutter/material.dart';
import 'labproject_page.dart';
import 'dailyactivity_page.dart';

class ProjectPage extends StatelessWidget {
  const ProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar di sini untuk judul 'Proyek'
      appBar: AppBar(
        title: const Text(
          'Proyek',
          style: TextStyle(
            color: Color(0xFF5E4036), // Warna teks sesuai desain
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white, // Latar belakang AppBar putih
        elevation: 0, // Hilangkan shadow di bawah AppBar
        centerTitle: false, // Judul tidak di tengah
      ),
      body: SingleChildScrollView(
        // SingleChildScrollView untuk memastikan konten bisa di-scroll jika melebihi layar
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              // Item "Aktivitas Harian"
              _buildProjectItem(
                context,
                label: 'Aktivitas Harian',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DailyActivityPage()),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Menuju Halaman Aktivitas Harian'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15), // Jarak antar item
              // Item "Project Lab 1"
              _buildProjectItem(
                context,
                label: 'Project Lab 1',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LabProjectPage()),
                  );
                },
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pembangun untuk setiap item proyek
  Widget _buildProjectItem(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10), // Sudut membulat
          boxShadow: [
            BoxShadow(
              color: Colors.black, // Shadow tipis
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceBetween, // Untuk menempatkan teks dan ikon di ujung
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800], // Warna teks
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              Icons.chevron_right, // Ikon panah ke kanan
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}
