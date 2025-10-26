import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:joy_way/widgets/map/view/map_view.dart';



class PhotoMapUrlView extends StatefulWidget {
  final GeoPoint? geoPoint;
  final String? address;
  final double height;
  final double width;
  final String mapboxToken;
  final String style;
  final double zoom;
  final double borderRadius;

  const PhotoMapUrlView({
    super.key,
    required this.geoPoint,
    required this.address,
    required this.width,
    required this.height,
    required this.mapboxToken,
    this.style = 'mapbox/streets-v12',
    this.zoom = 12.0,
    this.borderRadius = 12.0,
  });

  @override
  State<PhotoMapUrlView> createState() => _PhotoMapUrlViewState();
}

class _PhotoMapUrlViewState extends State<PhotoMapUrlView> {
  @override
  Widget build(BuildContext context) {
    if (widget.geoPoint == null) {
      return _placeholder();
    }
    final lon = widget.geoPoint!.longitude;
    final lat = widget.geoPoint!.latitude;
    final w = widget.width.clamp(1, 1280).toInt();
    final h = widget.height.clamp(1, 1280).toInt();
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final scale = dpr >= 1.5 ? '@2x' : '';
    final marker = 'pin-s+ff3b30($lon,$lat)';
    final url =
        'https://api.mapbox.com/styles/v1/${widget.style}/static/$marker/$lon,$lat,${widget.zoom.toStringAsFixed(2)},0,0/$w'
        'x$h$scale?access_token=${widget.mapboxToken}';
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>  Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                MapView(
                  geoPoint: widget.geoPoint,
                  address: widget.address,
                ),
                SafeArea(
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
                                  color: const Color.fromRGBO(0, 0, 0, 0.5),
                                  borderRadius: BorderRadius.circular(100)
                              ),
                              height: 35,
                              width: 35,
                              child: const Center(
                                child: ImageIcon(
                                  AssetImage(
                                      "assets/icons/other_icons/cross-small.png"),
                                  color: Colors.white,
                                  size: 30,
                                ),
                              )),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3,vertical: 3),
                          decoration: BoxDecoration(
                              color: const Color.fromRGBO(0, 0, 0, 0.5),
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
              ],
            ),
          ),





          ),
        );
      },
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            loadingBuilder: (ctx, child, progress) {
              if (progress == null) return child;
              final v = progress.expectedTotalBytes == null
                  ? null
                  : progress.cumulativeBytesLoaded /
                  (progress.expectedTotalBytes ?? 1);
              return Container(
                color: const Color(0xFFEFEFEF),
                alignment: Alignment.center,
                child: const SizedBox(
                  height: 26,
                  width: 26,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (ctx, err, st) => _placeholder(error: true),
          ),
        ),
      ),
    );
  }

  Widget _placeholder({bool error = false}) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Container(
          color: const Color(0xFFEFEFEF),
          alignment: Alignment.center,
          child: Icon(
            error ? Icons.map_outlined : Icons.location_on_outlined,
            size: 26,
            color: const Color(0xFF9E9E9E),
          ),
        ),
      ),
    );
  }
}
