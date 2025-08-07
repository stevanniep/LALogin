import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Activity History Page
class ActivityHistoryPage extends StatefulWidget {
  const ActivityHistoryPage({super.key});

  @override
  State<ActivityHistoryPage> createState() => _ActivityHistoryPageState();
}

class _ActivityHistoryPageState extends State<ActivityHistoryPage> {
  // Initialize Supabase client
  final SupabaseClient _supabase = Supabase.instance.client;

  // Future to store the activity data retrieval result
  late Future<List<Map<String, dynamic>>> _futureActivities;

  @override
  void initState() {
    super.initState();
    // Load activity data when the widget is initialized
    _futureActivities = _fetchActivities();
  }

  // Asynchronous function to fetch activity data from Supabase
  Future<List<Map<String, dynamic>>> _fetchActivities() async {
    try {
      // Get the ID of the logged-in user
      final userId = _supabase.auth.currentUser!.id;

      // Query the 'users_contribution' table
      // Filter by the logged-in user's ID
      final data = await _supabase
          .from('users_contribution')
          .select() // Select all columns
          .eq('user_id', userId) // Filter based on the logged-in user
          .order('date', ascending: false); // Sort by the latest date

      return data;
    } catch (e) {
      // Handle errors if there's a problem retrieving data
      print('Error fetching activities: $e');
      return []; // Return an empty list if an error occurs
    }
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
            // Body Content
            Expanded(
              // Use FutureBuilder to display data asynchronously
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _futureActivities,
                builder: (context, snapshot) {
                  // Display a loading indicator when data is being loaded
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Display an error message if an error occurs
                  else if (snapshot.hasError) {
                    return Center(
                      child: Text('Terjadi error: ${snapshot.error}'),
                    );
                  }
                  // Display a message if there is no data
                  else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada riwayat aktivitas.'),
                    );
                  }
                  // Display the list of activities if data is successfully loaded
                  else {
                    final activities = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ListView.separated(
                        itemCount: activities.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 15),
                        itemBuilder: (context, index) {
                          final activity = activities[index];

                          // The data is now directly from 'users_contribution'
                          return _buildActivityItem(
                            title:
                                activity['activity_kind'] as String? ?? 'N/A',
                            description:
                                activity['activity_description'] as String? ??
                                'Tidak ada deskripsi',
                            duration:
                                '${(activity['time_length'] as num? ?? 0).toInt()} jam',
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

  // Builder widget for each activity item
  Widget _buildActivityItem({
    required String title,
    required String description,
    required String duration,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4B2E2B), // Replacing the brown color
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
