import 'package:flutter/material.dart';
import 'fingerprint_done_page.dart';

class FingerprintPage extends StatelessWidget {
  const FingerprintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Fingerprint", style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 200),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Tempelkan sidik jari anda pada kotak di bawah',
              style: TextStyle(fontSize: 40),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FingerprintDonePage()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Image.asset(
                'assets/fingerprint.png',
                width: 120,
                height: 120,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
