import 'package:flutter/material.dart';

class AssistantStatsPage extends StatelessWidget {
  const AssistantStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
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
                      Navigator.of(context).pop();
                    },
                    // Ganti dengan path aset yang benar untuk ikon kembali Anda
                    child: Image.asset(
                      'assets/icons/kembali.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Statistik Asisten',
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
            // Body content
            Expanded(
              child: SingleChildScrollView(
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
            ),
          ],
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
    final List<String> dayLabels = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    final List<Color> barColors = [
      const Color(0xFFD7B899),
      const Color(0xFFC69C6D),
      const Color(0xFFA9746E),
      const Color(0xFF855E42),
      const Color(0xFF5C4033),
      const Color(0xFF3B2F2F),
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
            child: Stack(
              children: [
                // Y-axis Labels
                Positioned(
                  top: 0,
                  left: 0,
                  child: Text(
                    maxHeight.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: const Text(
                    '0',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Graph bars
                Positioned(
                  bottom: 0,
                  left:
                      30, // Geser grafik agar tidak bertumpang tindih dengan label Y-axis
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(data.length, (index) {
                      final double barHeight = data[index] / maxHeight * 120;
                      return Expanded(
                        // **PERUBAHAN DISINI:** Menggunakan Expanded
                        child: Center(
                          child: Container(
                            width: 30,
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: barColors[index],
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          // Day labels
          const SizedBox(height: 5), // Jarak antara grafik dan label hari
          Padding(
            padding: const EdgeInsets.only(
              left: 30,
            ), // Geser label hari agar sejajar dengan grafik
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(dayLabels.length, (index) {
                return Expanded(
                  // **PERUBAHAN DISINI:** Menggunakan Expanded
                  child: Text(
                    dayLabels[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          // Label rentang minggu
          Text(
            weekLabel,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
