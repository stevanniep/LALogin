import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityHistoryPage extends StatefulWidget {
  const ActivityHistoryPage({super.key});

  @override
  State<ActivityHistoryPage> createState() => _ActivityHistoryPageState();
}

class _ActivityHistoryPageState extends State<ActivityHistoryPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _futureActivities;

  @override
  void initState() {
    super.initState();
    _futureActivities = _fetchActivities();
  }

  Future<List<Map<String, dynamic>>> _fetchActivities() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final data = await _supabase
          .from('users_contribution')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);
      return data;
    } catch (e) {
      print('Error fetching activities: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
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
                    child: Image.asset(
                      'assets/icons/kembali.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Riwayat Aktivitas',
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
            // Konten utama
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _futureActivities,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Terjadi error: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada riwayat aktivitas.'),
                    );
                  } else {
                    final activities = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ListView.separated(
                        itemCount: activities.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 15),
                        itemBuilder: (context, index) {
                          final activity = activities[index];

                          return _buildActivityItem(
                            title:
                                activity['activity_kind'] as String? ?? 'N/A',
                            description:
                                activity['activity_description'] as String? ??
                                'Tidak ada deskripsi',
                            duration: _formatTimeLength(
                              (activity['time_length'] as num? ?? 0).toDouble(),
                            ),

                            date:
                                activity['date'] as String? ??
                                'Tanggal tidak diketahui',
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeLength(double timeLength) {
    if (timeLength < 1) {
      return '${(timeLength * 60).round()} menit';
    } else if (timeLength == 1.0) {
      return '1 jam';
    } else {
      int hours = timeLength.floor();
      int minutes = ((timeLength - hours) * 60).round();
      if (minutes == 0) {
        return '$hours jam';
      } else {
        return '$hours jam $minutes menit';
      }
    }
  }

  Widget _buildActivityItem({
    required String title,
    required String description,
    required String duration,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4B2E2B),
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
