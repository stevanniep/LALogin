import 'package:flutter/material.dart';

class ActivityHistoryPage extends StatelessWidget {
  const ActivityHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5E4036)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Riwayat Aktivitas',
          style: TextStyle(
            color: Color(0xFF5E4036),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            // List item aktivitas. Gunakan _buildActivityItem untuk setiap item.
            _buildActivityItem(
              title: 'Eksperimen',
              description: 'mencoba melakukan hal baru',
              duration: '1 jam',
              date: '22/08/25',
            ),
            const SizedBox(height: 15),
            _buildActivityItem(
              title: 'Coding',
              description: 'mencoba melakukan hal baru',
              duration: '2 jam',
              date: '22/08/25',
            ),
            const SizedBox(height: 15),
            _buildActivityItem(
              title: 'Membaca Jurnal',
              description: 'mencoba melakukan hal baru',
              duration: '4 jam',
              date: '21/08/25',
            ),
            const SizedBox(height: 15),
            _buildActivityItem(
              title: 'Diskusi Riset',
              description: 'mencoba melakukan hal baru',
              duration: '30 menit',
              date: '21/08/25',
            ),
            const SizedBox(height: 15),
            _buildActivityItem(
              title: 'Menulis Dokumentasi',
              description: 'mencoba melakukan hal baru',
              duration: '20 menit',
              date: '20/08/25',
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
        color: const Color(0xFF5E4036),
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

