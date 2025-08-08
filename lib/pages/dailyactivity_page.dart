import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DailyActivityPage extends StatefulWidget {
  const DailyActivityPage({super.key});

  @override
  State<DailyActivityPage> createState() => _DailyActivityPageState();
}

class _DailyActivityPageState extends State<DailyActivityPage> {
  final TextEditingController _deskripsiAktivitasController =
      TextEditingController();
  final TextEditingController _lamaWaktuController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();

  final List<String> _kategoriKegiatan = [
    'Eksperimen',
    'Coding',
    'Membaca jurnal',
    'Diskusi riset',
    'Menulis dokumentasi',
    'Lainnya',
  ];

  final List<String> _timeUnits = ['Jam', 'Menit'];
  String _selectedTimeUnit = 'Jam';

  String? _selectedKategori;

  DateTime? _selectedDate;

  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _tanggalController.text =
        "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
  }

  @override
  void dispose() {
    _deskripsiAktivitasController.dispose();
    _lamaWaktuController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  Future<String?> _getUsername() async {
    final String? userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      return null;
    }

    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('profiles')
          .select('username')
          .eq('user_id', userId);

      if (response.isNotEmpty && response.first['username'] != null) {
        return response.first['username'] as String;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching username: $e');
      return null;
    }
  }

  Future<void> _saveActivityToSupabase() async {
    if (_selectedKategori == null ||
        _deskripsiAktivitasController.text.isEmpty ||
        _lamaWaktuController.text.isEmpty ||
        _tanggalController.text.isEmpty) {
      _showSnackBar('Semua field harus diisi!', isError: true);
      return;
    }

    try {
      final String? userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        _showSnackBar(
          'Anda harus login untuk menyimpan aktivitas.',
          isError: true,
        );
        return;
      }

      final String? username = await _getUsername();
      if (username == null) {
        _showSnackBar(
          'Gagal mendapatkan username. Silakan coba lagi.',
          isError: true,
        );
        return;
      }

      final String activityKind = _selectedKategori!;
      final String activityDescription = _deskripsiAktivitasController.text;

      double timeLength = double.parse(_lamaWaktuController.text);
      if (_selectedTimeUnit == 'Menit') {
        timeLength = timeLength / 60;
      }

      final DateTime parsedDate = _parseDate(_tanggalController.text);
      final String date = DateFormat('yyyy-MM-dd').format(parsedDate);

      await supabase.from('users_contribution').insert({
        'user_id': userId,
        'username': username,
        'activity_kind': activityKind,
        'activity_description': activityDescription,
        'time_length': timeLength,
        'date': date,
      });

      _showSnackBar('Aktivitas Berhasil Ditambahkan!');

      _deskripsiAktivitasController.clear();
      _lamaWaktuController.clear();
      _tanggalController.clear();
      setState(() {
        _selectedKategori = null;
        _selectedDate = null;
        _selectedTimeUnit = 'Jam';
      });
    } on FormatException {
      _showSnackBar('Lama waktu harus berupa angka!', isError: true);
    } catch (e) {
      debugPrint('Error saving to Supabase: $e');
      _showSnackBar(
        'Gagal menambahkan aktivitas: ${e.toString()}',
        isError: true,
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF4B2E2B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  DateTime _parseDate(String input) {
    final parts = input.split('/');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF4B2E2B),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4B2E2B),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      String formattedDate =
          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      setState(() {
        _selectedDate = pickedDate;
        _tanggalController.text = formattedDate;
      });
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
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF4B2E2B),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Aktivitas Harian',
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 70),
                    _buildDropdownKategori(),
                    _inputField(
                      'Deskripsi Aktivitas',
                      _deskripsiAktivitasController,
                      isDynamicHeight: true,
                    ),
                    _buildTimeInput(),
                    _inputField(
                      'Tanggal',
                      _tanggalController,
                      isDateField: true,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 248,
                      height: 38,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B2E2B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _saveActivityToSupabase,
                        child: const Text(
                          'Tambah',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembantu untuk membuat dropdown kategori dengan ukuran font dan box yang seragam
  Widget _buildDropdownKategori() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Kegiatan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 248,
          height: 30, // Ketinggian box disamakan
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF4B2E2B).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedKategori,
              hint: const Text(
                'Pilih Kategori',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13, // Ukuran font disamakan
                ),
              ),
              isExpanded: true,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13, // Ukuran font disamakan
                color: Colors.black,
              ),
              items: _kategoriKegiatan.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedKategori = newValue;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Widget baru untuk input waktu dengan dropdown satuan yang sudah diperbaiki
  Widget _buildTimeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lama waktu',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: 248,
          height: 30,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _lamaWaktuController,
                  cursorColor: Colors.black,
                  style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF4B2E2B).withOpacity(0.2),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Container untuk dropdown sekarang memiliki lebar fleksibel
              // dengan memberikan padding agar teks tidak terpotong
              Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4B2E2B).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTimeUnit,
                    // isExpanded dihilangkan agar dropdown menyesuaikan ukuran teks
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.black,
                    ),
                    items: _timeUnits.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedTimeUnit = newValue!;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Widget pembantu untuk membuat field input teks dengan ukuran box dan font yang seragam
  Widget _inputField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool isDateField = false,
    bool isDynamicHeight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: 248,
          height: isDynamicHeight ? null : 30,
          child: TextField(
            controller: controller,
            cursorColor: Colors.black,
            style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
            maxLines: isDynamicHeight ? null : 1,
            minLines: isDynamicHeight ? 1 : null,
            keyboardType: keyboardType,
            readOnly: isDateField,
            onTap: isDateField ? () => _selectDate(context) : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF4B2E2B).withOpacity(0.2),
              contentPadding: isDynamicHeight
                  ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                  : const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              suffixIcon: isDateField
                  ? const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.black,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
