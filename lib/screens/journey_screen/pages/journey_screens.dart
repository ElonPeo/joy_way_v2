import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:joy_way/screens/journey_screen/components/journey_card.dart';
import '../../../models/post/post.dart'; // import model Post của bạn

class JourneyScreens extends StatefulWidget {
  const JourneyScreens({super.key});

  @override
  State<JourneyScreens> createState() => _JourneyScreensState();
}

class _JourneyScreensState extends State<JourneyScreens> {
  late Future<List<Post>> _futurePosts;

  @override
  void initState() {
    super.initState();
    _futurePosts = _loadPosts();
  }

  Future<List<Post>> _loadPosts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Chưa đăng nhập.");

    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('ownerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((d) => Post.fromDoc(d)).toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _futurePosts = _loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<Post>>(
        future: _futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }

          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(child: Text("Không có hành trình nào."));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 20),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return JourneyCard(post: post);
            },
          );
        },
      ),
    );
  }
}
