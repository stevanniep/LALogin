import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class AdminProjectPage extends StatefulWidget {
  const AdminProjectPage({super.key});

  @override
  State<AdminProjectPage> createState() => _AdminProjectPageState();
}

class _AdminProjectPageState extends State<AdminProjectPage> {
  late Future<List<Map<String, dynamic>>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _projectsFuture = _fetchProjects();
  }

  Future<List<Map<String, dynamic>>> _fetchProjects() async {
    try {
      final response = await Supabase.instance.client
          .from('projects')
          .select(
            'id, title, project_stages(stage_name, is_completed, completed_at, order_index)',
          )
          .order('created_at', ascending: false);

      if (response == null) {
        return [];
      }

      // Mengambil data dan mengurutkan tahap-tahap proyek
      final List<Map<String, dynamic>> projects =
          List<Map<String, dynamic>>.from(response);

      for (var project in projects) {
        if (project['project_stages'] != null) {
          final List<dynamic> stages = project['project_stages'];
          // Mengurutkan stages berdasarkan order_index
          stages.sort(
            (a, b) =>
                (a['order_index'] as int).compareTo(b['order_index'] as int),
          );
        }
      }

      return projects;
    } on PostgrestException catch (e) {
      print('Supabase error fetching projects: ${e.message}');
      return [];
    } catch (e) {
      print('Error fetching projects: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background halaman diubah menjadi putih
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          child: const SafeArea(
            child: Text(
              'Proyek',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF4B2E2B),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4B2E2B)),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada proyek ditemukan.'));
          } else {
            final projects = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: CustomProjectTile(projectData: project),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class CustomProjectTile extends StatefulWidget {
  final Map<String, dynamic> projectData;

  const CustomProjectTile({super.key, required this.projectData});

  @override
  State<CustomProjectTile> createState() => _CustomProjectTileState();
}

class _CustomProjectTileState extends State<CustomProjectTile> {
  bool _isExpanded = false;

  // Helper function to format date
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '-';
    }
    try {
      // Assuming dateString is in ISO 8601 format (YYYY-MM-DDTHH:MM:SS.SSSZ or YYYY-MM-DD)
      final DateTime dateTime = DateTime.parse(dateString);
      // Format to DD/MM/YY
      return DateFormat('dd/MM/yy').format(dateTime);
    } catch (e) {
      print('Error formatting date "$dateString": $e');
      return '-';
    }
  }

  // Function to calculate project progress
  double _calculateProgress(List<dynamic>? stages) {
    if (stages == null || stages.isEmpty) {
      return 0.0;
    }
    int completedStages = 0;
    for (var stage in stages) {
      if (stage['is_completed'] == true) {
        completedStages++;
      }
    }
    return (completedStages / stages.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        widget.projectData['title'] ?? 'Judul Proyek Tidak Ada';
    final List<dynamic>? stages = widget.projectData['project_stages'];
    final double progress = _calculateProgress(stages);

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            ListTile(
              title: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF4B2E2B),
                ),
              ),
              trailing: GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: AnimatedRotation(
                  turns: _isExpanded ? 0.25 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Image.asset(
                    'assets/adm/panah.png', // Pastikan path benar
                    width: 20,
                    height: 20,
                    color: const Color(0xFF4B2E2B),
                  ),
                ),
              ),
            ),
            if (_isExpanded && stages != null && stages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display each stage
                    for (
                      int i = 0;
                      i < stages.length;
                      i++
                    ) // Use index for "Tahap X"
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Align top for multiline text
                          children: [
                            Expanded(
                              flex: 3, // Tetap 3 untuk nama tahap
                              child: Column(
                                // Use Column to stack "Tahap X" and stage_name
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Tahap ${i + 1}", // Display "Tahap X"
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    stages[i]['stage_name'] ?? 'Nama Tahap',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 11,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Kolom status
                            SizedBox(
                              // Menggunakan SizedBox dengan lebar tetap untuk status
                              width:
                                  90, // Sesuaikan lebar ini sesuai kebutuhan Anda
                              child: Center(
                                child: Text(
                                  stages[i]['is_completed'] == true
                                      ? "Selesai"
                                      : "Belum Selesai",
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            // Kolom tanggal
                            SizedBox(
                              // Menggunakan SizedBox dengan lebar tetap untuk tanggal
                              width:
                                  97, // Sesuaikan lebar ini sesuai kebutuhan Anda (lebar 'xx/xx/xx')
                              child: Text(
                                // Jika belum selesai, tampilkan 'xx/xx/xx' sebagai placeholder tanggal
                                stages[i]['is_completed'] == true
                                    ? _formatDate(stages[i]['completed_at'])
                                    : '-',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        "Progres: ${progress.toStringAsFixed(0)}%", // Tampilkan progres dengan 0 desimal
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
