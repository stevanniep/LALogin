import 'package:flutter/material.dart';

class LabProjectPage extends StatefulWidget {
  final String projectName; // Tambahkan parameter untuk nama proyek

  const LabProjectPage({
    super.key,
    this.projectName = 'Project Lab',
  }); // Nilai default

  @override
  State<LabProjectPage> createState() => _LabProjectPageState();
}

class _LabProjectPageState extends State<LabProjectPage> {
  // Gunakan Map untuk menyimpan status checkbox setiap tahap
  final Map<int, bool> _stagesStatus = {
    1: true, // Tahap 1 sudah dicentang sesuai gambar
    2: true, // Tahap 2 sudah dicentang sesuai gambar
    3: false,
    4: false,
    5: false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5E4036)),
          onPressed: () {
            Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
          },
        ),
        title: Text(
          widget.projectName, // Menggunakan nama proyek dari parameter
          style: const TextStyle(
            color: Color(0xFF5E4036),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Ratakan ke kiri
            children: [
              // Bagian nama proyek (jika projectName diisi dari luar)
              Text(
                widget.projectName, // Contoh: 'Project Lab 3'
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5E4036),
                ),
              ),
              const SizedBox(height: 5),
              // Bagian tanggal
              const Text(
                '14 Juni - 14 Agustus',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Daftar Tahap dengan Checkbox
              Column(
                children: _stagesStatus.keys.map((stageNumber) {
                  return _buildStageItem(
                    'Tahap $stageNumber',
                    _stagesStatus[stageNumber]!,
                    (bool? newValue) {
                      setState(() {
                        _stagesStatus[stageNumber] = newValue!;
                      });
                      // Opsional: Lakukan sesuatu saat checkbox diubah
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tahap $stageNumber: ${newValue! ? 'Selesai' : 'Belum Selesai'}',
                          ),
                          duration: const Duration(milliseconds: 500),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 50),

              // Tombol "Simpan"
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Logika yang dijalankan saat tombol "Simpan" ditekan
                    debugPrint('Status Tahap Saat Ini: $_stagesStatus');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Perubahan Disimpan!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF5E4036,
                    ), // Warna latar belakang tombol
                    foregroundColor: Colors.white, // Warna teks tombol
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Sudut membulat
                    ),
                    elevation: 5, // Tambahkan sedikit elevasi
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pembangun untuk setiap item tahap dengan checkbox
  Widget _buildStageItem(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[800])),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF5E4036), // Warna checkbox saat aktif
            checkColor: Colors.white, // Warna tanda centang
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4), // Bentuk kotak checkbox
            ),
            side: WidgetStateBorderSide.resolveWith(
              (states) => BorderSide(
                width: 1.5,
                color: states.contains(WidgetState.selected)
                    ? const Color(0xFF5E4036)
                    : Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
