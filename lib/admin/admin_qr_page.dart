import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_navbar.dart';

class AdminQRPage extends StatefulWidget {
  final String eventId;

  const AdminQRPage({super.key, required this.eventId});

  @override
  State<AdminQRPage> createState() => _AdminQRPageState();
}

class _AdminQRPageState extends State<AdminQRPage> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? eventData;
  bool isLoading = true;
  Timer? countdownTimer;
  Duration remainingTime = const Duration(minutes: 15);
  String qrCode = "";

  @override
  void initState() {
    super.initState();
    fetchEventData();
  }

  Future<void> fetchEventData() async {
    try {
      final response = await supabase
          .from('events')
          .select()
          .eq('id', widget.eventId)
          .single();

      if (response != null) {
        setState(() {
          eventData = response;
          isLoading = false;
          qrCode = _generateQR();
        });
        _startCountdown();
      } else {
        throw Exception('Event tidak ditemukan');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ambil data event: $e')),
      );
    }
  }

  String _generateQR() {
    return '${widget.eventId}-${DateTime.now().millisecondsSinceEpoch}';
  }

  void _startCountdown() {
    countdownTimer?.cancel();

    setState(() {
      remainingTime = const Duration(minutes: 15);
    });

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.inSeconds <= 1) {
        timer.cancel();
      } else {
        setState(() {
          remainingTime -= const Duration(seconds: 1);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final namaKegiatan = eventData?['title'] ?? eventData?['day_of_week'] ?? 'Nama Kegiatan Tidak Diketahui';

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Presensi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminHomePage(initialIndex: 0)),
            );
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    QrImageView(
                      data: qrCode,
                      version: QrVersions.auto,
                      size: 250.0,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      namaKegiatan,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tempat: ${eventData?['location'] ?? '-'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Tanggal: ${(eventData?['date'] as String?)?.split("T").first ?? '-'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Waktu: ${eventData?['time'] ?? '-'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Sisa waktu: ${_formatDuration(remainingTime)}',
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          qrCode = _generateQR();
                        });
                        _startCountdown();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reload QR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4B2E2B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminHomePage(initialIndex: 0)),
                        );
                      },
                      child: const Text('Kembali ke Beranda'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
