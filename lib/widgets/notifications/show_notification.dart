import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ShowNotification {
  // Biến cờ để kiểm tra trạng thái hiển thị của thông báo
  static bool _isNotificationVisible = false;
  static void showAnimatedSnackBar(
      BuildContext context,
      String message,
      int type,
      Duration duration,
      ) {
    // NẾU ĐANG CÓ THÔNG BÁO -> KHÔNG LÀM GÌ CẢ
    if (_isNotificationVisible) {
      return;
    }

    // Đánh dấu là đang có thông báo
    _isNotificationVisible = true;
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _AnimatedSnackBar(
        errorMessage: message,
        overlayEntry: overlayEntry,
        type: type,
      ),
    );

    Overlay.of(context)?.insert(overlayEntry);
  }
}
class _AnimatedSnackBar extends StatefulWidget {
  final String errorMessage;
  final OverlayEntry overlayEntry;
  final Duration duration;
  final int type;

  const _AnimatedSnackBar({
    required this.errorMessage,
    required this.overlayEntry,
    required this.type,
    this.duration =  const Duration(milliseconds: 500),
  });

  @override
  __AnimatedSnackBarState createState() => __AnimatedSnackBarState();
}

class __AnimatedSnackBarState extends State<_AnimatedSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  final GlobalKey _snackBarKey = GlobalKey();

  List<Color> _colorListBackground = [
    Color.fromRGBO(217, 22, 86, 1),
    Color.fromRGBO(232, 123, 64, 1),
    Color.fromRGBO(74, 98, 138, 1),
    Color.fromRGBO(152, 205, 126, 1),
  ];


  List<String> _titleErr = ["Oh Snap!", "Warning!", "Hi There!", "Well done!"];
  List<String> _iconPath = [
    "assets/notification_bg/close.svg",
    "assets/notification_bg/warning.svg",
    "assets/notification_bg/question.svg",
    "assets/notification_bg/tick.svg",
  ];

  @override
  void initState() {
    super.initState();

    // 1. Khởi tạo AnimationController với thời gian dài hơn một chút
    // để hiệu ứng nảy (bounce) được mượt mà.
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // 2. Thiết lập animation trượt xuống (không thay đổi)
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic, // Sử dụng curve mượt hơn
          ),
        );

    // 3. Sử dụng TweenSequence để tạo hiệu ứng scale theo chuỗi
    _scaleAnimation = TweenSequence<double>([
      // Giai đoạn 1: Phóng to từ nhỏ đến kích thước thật (overshoot)
      TweenSequenceItem(tween: Tween<double>(begin: 0.5, end: 1), weight: 70.0),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 1.05),
        weight: 15.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1),
        weight: 15.0,
      ),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // 4. Lắng nghe trạng thái animation để tự động ẩn và gỡ bỏ
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted) {
            _controller.reverse();
          }
        });
      } else if (status == AnimationStatus.dismissed) {
        ShowNotification._isNotificationVisible = false;

        if (mounted) {
          widget.overlayEntry.remove();
        }
      }
    });

    // 5. Bắt đầu animation sau khi widget được build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Positioned(
      top: 15,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              key: _snackBarKey,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: Stack(
                children: [
                  // Lớp làm mờ blur
                  ClipPath(
                    clipper: ShapeBorderClipper(
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                    child: Stack(
                      children: [
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(color: Colors.transparent),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 0,
                                right: 0,
                                child: SizedBox(
                                  height: 50,
                                  width: 55,
                                  child: Transform.rotate(
                                    angle: 3.14 ,
                                    child: SvgPicture.asset(
                                      'assets/notification_bg/bubbles.svg',
                                      fit: BoxFit.cover,
                                      color: _colorListBackground[widget.type],
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.all(20),
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: _colorListBackground[widget.type],
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Center(
                                          child: SizedBox(
                                            height: 30,
                                            width: 30,
                                            child: SvgPicture.asset(
                                              _iconPath[widget.type],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(vertical: 20),
                                        width: screenWidth - 140,
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _titleErr[widget.type],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Text(
                                              widget.errorMessage,
                                              style: const TextStyle(
                                                  color: Color.fromRGBO(240, 240, 240, 1),
                                                  fontSize: 11
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ), // Đặt nội dung của bạn ở đây
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
