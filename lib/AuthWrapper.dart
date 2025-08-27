import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:joy_way/screens/authentication/foudation_of_auth.dart';
import 'package:joy_way/screens/home/foundation_of_home.dart';


class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _holding = false;
  String? _uidShown;          // user đã chuyển xong
  Future<void>? _delayFuture; // tránh tạo lại future

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (user != null) {
          // Lần đầu thấy user mới -> giữ 3s
          if (_uidShown != user.uid && !_holding) {
            _holding = true;
            _delayFuture ??= Future.delayed(const Duration(milliseconds: 3000));
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await _delayFuture;
              if (!mounted) return;
              setState(() {
                _uidShown = user.uid;
                _holding = false;
                _delayFuture = null; // sạch cho lần sau đăng xuất/đăng nhập
              });
            });
          }
          // Màn hình trong lúc chờ 3s (tuỳ bạn: splash/success/overlay…)
          if (_holding) {
            return const FoundationOfAuth(); // hoặc widget chuyển cảnh
          }
          return const FoundationOfHome();
        } else {
          // reset khi sign out
          _uidShown = null;
          _delayFuture = null;
          _holding = false;
          return const FoundationOfAuth();
        }
      },
    );
  }
}
