import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:joy_way/models/post/post_display.dart';
import 'package:joy_way/screens/home_screen/top_bar/top_bar.dart';
import 'package:joy_way/screens/post/post_card/post_card.dart';
import 'package:joy_way/services/firebase_services/post_services/post_firestore.dart';
import 'package:joy_way/widgets/animated_container/custom_animated_button.dart';

import '../../../config/general_specifications.dart';
import '../../../models/post/post.dart';
import '../post/edit_post/edit_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<PostDisplay>> _futurePostDisplay;

  @override
  void initState() {
    super.initState();
    _futurePostDisplay = PostFirestore().getLatestPostDisplays();
  }

  Future<void> _refresh() async {
    setState(() {
      _futurePostDisplay = PostFirestore().getLatestPostDisplays();
    });
  }


  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refresh,
            child: FutureBuilder<List<PostDisplay>>(
              future: _futurePostDisplay,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  return const Center(
                    child: Text(
                      "No posts available",
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 100, bottom: 70),
                  itemCount: posts.length,
                  itemBuilder: (ctx, i) => PostCard(postDisplay: posts[i]),
                );
              },
            ),
          ),

          // TopBar
          const Positioned(top: 0, left: 0, right: 0, child: TopBar()),

          // Nút tạo bài đăng
          Positioned(
            bottom: 75,
            right: 10,
            child: CustomAnimatedButton(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => const CreatePostScreen(),
                  ),
                );
              },
              pressedScale: 0.9,
              shadowColor: const Color.fromRGBO(200, 200, 200, 0.6),
              height: 50,
              width: 50,
              child: const Icon(
                Icons.add_rounded,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
