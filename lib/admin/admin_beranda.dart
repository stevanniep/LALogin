import 'package:flutter/material.dart';
import 'admin_tambah_jadwal.dart';

class AdminBeranda extends StatelessWidget {
  const AdminBeranda({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 330,
                  height: 136,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4B2E2B), // warna coklat tua
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Study Group',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '22/09/25',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TULT 13.27',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '18.00 WIB',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 100),

              // Menu ikon
              Center(
                child: Container(
                  width: 340,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _MenuIcon(
                          iconPath: 'assets/adm/tambah.png',
                          label: 'Tambah\nJadwal',
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TambahJadwalPage(),
                              ),
                            );

                            if (result != null &&
                                result is Map<String, String>) {
                              // Lakukan sesuatu dengan data jadwal (opsional)
                              print("Jadwal baru: $result");
                            }
                          },
                        ),
                        const _MenuIcon(
                          iconPath: 'assets/adm/qr.png',
                          label: 'Membuat\nPresensi',
                        ),
                        const _MenuIcon(
                          iconPath: 'assets/adm/data.png',
                          label: 'Data\nAsisten',
                        ),
                        const _MenuIcon(
                          iconPath: 'assets/adm/proyek.png',
                          label: 'Tambah\nProyek',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Komponen ikon + label
class _MenuIcon extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback? onTap;

  const _MenuIcon({required this.iconPath, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Image.asset(iconPath, width: 24, height: 24)),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 11,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
