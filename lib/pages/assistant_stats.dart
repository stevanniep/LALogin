import 'package:flutter/material.dart';

class AssistantStatsPage extends StatelessWidget {
  const AssistantStatsPage({super.key});

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
          'Statistik Asisten',
          style: TextStyle(
            color: Color(0xFF5E4036),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Grafik Mingguan Pertama
              _buildWeeklyChart(
                weekLabel: '7/07/25-12/07/25',
                data: const [2.0, 3.0, 1.0, 2.0, 4.0, 1.0], // Data jam
                maxHeight: 4, // Max jam pada y-axis
              ),
              const SizedBox(height: 30),
              // Grafik Mingguan Kedua
              _buildWeeklyChart(
                weekLabel: '30/06/25-5/07/25',
                data: const [5.0, 2.0, 7.0, 4.0, 8.0, 9.0],
                maxHeight: 10,
              ),
              const SizedBox(height: 30),
              // Grafik Mingguan Ketiga
              _buildWeeklyChart(
                weekLabel: '23/06/25-28/06/25',
                data: const [1.0, 7.0, 9.0, 3.0, 6.0, 4.0],
                maxHeight: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pembangun untuk setiap grafik batang mingguan
  Widget _buildWeeklyChart({
    required String weekLabel,
    required List<double> data,
    required double maxHeight,
  }) {
    // Label hari dalam seminggu (Senin - Sabtu)
    final List<String> dayLabels = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          SizedBox(
            height: 150, // Tinggi area grafik
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis (Jumlah jam)
                SizedBox(
                  width: 30, // Lebar untuk label Y-axis
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        maxHeight.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      const Text(
                        '0',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // Area grafik batang
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(data.length, (index) {
                      final double barHeight =
                          data[index] / maxHeight * 120; // Hitung tinggi batang
                      return Container(
                        width: 25, // Lebar setiap batang
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC79A73), // Warna batang
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // X-axis (Label hari)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(dayLabels.length, (index) {
              return SizedBox(
                width: 25, // Lebar yang sama dengan batang
                child: Text(
                  dayLabels[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          // Label rentang minggu
          Text(
            weekLabel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5E4036),
            ),
          ),
        ],
      ),
    );
  }
}

