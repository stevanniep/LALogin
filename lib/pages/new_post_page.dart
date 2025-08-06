import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewPostPage extends StatelessWidget {
  const NewPostPage({super.key});

  // Fungsi untuk menampilkan snackbar
  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF4B2E2B),
        duration: const Duration(
          milliseconds: 1500,
        ), // Konsisten dengan durasi sebelumnya
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    final supabase = Supabase.instance.client;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
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
          child: SafeArea(
            bottom:
                false, // Menghindari padding di bagian bawah SafeArea jika ada
            child: Padding(
              padding: const EdgeInsets.only(
                top: 12,
                left: 16,
                right: 16,
                bottom: 12,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      'assets/icons/kembali.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Post',
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
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Ketik sesuatu',
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  // Mengubah warna saat fokus
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: Color(0xFF4B2E2B), // Warna yang diinginkan
                    width: 2.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B2E2B),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () async {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    final user = supabase.auth.currentUser;
                    try {
                      await supabase.from('posts').insert({
                        'user_id': user!.id,
                        'content': text,
                      });
                      _showSnackBar(context, 'Postingan berhasil dibuat!');
                      Navigator.pop(context, true);
                    } catch (e) {
                      _showSnackBar(
                        context,
                        'Gagal membuat postingan: $e',
                        isError: true,
                      );
                    }
                  } else {
                    _showSnackBar(
                      context,
                      'Postingan tidak boleh kosong.',
                      isError: true,
                    );
                  }
                },
                child: const Text(
                  'Post',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
