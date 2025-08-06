import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentPage extends StatefulWidget {
  final String postId;

  const CommentPage({super.key, required this.postId});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _controller = TextEditingController();

  Map<String, dynamic>? mainPost;
  List<Map<String, dynamic>> comments = [];

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('id', timeago.IdMessages());
    fetchPostAndComments();
  }

  Future<void> fetchPostAndComments() async {
    // Fetch post utama
    final postRes = await supabase
        .from('posts')
        .select('content, created_at, profiles(username)')
        .eq('id', widget.postId)
        .single();

    // Fetch komentar
    final commentRes = await supabase
        .from('comments')
        .select('comment, created_at, profiles(username)')
        .eq('post_id', widget.postId)
        .order('created_at');

    setState(() {
      mainPost = postRes;
      comments = List<Map<String, dynamic>>.from(commentRes);
    });
  }

  // Fungsi untuk menampilkan snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
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

  Future<void> addComment(String content) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      _showSnackBar('Anda harus login untuk berkomentar.', isError: true);
      return;
    }

    if (content.isEmpty) {
      _showSnackBar('Komentar tidak boleh kosong.', isError: true);
      return;
    }

    try {
      await supabase.from('comments').insert({
        'post_id': widget.postId,
        'user_id': user.id,
        'comment': content,
      });

      _controller.clear();
      fetchPostAndComments();
      _showSnackBar('Komentar berhasil ditambahkan!');
    } catch (e) {
      _showSnackBar('Gagal menambahkan komentar: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final postUsername = mainPost?['profiles']['username'] ?? '???';
    final postTime = mainPost != null
        ? timeago.format(DateTime.parse(mainPost!['created_at']), locale: 'id')
        : '';
    final postContent = mainPost?['content'] ?? '';

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
            bottom: false,
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
                    'Komentar',
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
      body: Column(
        children: [
          // main post
          if (mainPost != null)
            Card(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              color: Colors.white,
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
                        Text(
                          postUsername,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          postTime,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(postContent),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 1.5,
                      color: const Color(0xFF4B2E2B),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        child: Image.asset(
                          'assets/icons/comment_active.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // reply
          Expanded(
            child: comments.isEmpty
                ? const Center(child: Text('Belum ada komentar.'))
                : ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      final username = comment['profiles']['username'] ?? '???';
                      final time = timeago.format(
                        DateTime.parse(comment['created_at']),
                        locale: 'id',
                      );
                      final content = comment['comment'] ?? '';

                      return Card(
                        margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                        color: Colors.white,
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
                                  const SizedBox(width: 16),
                                  Text(
                                    username,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    time,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(content),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // comment input
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar...',
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
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B2E2B),
                    padding: const EdgeInsets.all(12),
                  ),
                  onPressed: () {
                    final text = _controller.text.trim();
                    addComment(text); // Memanggil fungsi addComment
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
