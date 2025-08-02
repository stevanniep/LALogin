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
  // Gunakan Future untuk mengambil data awal proyek
  late Future<Map<String, dynamic>> _projectDetailsFuture;

  // Variabel untuk menyimpan status checkbox sementara
  late List<Map<String, dynamic>> _stages;

  @override
  void initState() {
    super.initState();
    _projectDetailsFuture = _fetchAndInitializeStages();
  }

  Future<Map<String, dynamic>> _fetchAndInitializeStages() async {
    final data = await _fetchProjectDetails();
    // Simpan data stages ke variabel _stages untuk dimanipulasi secara lokal
    _stages = List<Map<String, dynamic>>.from(data['stages']);
    return data;
  }

  // Fungsi asli untuk mengambil data dari Supabase
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

  // Fungsi baru untuk memperbarui semua perubahan saat tombol "Simpan" ditekan
  Future<void> _saveChanges() async {
    try {
      // Ambil hanya tahap yang berubah
      final stagesToUpdate = _stages
          .where((stage) => stage.containsKey('has_changed'))
          .toList();

      if (stagesToUpdate.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada perubahan untuk disimpan.')),
        );
        return;
      }

      // Buat list dari Future untuk setiap update
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

      // Setelah update berhasil, refresh data
      setState(() {
        _projectDetailsFuture = _fetchAndInitializeStages();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perubahan berhasil disimpan!'),
          duration: Duration(milliseconds: 1500),
        ),
      );
    } on PostgrestException catch (e) {
      debugPrint('Error saving changes: ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan perubahan: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint('Error saving changes: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan perubahan. Coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Widget pembangun untuk setiap item tahap dengan checkbox
  Widget _buildStageItem(int index) {
    // Ambil data dari list lokal
    final stage = _stages[index];
    final stageName = stage['stage_name'] as String;
    final isCompleted = stage['is_completed'] as bool;
    final hasChanged = stage['has_changed'] as bool? ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            stageName,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
          Checkbox(
            value: isCompleted,
            onChanged: (bool? newValue) {
              if (newValue != null) {
                setState(() {
                  _stages[index]['is_completed'] = newValue;
                  _stages[index]['has_changed'] = true;
                });
              }
            },
            activeColor: const Color(0xFF5E4036),
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: WidgetStateBorderSide.resolveWith(
              (states) => BorderSide(
                width: 1.5,
                color: hasChanged
                    ? Colors
                          .orange // Tanda bahwa ini sudah diubah
                    : states.contains(WidgetState.selected)
                    ? const Color(0xFF5E4036)
                    : Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (Fungsi _formatDate dan _formatDateRange tetap sama)
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5E4036)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Detail Proyek',
          style: TextStyle(
            color: Color(0xFF5E4036),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _projectDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF5E4036)),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (!snapshot.hasData || snapshot.data!['project'] == null) {
            return const Center(child: Text('Data proyek tidak ditemukan.'));
          }

          final projectData = snapshot.data!['project'] as Map<String, dynamic>;
          final projectTitle = projectData['title'] ?? 'Proyek Tanpa Judul';
          final startDate = projectData['start_date'] as String?;
          final endDate = projectData['end_date'] as String?;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    projectTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5E4036),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatDateRange(startDate, endDate),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
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
                    child: ElevatedButton(
                      onPressed: _saveChanges, // Panggil fungsi _saveChanges
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E4036),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
