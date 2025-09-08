import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:joy_way/screens/authentication/foundation_of_auth.dart';
import 'package:joy_way/screens/home/foundation_of_home.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _delayStarted = false;
  bool _delayedReady = false;
  bool _isFirstEmission = true;
  String? _lastUid;

  void _startDelayOnce() {
    if (_delayStarted) return;
    _delayStarted = true;
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (!mounted) return;
      setState(() => _delayedReady = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        final user = snap.data;
        final hasUser = user != null;
        // Lần emit đầu tiên của stream:
        if (_isFirstEmission && snap.connectionState == ConnectionState.active) {
          _isFirstEmission = false;
          _lastUid = user?.uid;
          // Nếu đã đăng nhập sẵn từ trước vào Home ngay
          if (hasUser) return const FoundationOfHome();
        }
        // Các lần sau: nếu vừa chuyển null→user (fresh login) → delay 5s
        if (hasUser) {
          final isFreshLogin = _lastUid == null; // trước đó null, giờ có user
          _lastUid = user.uid;

          if (isFreshLogin) {
            _startDelayOnce();
            if (_delayedReady) {
              return const FoundationOfHome();
            } else {
              // giữ nguyên màn Auth để chạy animation trong 5s
              return const FoundationOfAuth();
            }
          } else {
            // đã có user từ trước
            return const FoundationOfHome();
          }
        } else {
          // chưa đăng nhập → reset cờ
          _delayStarted = false;
          _delayedReady = false;
          _lastUid = null;
          return const FoundationOfAuth();
        }
      },
    );
  }
}
