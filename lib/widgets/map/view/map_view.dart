import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../services/data_processing/map_processing.dart';
import '../../../services/mapbox_services/general_map_services.dart';
import '../../../services/mapbox_services/mapbox_config.dart';
import '../../animated_container/animated_button.dart';
import '../../animated_icons/loading_rive_icon.dart';

class MapView extends StatefulWidget {
  final GeoPoint? geoPoint;
  final String? address;

  const MapView({
    super.key,
    required this.geoPoint,
    required this.address,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late MapboxMap _map;

  bool _bootstrapping = true;
  bool _ready = false;

  Uint8List? _markerBytes;
  CameraOptions? _initCamera;

  PointAnnotationManager? _annoMgr;
  PointAnnotation? _pin;

  GeoPoint? _userPos;
  GeoPoint? _pinPos;
  String? _address;

  @override
  void initState() {
    super.initState();
    _address = widget.address ?? '';
    _pinPos = widget.geoPoint;
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (mounted) setState(() => _bootstrapping = true);
    final gp = await GeneralMapServices.getCurrentLocation(context);
    _userPos = gp;
    final center = (_userPos ?? _pinPos);
    if (center != null) {
      _initCamera = CameraOptions(
        center: MapProcessing().fromGeoPointToPoint(center),
        zoom: 15,
        bearing: 0,
        pitch: 0,
      );
      _ready = true;
    } else {
      _ready = false;
      _initCamera = null;
    }

    if (mounted) setState(() => _bootstrapping = false);
  }

  Future<void> _ensureMarkerBytes() async {
    if (_markerBytes != null) return;
    final bytes = await rootBundle.load('assets/icons/map/3d_pin.png');
    _markerBytes = bytes.buffer.asUint8List();
  }

  Future<void> _onMapCreated(MapboxMap controller) async {
    _map = controller;

    await _map.gestures.updateSettings(GesturesSettings(
      scrollEnabled: true,
      pinchToZoomEnabled: true,
      rotateEnabled: false,
      pitchEnabled: false,
      quickZoomEnabled: true,
    ));

    // Hiển thị puck vị trí hiện tại
    await _map.location.updateSettings(LocationComponentSettings(
      enabled: true,
      pulsingEnabled: true,
      puckBearingEnabled: false,
      showAccuracyRing: false,
    ));
    await _map.setBounds(CameraBoundsOptions(
      bounds: MapboxConfig.vnBounds,
      minZoom: 3.5,
      maxZoom: 19,
    ));

    _annoMgr ??= await _map.annotations.createPointAnnotationManager();
    await _ensureMarkerBytes();

    // Tạo pin nếu có geoPoint
    if (_pinPos != null) {
      await _showPin(_pinPos!);
    }
    final camTarget = (_userPos ?? _pinPos);
    if (camTarget != null) {
      await _map.setCamera(CameraOptions(
        center: MapProcessing().fromGeoPointToPoint(camTarget),
        zoom: 16,
      ));
    }
  }

  Future<void> _showPin(GeoPoint gp) async {
    final p = MapProcessing().fromGeoPointToPoint(gp);
    await _ensureMarkerBytes();
    _pin = await _annoMgr!.create(PointAnnotationOptions(
      geometry: p,
      image: _markerBytes,
      iconAnchor: IconAnchor.BOTTOM,
      iconSize: 1.0,
    ));
  }

  Future<void> _moveCameraTo(GeoPoint gp, {double? zoom}) async {
    await _map.flyTo(
      CameraOptions(
        center: MapProcessing().fromGeoPointToPoint(gp),
        zoom: zoom,
      ),
      MapAnimationOptions(duration: 500),
    );
  }

  Future<void> _recenterToUser() async {
    // Cập nhật lại vị trí hiện tại và bay tới
    final gp = await GeneralMapServices.getCurrentLocation(context);
    if (gp != null) {
      _userPos = gp;
      await _moveCameraTo(gp, zoom: 16);
    }
  }


  Future<void> _flyToPin() async {
    final gp = _pinPos;
    if (gp == null) return;
    await _moveCameraTo(gp, zoom: 16);
  }

  Future<void> _updatePin(GeoPoint gp) async {
    _pinPos = gp;
    if (_annoMgr != null) {
      if (_pin != null) {
        await _annoMgr!.delete(_pin!);
        _pin = null;
      }
      await _showPin(gp);
      await _moveCameraTo(gp);
    }
  }

  @override
  void dispose() {
    _annoMgr?.deleteAll();
    _annoMgr = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

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
    }

    if (!_ready || _initCamera == null) {
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
    }

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
        ),

        /// Khung thông tin địa chỉ
        Positioned(
          left: 15,
          bottom: 15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                  height: 48,
                  width: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: GestureDetector(
                    onTap: _flyToPin,
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Center(
                          child: Image.asset(
                              height: 30,
                              width: 30,
                              "assets/icons/map/3d_pin.png")),
                    ),
                  )),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 48,
                width: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: IconButton(
                  onPressed: _recenterToUser,
                  icon: const Icon(
                    Icons.my_location,
                    size: 24,
                  ),
                ),
              ),
              Container(
                width: w - 30,
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x1F000000),
                          blurRadius: 8,
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.place_outlined,
                          size: 18, color: Colors.black),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _address ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
