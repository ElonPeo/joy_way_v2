import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:joy_way/widgets/animated_icons/loading_rive_icon.dart';


class ShowLoadingController extends ChangeNotifier {
  bool? _result;
  bool _closed = false;

  void close([bool? result]) {
    if (_closed) return;
    _closed = true;
    _result = result;
    notifyListeners();
  }

  bool get isClosed => _closed;
  bool? get result => _result;
}



class ShowLoading {
  static bool _isVisible = false;
  static Future<bool?> show({
    required BuildContext context,
    String message = '',
    required ShowLoadingController controller,
  }) async {
    if (_isVisible) return null;

    _isVisible = true;
    final completer = Completer<bool?>();
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _AnimatedLoadingSnackBar(
        message: message,
        entry: entry,
        controller: controller,
        completer: completer,
      ),
    );

    Overlay.of(context)?.insert(entry);
    return completer.future;
  }
}


class _AnimatedLoadingSnackBar extends StatefulWidget {
  final String message;
  final OverlayEntry entry;
  final ShowLoadingController controller;
  final Completer<bool?> completer;

  const _AnimatedLoadingSnackBar({
    required this.message,
    required this.entry,
    required this.controller,
    required this.completer,
  });

  @override
  State<_AnimatedLoadingSnackBar> createState() => _AnimatedLoadingSnackBarState();
}

class _AnimatedLoadingSnackBarState extends State<_AnimatedLoadingSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;
  late final Animation<double> _blur;
  late final Animation<Color?> _barrier;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _blur = Tween<double>(begin: 0, end: 15).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));
    _barrier = ColorTween(begin: Colors.transparent, end: Colors.black.withOpacity(0.25))
        .animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));
    _slide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 15),
    ]).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOut));

    // Đóng khi controller phát tín hiệu
    widget.controller.addListener(() {
      if (widget.controller.isClosed) {
        _ac.reverse();
      }
    });

    _ac.addStatusListener((s) {
      if (s == AnimationStatus.dismissed) {
        ShowLoading._isVisible = false;
        if (!widget.completer.isCompleted) {
          widget.completer.complete(widget.controller.result);
        }
        if (mounted) widget.entry.remove();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _ac.forward());
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    const bgColor = Color(0xFF4A628A);

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _ac,
          builder: (_, __) => Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: _blur.value, sigmaY: _blur.value),
                child: const SizedBox(),
              ),
            ),
          ),
        ),
        AnimatedModalBarrier(color: _barrier, dismissible: false),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _ac,
            builder: (_, __) => GestureDetector(
              behavior: HitTestBehavior.opaque, // đảm bảo nhận tap
              onTap: () => widget.controller.close(), // <<< tap ra ngoài để đóng
              child: Container(color: _barrier.value),
            ),
          ),
        ),
        Positioned(
          top: 0, left: 0, right: 0,
          child: SlideTransition(
            position: _slide,
            child: ScaleTransition(
              scale: _scale,
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: Container(
                    height: 140,
                    width: w, color: Colors.white,
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0, right: 0,
                          child: SizedBox(
                            height: 50, width: 55,
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0), // lật ngang: đúng rồi!
                              child: SvgPicture.asset(
                                'assets/notification_bg/bubbles.svg',
                                fit: BoxFit.cover,
                                color: bgColor,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 25),
                            Container(
                              height: 55, width: 55,
                              decoration: BoxDecoration(
                                color: bgColor, borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: LoadingRiveIcon(fatherHeight: 40, fatherWidth: 40),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Hi There!',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.message,
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF969696)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
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
    );
  }
}

