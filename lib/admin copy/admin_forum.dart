import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'forum_card.dart';
import 'new_post_page.dart';
import 'comment_page.dart';

class AdminForumPage extends StatefulWidget {
  const AdminForumPage({super.key});

  @override
  State<AdminForumPage> createState() => _AdminForumPageState();
}

class _AdminForumPageState extends State<AdminForumPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('id', timeago.IdMessages());
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final response = await supabase
        .from('posts')
        .select('id, content, created_at, profiles(username)')
        .order('created_at', ascending: false);

    setState(() {
      posts = List<Map<String, dynamic>>.from(response);
    });
  }

  void addNewPost(Map<String, dynamic> newPost) {
    setState(() {
      posts.insert(0, newPost);
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
        automaticallyImplyLeading: false,
      ),
      body: posts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                final author = post['profiles']['username'] ?? '???';
                final content = post['content'] ?? '';
                final createdAt = DateTime.parse(post['created_at']);
                final time = timeago.format(createdAt, locale: 'id');

                return ForumCard(
                  author: author,
                  content: content,
                  time: time,
                  onCommentTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommentPage(postId: post['id']),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
        child: GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NewPostPage()),
            );
            if (result != null) {
              fetchPosts(); // refresh post dari server
            }
          },
          child: Image.asset(
            'assets/icons/add_post.png',
            width: 56, // atau 48 sesuai ukuran asli PNG kamu
            height: 56,
          ),
        ),
      ),
    );
  }
}