import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/screens/notify_screen/pages/request_notice_page.dart';

import 'components/top_bar_notify.dart';

class NotifyScreen extends StatefulWidget {
  const NotifyScreen({super.key});

  @override
  State<NotifyScreen> createState() => _NotifyScreenState();
}

class _NotifyScreenState extends State<NotifyScreen> {
  late final PageController _pc;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pc = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _jumpTo(int index) {
    if (index == _page) return;
    setState(() => _page = index);
    _pc.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: specs.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          TopBarNotify(
            page: _page,
            onPageChanged: _jumpTo,
          ),
          Expanded(
            child: PageView(
              controller: _pc,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (i) => setState(() => _page = i),
              children: [
                const RequestNoticePage(),
                Container(
                  alignment: Alignment.center,
                  child: const Text('Notify'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
