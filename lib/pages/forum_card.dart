import 'package:flutter/material.dart';

class ForumCard extends StatelessWidget {
  final String author;
  final String time;
  final String content;
  final VoidCallback onCommentTap;

  const ForumCard({
    super.key,
    required this.author,
    required this.time,
    required this.content,
    required this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/icons/forumpp.png',
                  width: 32,
                  height: 32,
                ),
                const SizedBox(width: 8),
                Text(author, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(time, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Text(content),
            const SizedBox(height: 16),
            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 1.5,
                  color: Colors.brown,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: onCommentTap,
                    child: Image.asset(
                      'assets/icons/comment.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
