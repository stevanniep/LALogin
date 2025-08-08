import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AssistantStatsPage extends StatefulWidget {
  const AssistantStatsPage({super.key});

  @override
  State<AssistantStatsPage> createState() => _AssistantStatsPageState();
}

class _AssistantStatsPageState extends State<AssistantStatsPage> {
  // Inisialisasi Supabase client
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isLoading = true;

  // Variabel untuk menyimpan data mingguan yang sudah diurutkan
  List<MapEntry<String, List<BarChartGroupData>>> _allWeeklyData = [];

  // Label untuk hari dalam seminggu (Senin - Sabtu)
  final List<String> _dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

  @override
  void initState() {
    super.initState();
    _fetchAllWeeklyData();
  }

  Future<void> _fetchAllWeeklyData() async {
    setState(() {
      _isLoading = true;
    });

    final String? userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await supabase
          .from('users_contribution')
          .select('date, time_length')
          .eq('user_id', userId)
          .order('date', ascending: true);

      // Group by week
      final Map<String, Map<int, double>> weeklyData = {};

      for (var record in response) {
        final DateTime recordDate = DateTime.parse(record['date']);
        final int weekday = recordDate.weekday;

        if (weekday > 6) continue; // Skip Sunday

        final weekStart = recordDate.subtract(Duration(days: weekday - 1));
        final weekKey = DateFormat('yyyy-MM-dd').format(weekStart);

        weeklyData.putIfAbsent(
          weekKey,
          () => {for (var i = 1; i <= 6; i++) i: 0.0},
        );
        weeklyData[weekKey]![weekday] =
            (weeklyData[weekKey]![weekday] ?? 0) +
            (record['time_length'] as num).toDouble();
      }

      // Ubah ke list dan urutkan berdasarkan tanggal minggu descending (terbaru di atas)
      final sortedEntries = weeklyData.entries.toList()
        ..sort(
          (a, b) => DateTime.parse(b.key).compareTo(DateTime.parse(a.key)),
        );

      List<MapEntry<String, List<BarChartGroupData>>> chartDataList = [];

      for (var entry in sortedEntries) {
        List<BarChartGroupData> groups = [];
        for (int day = 1; day <= 6; day++) {
          final time = entry.value[day]!;
          groups.add(
            BarChartGroupData(
              x: day,
              barRods: [
                BarChartRodData(
                  toY: time,
                  color: _getBarColor(day),
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                  ),
                ),
              ],
            ),
          );
        }
        chartDataList.add(MapEntry(entry.key, groups));
      }

      setState(() {
        _allWeeklyData = chartDataList;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() => _isLoading = false);
    }
  }

  Color _getBarColor(int day) {
    final List<Color> barColors = [
      const Color(0xFFD7B899),
      const Color(0xFFC69C6D),
      const Color(0xFFA9746E),
      const Color(0xFF855E42),
      const Color(0xFF5C4033),
      const Color(0xFF3B2F2F),
    ];
    return barColors[day - 1]; // Menggunakan indeks 0-5
  }

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
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF4B2E2B),
                      size: 24,
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
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4B2E2B),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: _allWeeklyData.map((entry) {
                            final DateTime weekStart = DateTime.parse(
                              entry.key,
                            );
                            final DateTime weekEnd = weekStart.add(
                              const Duration(days: 5),
                            );

                            final double maxY = entry.value
                                .map((group) => group.barRods[0].toY)
                                .fold(0.0, (prev, el) => el > prev ? el : prev);
                            final double intervalY = maxY <= 1
                                ? 1
                                : 2; // Menyesuaikan interval

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 200,
                                    child: BarChart(
                                      BarChartData(
                                        barGroups: entry.value,
                                        alignment:
                                            BarChartAlignment.spaceAround,
                                        groupsSpace: 10,
                                        maxY: (maxY.ceil() + 1).toDouble(),
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: intervalY,
                                              reservedSize: 30,
                                              getTitlesWidget: (value, meta) =>
                                                  Text(
                                                    value.toInt().toString(),
                                                    style: const TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 10,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 22,
                                              getTitlesWidget: (value, meta) {
                                                final int idx = value.toInt();
                                                if (idx >= 1 && idx <= 6) {
                                                  return Text(
                                                    _dayLabels[idx - 1],
                                                    style: const TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 10,
                                                      color: Colors.black,
                                                    ),
                                                  );
                                                }
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                          ),
                                          topTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          rightTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(
                                          show: true,
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey.withOpacity(
                                                0.5,
                                              ),
                                            ),
                                            left: const BorderSide(
                                              color: Colors.transparent,
                                            ),
                                            right: const BorderSide(
                                              color: Colors.transparent,
                                            ),
                                            top: const BorderSide(
                                              color: Colors.transparent,
                                            ),
                                          ),
                                        ),
                                        gridData: FlGridData(
                                          show: true,
                                          drawHorizontalLine: true,
                                          drawVerticalLine: false,
                                          horizontalInterval:
                                              intervalY, // Menggunakan interval yang disesuaikan
                                          getDrawingHorizontalLine: (value) =>
                                              FlLine(
                                                color: Colors.grey.withOpacity(
                                                  0.3,
                                                ),
                                                strokeWidth: 1,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${DateFormat('dd MMM').format(weekStart)} - ${DateFormat('dd MMM yyyy').format(weekEnd)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembangun untuk grafik batang mingguan yang tidak terpakai, bisa dihapus.
  // @Deprecated('This widget is no longer used. The chart is built directly in the main build method.')
  Widget _buildWeeklyChart() {
    return const SizedBox.shrink();
  }
}
