// File: project_page.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'labproject_page.dart';
import 'dailyactivity_page.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  String? _currentUserId;
  late Future<List<Map<String, dynamic>>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _currentUserId = user.id;
      _projectsFuture = _fetchUserProjects();
    } else {
      _projectsFuture = Future.value([]);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUserProjects() async {
    try {
      if (_currentUserId == null) return [];

      final profile = await Supabase.instance.client
          .from('profiles')
          .select('username')
          .eq('user_id', _currentUserId!)
          .maybeSingle();

      final username = profile?['username'];
      if (username == null) return [];

      final contributorProjects = await Supabase.instance.client
          .from('project_contributors')
          .select('project_id')
          .eq('contributor_username', username);

      final contributorProjectIds = contributorProjects
          .map<String>((e) => e['project_id'] as String)
          .toList();

      if (contributorProjectIds.isEmpty) return [];

      final response = await Supabase.instance.client
          .from('projects')
          .select('id, title')
          .filter('id', 'in', '(${contributorProjectIds.join(",")})')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      print('Supabase error fetching projects: ${e.message}');
      return [];
    } catch (e) {
      print('Error fetching projects: $e');
      return [];
    }
  }

  Widget _buildProjectItem(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF4B2E2B),
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF4B2E2B)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          child: const SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
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
          } else {
            final projects = snapshot.data ?? [];
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProjectItem(
                      context,
                      label: 'Aktivitas Harian',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DailyActivityPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    if (projects.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          'Belum ada proyek yang dibuat atau di-assign.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ...projects.map((project) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: _buildProjectItem(
                          context,
                          label: project['title'] ?? 'Judul Proyek Tidak Ada',
                          onTap: () {
                            final projectId = project['id'] as String;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    LabProjectPage(projectId: projectId),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
