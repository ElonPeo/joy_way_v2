import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:joy_way/screens/journey_screen/components/journey_card.dart';
import 'package:joy_way/services/firebase_services/post_services/post_firestore.dart';
import '../../../models/post/post.dart'; // import model Post của bạn

class JourneyScreens extends StatefulWidget {
  const JourneyScreens({super.key});

  @override
  State<JourneyScreens> createState() => _JourneyScreensState();
}

class _JourneyScreensState extends State<JourneyScreens> {
  late Future<({List<Post>? posts, String? error})> _futureResult;

  @override
  void initState() {
    super.initState();
    _futureResult = PostFirestore().getActivePostsOfCurrentUser();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureResult = PostFirestore().getActivePostsOfCurrentUser();
    });
  }


  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<({List<Post>? posts, String? error})>(
        future: _futureResult,
        builder: (context, snapshot) {
          // Đang tải: vẫn trả về ListView rỗng để kéo-để-refresh hoạt động
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 200),
                Center(child: CircularProgressIndicator()),
                SizedBox(height: 200),
              ],
            );
          }

          // Lỗi Future (không phải error trong record)
          if (snapshot.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 100),
                Center(child: Text('${snapshot.error}')),
              ],
            );
          }

          final result = snapshot.data;
          final error  = result?.error;
          final posts  = result?.posts ?? [];

          // Lỗi do logic trả về từ getActivePostsOfCurrentUser
          if (error != null && error.isNotEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 100),
                Center(child: Text(error)),
              ],
            );
          }

          if (posts.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 100),
                Center(child: Text('There is no journey')),
              ],
            );
          }

          // Có dữ liệu
          return ListView.builder(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: JourneyCard(post: post),
              );
            },
          );
        },
      ),
    );
  }
}
