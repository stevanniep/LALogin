import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

class RiwayatPresensiPage extends StatefulWidget {
  const RiwayatPresensiPage({super.key});

  @override
  State<RiwayatPresensiPage> createState() => _RiwayatPresensiPageState();
}

class _RiwayatPresensiPageState extends State<RiwayatPresensiPage> {
  late Future<Map<String, dynamic>> data;

  @override
  void initState() {
    super.initState();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      data = _loadData(userId);
    }
  }

  Future<Map<String, dynamic>> _loadData(String userId) async {
    final client = Supabase.instance.client;

    // Presensi Harian
    final allEvents = await client
        .from('events')
        .select('id, day_of_week')
        .eq('type', 'harian');

    final grouped = <String, List<String>>{};
    for (var e in allEvents) {
      final day = e['day_of_week'] ?? 'Tidak diketahui';
      grouped.putIfAbsent(day, () => []).add(e['id']);
    }

    final resultHarian = <String, Map<String, dynamic>>{};
    for (var day in grouped.keys) {
      final ids = grouped[day]!;
      final count = ids.length;
      final hadir = await client
          .from('attendance')
          .select('id')
          .inFilter('event_id', ids)
          .eq('user_id', userId);
      resultHarian[day] = {
        'total': count,
        'hadir': hadir.length,
      };
    }

    // Event Individu (tipe: event)
    final allEventEvents = await client
        .from('events')
        .select('id, date, title')
        .eq('type', 'event');

    final eventMap = <String, List<Map<String, String>>>{};
    for (var e in allEventEvents) {
      final title = e['title'] ?? 'Tanpa Judul';
      final date = e['date'];
      if (date == null) continue;
      final status = await client
          .from('attendance')
          .select('id')
          .eq('user_id', userId)
          .eq('event_id', e['id'])
          .maybeSingle();

      eventMap.putIfAbsent(title, () => []).add({
        'date': date.toString().split('T')[0],
        'status': status != null ? 'Hadir' : 'Tidak Hadir',
      });
    }

    return {
      'harian': resultHarian,
      'events': eventMap,
    };
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("Belum login")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F9),
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
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(initialIndex: 2),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/icons/kembali.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Riwayat Presensi',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF4B2E2B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: data,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(child: Text('Gagal memuat data'));
                  }

                  final harian = snapshot.data!['harian'] as Map<String, dynamic>;
                  final events = snapshot.data!['events'] as Map<String, List>;

                  return ListView(
                    padding: const EdgeInsets.all(40),
                    children: [
                      CustomExpansionTile(
                        title: 'Presensi Harian',
                       content: harian.entries.map((e) {
                          final hadir = e.value['hadir'] ?? 0;
                          final total = e.value['total'] ?? 0;
                          final persen = total > 0 ? ((hadir / total) * 100).toStringAsFixed(0) : '0';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.5),
                            child: Row(
                              children: [
                                // Hari (kiri)
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    e.key,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: Color(0xFF4B2E2B),
                                    ),
                                  ),
                                ),

                                // Hadir / Total (tengah)
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      '$hadir / $total',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF4B2E2B),
                                      ),
                                    ),
                                  ),
                                ),

                                // Persentase (kanan)
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    '$persen%',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: Color(0xFF4B2E2B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      ...events.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CustomExpansionTile(
                            title: entry.key,
                            content: entry.value.map((row) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        row['date']!,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: Color(0xFF4B2E2B),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      row['status']!,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF4B2E2B),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }
}

class CustomExpansionTile extends StatefulWidget {
  final String title;
  final List<Widget> content;

  const CustomExpansionTile({
    super.key,
    required this.title,
    this.content = const [],
  });

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 320,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              childrenPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              initiallyExpanded: _isExpanded,
              onExpansionChanged: (value) => setState(() {
                _isExpanded = value;
              }),
              title: SizedBox(
                height: 40,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Color(0xFF4B2E2B),
                    ),
                  ),
                ),
              ),
              trailing: AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Image.asset(
                  'assets/icons/detail.png',
                  width: 20,
                  height: 20,
                  color: const Color(0xFF4B2E2B),
                ),
              ),
              children: widget.content.isEmpty
                  ? [
                      const Text(
                        'Belum ada data.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      )
                    ]
                  : widget.content,
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildBottomNavBar(BuildContext context) {
  const selectedIndex = 2;

  final iconNames = [
    ['home.png', 'home_active.png'],
    ['project.png', 'project_active.png'],
    ['scan.png', 'scan_active.png'],
    ['forum.png', 'forum_active.png'],
    ['profile.png', 'profile_active.png'],
  ];

  final labels = ['Beranda', 'Proyek', 'Scan', 'Forum', 'Profil'];

  return Container(
    height: 72,
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Row(
      children: List.generate(5, (index) {
        final isSelected = selectedIndex == index;
        final iconPath = isSelected
            ? 'assets/icons/${iconNames[index][1]}'
            : 'assets/icons/${iconNames[index][0]}';

        return Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomePage(initialIndex: index),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  color: isSelected
                      ? const Color(0xFF5E4036)
                      : Colors.transparent,
                ),
                const SizedBox(height: 8),
                Image.asset(iconPath, width: 24, height: 24),
                const SizedBox(height: 4),
                Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? const Color(0xFF5E4036) : Colors.grey,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      }),
    ),
  );
}