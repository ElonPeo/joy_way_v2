import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class CustomPhotoView extends StatefulWidget {
  final ImageProvider? imageProvider;
  final double height;
  final double width;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final Widget child;

  const CustomPhotoView({
    super.key,
    required this.height,
    required this.width,
    required this.imageProvider,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(40)),
    this.backgroundColor = Colors.transparent,
  });

  @override
  State<CustomPhotoView> createState() => _CustomPhotoViewState();
}

class _CustomPhotoViewState extends State<CustomPhotoView> {
  @override
  Widget build(BuildContext context) {
    final hasImg = widget.imageProvider != null;

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: GestureDetector(
        onTap: () {
          if (!hasImg) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FullScreenImage(
                imageProvider: widget.imageProvider!,
              ),
            ),
          );
        },
        child: Container(
          height: widget.height,
          width: widget.width,
          color: widget.backgroundColor,
          child: hasImg
              ? Image(image: widget.imageProvider!, fit: BoxFit.cover)
              : widget.child,
        ),
      ),
    );
  }
}

class FullScreenImage extends StatefulWidget {
  final ImageProvider imageProvider;

  const FullScreenImage({
    super.key,
    required this.imageProvider,
  });

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  bool _showUI = true;
  final PhotoViewController _controller = PhotoViewController();
  final PhotoViewScaleStateController _scaleStateController =
      PhotoViewScaleStateController();

  @override
  void dispose() {
    _controller.dispose();
    _scaleStateController.dispose();
    super.dispose();
  }

  // true nếu đang ở kích thước ban đầu
  bool _shouldShowUiForState(PhotoViewScaleState state) {
    return state == PhotoViewScaleState.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: GestureDetector(
              onTapUp: (details) => setState(() => _showUI = !_showUI),
              child: PhotoView(
                imageProvider: widget.imageProvider,
                controller: _controller,
                scaleStateController: _scaleStateController,
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
                scaleStateChangedCallback: (state) {
                  final next = _shouldShowUiForState(state);
                  if (next != _showUI) {
                    setState(() => _showUI = next);
                  }
                },
              ),
            ),
          ),
          SafeArea(
            child: AnimatedOpacity(
              opacity: _showUI ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 180),
              child: IgnorePointer(
                ignoring: !_showUI,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(0, 0, 0, 0.5),
                                borderRadius: BorderRadius.circular(100)
                            ),
                            height: 35,
                            width: 35,
                            child: Center(
                              child: ImageIcon(
                                AssetImage(
                                    "assets/icons/other_icons/cross-small.png"),
                                color: Colors.white,
                                size: 30,
                              ),
                            )),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 3),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(0, 0, 0, 0.5),
                            borderRadius: BorderRadius.circular(100)
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: const SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: Center(
                                    child: ImageIcon(
                                      AssetImage(
                                          "assets/icons/other_icons/download.png"),
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  )),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: const SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: Center(
                                    child: ImageIcon(
                                      AssetImage(
                                          "assets/icons/other_icons/location-exclamation.png"),
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  )),
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
        ],
      ),
    );
  }
}
