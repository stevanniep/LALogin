import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class LabProjectPage extends StatefulWidget {
  final String projectId;

  const LabProjectPage({super.key, required this.projectId});

  @override
  State<LabProjectPage> createState() => _LabProjectPageState();
}

class _LabProjectPageState extends State<LabProjectPage> {
  late Future<Map<String, dynamic>> _projectDetailsFuture;
  late List<Map<String, dynamic>> _stages;

  static const Color _brownColor = Color(0xFF4B2E2B);

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'id_ID';
    _projectDetailsFuture = _fetchAndInitializeStages();
  }

  Future<Map<String, dynamic>> _fetchAndInitializeStages() async {
    final data = await _fetchProjectDetails();
    _stages = List<Map<String, dynamic>>.from(data['stages']);
    return data;
  }

  Future<Map<String, dynamic>> _fetchProjectDetails() async {
    try {
      final projectData = await Supabase.instance.client
          .from('projects')
          .select('title, start_date, end_date')
          .eq('id', widget.projectId)
          .single();

      final stagesData = await Supabase.instance.client
          .from('project_stages')
          .select('id, stage_name, is_completed, order_index')
          .eq('project_id', widget.projectId)
          .order('order_index', ascending: true);

      return {'project': projectData, 'stages': stagesData};
    } on PostgrestException catch (e) {
      debugPrint('Supabase error fetching project details: ${e.message}');
      throw Exception('Gagal mengambil data proyek: ${e.message}');
    } catch (e) {
      debugPrint('Error fetching project details: $e');
      throw Exception('Terjadi kesalahan tidak terduga');
    }
  }

  // Fungsi untuk menampilkan snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : _brownColor,
        duration: const Duration(
          milliseconds: 1500,
        ), // Durasi default seperti di kode asli
      ),
    );
  }

  Future<void> _saveChanges() async {
    try {
      final stagesToUpdate = _stages
          .where((stage) => stage.containsKey('has_changed'))
          .toList();

      if (stagesToUpdate.isEmpty) {
        _showSnackBar('Tidak ada perubahan untuk disimpan.');
        return;
      }

      final List<Future<dynamic>> updateFutures = stagesToUpdate.map((stage) {
        return Supabase.instance.client
            .from('project_stages')
            .update({
              'is_completed': stage['is_completed'],
              'completed_at': stage['is_completed']
                  ? DateTime.now().toIso8601String()
                  : null,
            })
            .eq('id', stage['id']);
      }).toList();

      await Future.wait(updateFutures);

      setState(() {
        _projectDetailsFuture = _fetchAndInitializeStages();
      });

      _showSnackBar('Perubahan berhasil disimpan!');
    } on PostgrestException catch (e) {
      debugPrint('Error saving changes: ${e.message}');
      _showSnackBar('Gagal menyimpan perubahan: ${e.message}', isError: true);
    } catch (e) {
      debugPrint('Error saving changes: $e');
      _showSnackBar('Gagal menyimpan perubahan. Coba lagi.', isError: true);
    }
  }

  Widget _buildStageItem(int index) {
    final stage = _stages[index];
    final stageName = stage['stage_name'] as String;
    final isCompleted = stage['is_completed'] as bool;
    final hasChanged = stage['has_changed'] as bool? ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              stageName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 23,
            height: 23,
            decoration: BoxDecoration(
              color: isCompleted ? _brownColor : Colors.transparent,
              border: Border.all(
                color: hasChanged ? Colors.orange : _brownColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Theme(
              data: ThemeData(
                unselectedWidgetColor: Colors.transparent,
                checkboxTheme: CheckboxThemeData(
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              child: Checkbox(
                value: isCompleted,
                onChanged: (bool? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _stages[index]['is_completed'] = newValue;
                      _stages[index]['has_changed'] = true;
                    });
                  }
                },
                activeColor: Colors.transparent,
                checkColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateRange(String? start, String? end) {
    String startDate = _formatDate(start);
    String endDate = _formatDate(end);
    if (startDate == 'N/A' || endDate == 'N/A') {
      return 'Tanggal Tidak Tersedia';
    }
    final startDt = DateTime.tryParse(start ?? '');
    final endDt = DateTime.tryParse(end ?? '');
    if (startDt != null &&
        endDt != null &&
        startDt.month == endDt.month &&
        startDt.year == endDt.year) {
      return '${DateFormat('d', 'id_ID').format(startDt)} - ${DateFormat('d MMMM yyyy', 'id_ID').format(endDt)}';
    }
    return '$startDate - $endDate';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    'Detail Proyek',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: _brownColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Body Content
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _projectDetailsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: _brownColor),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else if (!snapshot.hasData ||
                      snapshot.data!['project'] == null) {
                    return const Center(
                      child: Text('Data proyek tidak ditemukan.'),
                    );
                  }

                  final projectData =
                      snapshot.data!['project'] as Map<String, dynamic>;
                  final projectTitle =
                      projectData['title'] ?? 'Proyek Tanpa Judul';
                  final startDate = projectData['start_date'] as String?;
                  final endDate = projectData['end_date'] as String?;

                  return SingleChildScrollView(
                    child: Center(
                      child: SizedBox(
                        width: 300,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              projectTitle,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _formatDateRange(startDate, endDate),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Column(
                              children: List.generate(
                                _stages.length,
                                (index) => _buildStageItem(index),
                              ),
                            ),
                            const SizedBox(height: 50),
                            Center(
                              child: SizedBox(
                                width: 248,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: _saveChanges,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _brownColor,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets
                                        .zero, // Padding diatur ke nol karena kita sudah menggunakan SizedBox
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: const Text(
                                    'Simpan',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
