import 'package:flutter/material.dart';

class NewPostPage extends StatelessWidget {
  const NewPostPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F9),
      appBar: AppBar(
        title: const Text('Post'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Ketik sesuatu',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    Navigator.pop(context, text);
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
