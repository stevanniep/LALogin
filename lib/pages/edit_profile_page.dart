import 'package:flutter/material.dart';
import 'home_page.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const inputDecoration = InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      filled: true,
      fillColor: Color(0xFFF0F0F0),
      border: OutlineInputBorder(borderSide: BorderSide.none),
    );

    double horizontalPadding = MediaQuery.of(context).size.width / 2 - 124;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 3,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Edit Profil", style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Column(
          children: [
            _buildField(label: 'Nama', hint: 'Masukkan nama anda', paddingLeft: horizontalPadding),
            _buildField(label: 'Role', hint: 'Asisten Praktikum', paddingLeft: horizontalPadding),
            _buildField(label: 'Email', hint: 'nama@email.com', paddingLeft: horizontalPadding),
            _buildField(label: 'NIM', hint: '10101000000', paddingLeft: horizontalPadding),
            const SizedBox(height: 32),
            SizedBox(
              width: 248,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B2E2B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => HomePage(initialIndex: 4)),
                      (route) => false,
                    );
                  },
                child: const Text("Simpan", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required double paddingLeft,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: paddingLeft),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(label, style: const TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 248,
            height: 28,
            child: TextField(
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: hint,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: const Color(0xFFF0F0F0),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
