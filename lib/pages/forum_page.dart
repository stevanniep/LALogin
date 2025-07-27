import 'package:flutter/material.dart';
import 'new_post_page.dart';
import 'comment_page.dart';
import 'forum_card.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final List<Map<String, String>> posts = [
    {
      'author': 'Saya',
      'time': '2 menit yang lalu',
      'content': 'Lorem ipsum dolor sit amet...',
    },
    {
      'author': 'Member No. 1',
      'time': '5 menit yang lalu',
      'content': 'Ada yang tahu cara rakit PC?',
    },
  ];

  void addNewPost(String content) {
    setState(() {
      posts.insert(0, {
        'author': 'Saya',
        'time': 'Baru saja',
        'content': content,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F9),
      appBar: AppBar(
        title: const Text('Forum'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return ForumCard(
                author: post['author']!,
                time: post['time']!,
                content: post['content']!,
                onCommentTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommentPage(
                        author: post['author']!,
                        time: post['time']!,
                        content: post['content']!,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // add post
          Positioned(
            bottom: 24,
            right: 24,
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewPostPage()),
                );
                if (result != null && result is String && result.isNotEmpty) {
                  addNewPost(result);
                }
              },
              child: Image.asset(
                'assets/icons/add_post.png',
                width: 48,
                height: 48,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
