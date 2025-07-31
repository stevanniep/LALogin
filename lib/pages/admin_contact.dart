import 'package:flutter/material.dart';

class AdminContactPage extends StatelessWidget {
  const AdminContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kontak Admin')),
      body: const Center(child: Text('Halaman Kontak Admin')),
    );
  }
}
