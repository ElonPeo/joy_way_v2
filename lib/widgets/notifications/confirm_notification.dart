import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:joy_way/widgets/animated_container/animated_button.dart';

class ShowConfirmNotification {
  static bool _isNotificationVisible = false;

  /// return: true = Confirm, false = Cancel, null = đang hiển thị cái khác
  static Future<bool?> showAnimatedSnackBar(
      BuildContext context,
      String message,
      int type, {
        Future<void> Function()? onConfirm,
      }) async {
    if (_isNotificationVisible) return null;

    _isNotificationVisible = true;
    final completer = Completer<bool?>();
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _AnimatedConfirmSnackBar(
        errorMessage: message,
        overlayEntry: overlayEntry,
        type: type,
        completer: completer,
        onConfirm: onConfirm,
      ),
    );

    Overlay.of(context)?.insert(overlayEntry);
    return completer.future;
  }
}

class _AnimatedConfirmSnackBar extends StatefulWidget {
  final String errorMessage;
  final OverlayEntry overlayEntry;
  final Duration duration;
  final int type;
  final Completer<bool?> completer;

  /// callback khi nhấn Confirm (có thể async)
  final Future<void> Function()? onConfirm;

  const _AnimatedConfirmSnackBar({
    required this.errorMessage,
    required this.overlayEntry,
    required this.type,
    required this.completer,
    this.onConfirm,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  ___AnimatedConfirmSnackBarState createState() => ___AnimatedConfirmSnackBarState();
}

class ___AnimatedConfirmSnackBarState extends State<_AnimatedConfirmSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _blurSigma;
  late final Animation<double> _backdropOpacity;
  late final Animation<Color?> _barrierColor;

  bool? _pendingResult;

  static const _bgColors = [
    Color.fromRGBO(217, 22, 86, 1),
    Color.fromRGBO(232, 123, 64, 1),
    Color.fromRGBO(102, 136, 115, 1),
    Color.fromRGBO(152, 205, 126, 1),
  ];
  static const _titles = ["Oh Snap!", "Warning!", "Hi There!", "Well done!"];
  static const _icons = [
    "assets/notification_bg/close.svg",
    "assets/notification_bg/warning.svg",
    "assets/notification_bg/question.svg",
    "assets/notification_bg/tick.svg",
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _blurSigma = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _barrierColor = ColorTween(
      begin: Colors.transparent,
      end: Colors.black.withOpacity(0.25),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _backdropOpacity = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 15),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        final result = _pendingResult;
        ShowConfirmNotification._isNotificationVisible = false;
        if (!widget.completer.isCompleted) {
          widget.completer.complete(result);
        }
        if (mounted) widget.overlayEntry.remove();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  void _requestClose(bool? result) {
    if (_controller.status == AnimationStatus.reverse) return;
    _pendingResult = result;
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async => false,
      child: Stack(
        children: [

          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              final s = _blurSigma.value;
              return Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: s, sigmaY: s),
                  child: const SizedBox(),
                ),
              );
            },
          ),


          AnimatedModalBarrier(
            color: _barrierColor,
            dismissible: false, // quan trọng: không cho chạm/tắt khi bấm ra ngoài
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Material(
                  color: Colors.transparent,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: Container(
                      height: 165,
                      width: w,
                      color: Colors.white,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0, right: 0,
                            child: SizedBox(
                              height: 50, width: 55,
                              child: Transform.rotate(
                                angle: 3.14,
                                child: SvgPicture.asset(
                                  'assets/notification_bg/bubbles.svg',
                                  fit: BoxFit.cover,
                                  color: _bgColors[widget.type],
                                ),
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(25),
                                    height: 50, width: 50,
                                    decoration: BoxDecoration(
                                      color: _bgColors[widget.type],
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Center(
                                      child: SizedBox(
                                        height: 30, width: 30,
                                        child: SvgPicture.asset(_icons[widget.type], fit: BoxFit.cover),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _titles[widget.type],
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          widget.errorMessage,
                                          style: const TextStyle(
                                            color: Color.fromRGBO(150, 150, 150, 1),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                ],
                              ),
                              Container(
                                width: w,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    AnimatedButton(
                                      height: 45,
                                      width: w * 0.4,
                                      color: const Color.fromRGBO(100, 100, 100, 1),
                                      textColor: Colors.white,
                                      shadowColor: Colors.black12,
                                      text: 'Cancel',
                                      fontSize: 14,
                                      onTap: () => _requestClose(false),
                                    ),
                                    AnimatedButton(
                                      height: 45,
                                      width: w * 0.4,
                                      color: _bgColors[widget.type],
                                      text: 'Confirm',
                                      fontSize: 14,
                                      onTap: () async {
                                        if (widget.onConfirm != null) {
                                          await widget.onConfirm!.call();
                                        }
                                        _requestClose(true);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
