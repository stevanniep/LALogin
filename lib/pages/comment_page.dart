import 'package:flutter/material.dart';

class CommentPage extends StatefulWidget {
  final String author;
  final String time;
  final String content;

  const CommentPage({
    super.key,
    required this.author,
    required this.time,
    required this.content,
  });

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController commentController = TextEditingController();

  final List<Map<String, String>> replies = [
    {
      'author': 'Member No. 2',
      'time': '1 menit yang lalu',
      'text': 'Coba tanya dora kak',
    },
  ];

  void addReply(String text) {
    setState(() {
      replies.add({
        'author': 'Saya',
        'time': 'Baru saja',
        'text': text,
      });
    });
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F9),
      appBar: AppBar(
        title: const Text('Komentar'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // main post
          Card(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/icons/forumpp.png', width: 32, height: 32),
                      const SizedBox(width: 8),
                      Text(widget.author, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text(widget.time, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(widget.content),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 1.5,
                        color: Colors.brown,
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          'assets/icons/comment_active.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // reply
          Expanded(
            child: ListView.builder(
              itemCount: replies.length,
              itemBuilder: (context, index) {
                final reply = replies[index];
                return Card(
                  margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/icons/forumpp.png', width: 32, height: 32),
                            const SizedBox(width: 16),
                            Text(reply['author']!,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Text(
                              reply['time'] ?? '',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(reply['text']!),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // input comment
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: 'Tulis komentar...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    padding: const EdgeInsets.all(12),
                  ),
                  onPressed: () {
                    final text = commentController.text.trim();
                    if (text.isNotEmpty) addReply(text);
                  },
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
