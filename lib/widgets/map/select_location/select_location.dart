import 'dart:async';
import 'dart:math' as Math;


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:joy_way/config/general_specifications.dart';

import 'package:joy_way/widgets/ShowGeneralDialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/widgets/map/select_location/search_location.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;

import 'package:joy_way/services/mapbox_services/general_map_services.dart';
import 'package:joy_way/widgets/animated_container/animated_button.dart';

import '../../animated_container/animated_icon_button.dart';
import '../../animated_icons/loading_rive_icon.dart';


class SelectLocation extends StatefulWidget {
  const SelectLocation({super.key});

  @override
  State<SelectLocation> createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  late MapboxMap _map;
  PointAnnotationManager? _annoMgr;
  PointAnnotation? _pin;

  bool _bootstrapping = true;
  bool _ready = false;
  geolocator.Position? _userPos;
  CameraOptions? _initCamera;
  GeoPoint? geoPoint;
  GeoPoint? _picked;

  Future<void> _goToMyLocation() async {
    final geolocator.Position? pos = await GeneralMapServices.getCurrentLocation(context);
    if (pos == null) return;
    _userPos = pos;

    final p = Point(coordinates: Position(pos.longitude, pos.latitude));
    await _ensurePin(p);
    await _map.flyTo(
      CameraOptions(center: p, zoom: 15, bearing: 0, pitch: 0),
       MapAnimationOptions(duration: 500),
    );
  }


  // VN bounds
  final _vnBounds = CoordinateBounds(
    southwest: Point(coordinates: Position(102, 8.179)),
    northeast: Point(coordinates: Position(110, 23.5)),
    infiniteBounds: false,
  );




  @override
  void initState() {
    super.initState();
    _bootstrap();
  }
  /// Lấy vị trí hiện tại của người dùng, check quyền.
  Future<void> _bootstrap() async {
    if (mounted) setState(() => _bootstrapping = true);
    final geolocator.Position? pos =
    await GeneralMapServices.getCurrentLocation(context);
    if (!mounted) return;
    if (pos == null) {
      _userPos = null;
      _initCamera = null;
      _ready = false;
    } else {
      _userPos = pos;
      _initCamera = CameraOptions(
        center: Point(coordinates: Position(pos.longitude, pos.latitude)),
        zoom: 14,
        bearing: 0,
        pitch: 0,
      );
      _ready = true;
    }
    setState(() => _bootstrapping = false);
  }

  Future<void> _onMapCreated(MapboxMap controller) async {
    _map = controller;

    await _map.gestures.updateSettings(GesturesSettings(
      scrollEnabled: true,
      pinchToZoomEnabled: true,
      rotateEnabled: false,
      pitchEnabled: false,
      quickZoomEnabled: false,
    )); // Gestures API. :contentReference[oaicite:1]{index=1}

    await _map.setBounds(CameraBoundsOptions(
      bounds: _vnBounds,
      minZoom: 4,
      maxZoom: 19,
    ));
  }

  Future<void> _focusAt(GeoPoint gp, {double zoom = 15}) async {
    final p = Point(coordinates: Position(gp.longitude, gp.latitude));
    await _ensurePin(p);
    await _map.flyTo(
      CameraOptions(center: p, zoom: zoom, bearing: 0, pitch: 0),
      MapAnimationOptions(duration: 500),
    );
  }



  Future<void> _ensurePin(Point p) async {
    _annoMgr ??= await _map.annotations.createPointAnnotationManager();
    if (_pin != null) {
      await _annoMgr!.delete(_pin!);
      _pin = null;
    }
    _pin = await _annoMgr!.create(PointAnnotationOptions(geometry: p));
  }



  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      body: Column(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: specs.screenWidth,
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 50),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 50,
                        child: AnimatedIconButton(
                          onTap: () => Navigator.pop(context),
                          height: 30, width: 20,
                          color: Colors.transparent, shadowColor: Colors.transparent,
                          child: SizedBox(
                            height: 23, width: 23,
                            child: Image.asset("assets/icons/other_icons/angle-left.png"),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30, width: specs.screenWidth - 130,
                        child: Center(child: Text("Select Location",
                          style: GoogleFonts.outfit(
                              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
                        )),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () => {
                      ShowGeneralDialog.General_Dialog(
                        context: context,
                        beginOffset: const Offset(1, 0),
                        child: SearchLocation(
                          onLonLatGeoPoint: (value) async {
                            if (value == null) return;
                            setState(() => geoPoint = value);
                            await _focusAt(geoPoint!, zoom: 15);
                          },
                        ),
                      ),
                    },
                    child: Container(
                      height: 45, width: specs.screenWidth,
                      decoration: BoxDecoration(
                        color: specs.black240, borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 45, width: 45,
                            child: Center(
                              child: Container(
                                height: 38, width: 38,
                                decoration: const BoxDecoration(
                                    color: Colors.black, shape: BoxShape.circle),
                                child: const Center(
                                  child: ImageIcon(
                                      AssetImage("assets/icons/other_icons/search.png"),
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text("Search for location",
                              style: GoogleFonts.outfit(color: specs.black80, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
              height: specs.screenHeight - 160,
              width: specs.screenWidth,
              child: _buildMapArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapArea() {
    if (_bootstrapping) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Loading',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              SizedBox(width: 10),
              LoadingRiveIcon(fatherHeight: 30, fatherWidth: 30),
            ],
          ),
        ),
      );
    } else if (!_ready || _initCamera == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ImageIcon(
                AssetImage("assets/icons/user_infor/location-dot-slash.png"),
                color: Colors.black,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Location permission is required to display maps based on your location.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              AnimatedButton(
                color: Colors.black,
                shadowColor: const Color.fromRGBO(0, 0, 0, 0.12),
                height: 40,
                width: 100,
                text: 'Retry',
                fontSize: 14,
                onTap: _bootstrap,
              ),
            ],
          ),
        ),
      );
    } else {
      return Stack(
        children: [
          MapWidget(
            key: const ValueKey("mapWidget"),
            cameraOptions: _initCamera!,
            mapOptions: MapOptions(
              orientation: NorthOrientation.UPWARDS,
              pixelRatio: MediaQuery.of(context).devicePixelRatio,
            ),
            onMapCreated: _onMapCreated,

            // 👇 Tap trên bản đồ -> đặt pin & hiển thị toạ độ
            onTapListener: (context) async {
              final double lon = context.point.coordinates.lng.toDouble(); // Mapbox: lon
              final double lat = context.point.coordinates.lat.toDouble(); // Mapbox: lat

              final point = Point(coordinates: Position(lon, lat)); // Mapbox Position(lon, lat)

              setState(() {
                _picked = GeoPoint(lat, lon); // Firestore GeoPoint(lat, lon)
              });
              await _ensurePin(point);
            },
          ),
          if (_picked != null)
            Positioned(
              left: 12, right: 12, bottom: 76,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 2))],
                ),
                child: Text(
                  'lat: ${_picked!.latitude.toStringAsFixed(6)}'
                      '   lon: ${_picked!.longitude.toStringAsFixed(6)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),

          // 👇 Nút quay về vị trí hiện tại
          Positioned(
            right: 16, bottom: 16,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _goToMyLocation,
                child: const SizedBox(
                  width: 48, height: 48,
                  child: Icon(Icons.my_location, size: 24),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

}
