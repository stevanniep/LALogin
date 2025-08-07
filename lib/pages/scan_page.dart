import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/home_page.dart';
import 'riwayat_presensi_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool scanned = false;
  Timer? timeoutTimer;

  @override
  void initState() {
    super.initState();
    timeoutTimer = Timer(const Duration(minutes: 2), () {
      if (!scanned) {
        _showDialog('Scan Gagal', 'Waktu habis. Silakan coba lagi.');
      }
    });
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    controller!.scannedDataStream.listen((scanData) async {
      if (scanned) return;
      scanned = true;
      controller!.pauseCamera();
      timeoutTimer?.cancel();

      final raw = scanData.code;
      if (raw == null || raw.isEmpty) {
        _showDialog('Scan Gagal', 'QR tidak terbaca.');
        return;
      }

      final parts = raw.split('-');
      if (parts.length < 5) {
        _showDialog('Scan Gagal', 'Format QR tidak valid.');
        return;
      }

      final eventId = parts.take(5).join('-');
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        _showDialog('Scan Gagal', 'User belum login.');
        return;
      }

      try {
        final supabase = Supabase.instance.client;

        final event = await supabase
            .from('events')
            .select('id, expired_at')
            .eq('id', eventId)
            .maybeSingle();

        if (event == null) {
          _showDialog('Scan Gagal', 'Event tidak ditemukan.');
          return;
        }

        final expiredAt = DateTime.tryParse(event['expired_at']);
        if (expiredAt != null && DateTime.now().isAfter(expiredAt)) {
          _showDialog('Scan Gagal', 'QR sudah kedaluwarsa.');
          return;
        }

        final existing = await supabase
            .from('attendance')
            .select('id')
            .eq('user_id', userId)
            .eq('event_id', eventId)
            .maybeSingle();

        if (existing != null) {
          _showDialog('Sudah Presensi', 'Kamu sudah presensi event ini.');
          return;
        }

        await supabase.from('attendance').insert({
          'user_id': userId,
          'event_id': eventId,
          'timestamp': DateTime.now().toIso8601String(),
        });

        _showDialog('Scan Berhasil', 'Presensi berhasil tercatat.');
      } catch (e) {
        print("Error: $e");
        _showDialog('Scan Gagal', 'Gagal menyimpan presensi:\n$e');
      }
    });
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller?.resumeCamera();
              scanned = false;
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F9),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 47,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF4B2E2B),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                      'Presensi QR',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        'SCAN QR PRESENSI',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4B2E2B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 330,
                        height: 330,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black54),
                        ),
                        child: QRView(
                          key: qrKey,
                          onQRViewCreated: _onQRViewCreated,
                        ),
                      ),
                      const SizedBox(height: 200),
                      SizedBox(
                        width: 330,
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RiwayatPresensiPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4B2E2B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icons/riwayat.png',
                                width: 20,
                                height: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Lihat Riwayat Presensi',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
