
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:joy_way/services/mapbox_services/general_map_services.dart';
import 'package:joy_way/widgets/animated_container/animated_button.dart';


import '../animated_icons/loading_rive_icon.dart';

class ShowMap extends StatefulWidget {
  const ShowMap({super.key});
  @override
  State<ShowMap> createState() => _ShowMapState();
}

class _ShowMapState extends State<ShowMap> {
  late MapboxMap _map;
  PointAnnotationManager? _annoMgr;
  PointAnnotation? _pin;

  bool _bootstrapping = true;      // <-- trạng thái LOADING thật sự
  bool _ready = false;             // <-- xong bootstrapping & có position
  geolocator.Position? _userPos;
  CameraOptions? _initCamera;

  // VN bounds
  final _vnBounds = CoordinateBounds(
    southwest: Point(coordinates: Position(102.144, 8.179)),
    northeast: Point(coordinates: Position(109.469, 23.392)),
    infiniteBounds: false,
  );

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

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
        center: Point(coordinates: Position(pos.longitude, pos.latitude)), // (lng, lat)
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
    await _map.setBounds(CameraBoundsOptions(
      bounds: _vnBounds,
      minZoom: 4, maxZoom: 19,
    ));
    await _map.location.updateSettings( LocationComponentSettings(
      enabled: true,
      puckBearingEnabled: true,
    ));
    _annoMgr ??= await _map.annotations.createPointAnnotationManager();
  }



  @override
  Widget build(BuildContext context) {
    if (_bootstrapping) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Loading",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 10,),
                const LoadingRiveIcon(fatherHeight: 30, fatherWidth: 30, )
              ],
            ),
          ],
        ),
      );
    }

    if (!_ready || _initCamera == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
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
                    onTap: _bootstrap, // gọi lại toàn bộ flow xin quyền
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(children: [
        MapWidget(
          key: const ValueKey("mapWidget"),
          cameraOptions: _initCamera!,
          onMapCreated: _onMapCreated,
          styleUri: MapboxStyles.MAPBOX_STREETS,
        ),
        SafeArea(
          child: Container(
            height: 64, color: Colors.white,
            child: Row(children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
              const Text("Chọn vị trí",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              IconButton(
                tooltip: 'Về vị trí của tôi',
                icon: const Icon(Icons.my_location),
                onPressed: () async {
                  final enabled =
                  await geolocator.Geolocator.isLocationServiceEnabled();
                  if (!enabled) return;
                  final p = await geolocator.Geolocator.getCurrentPosition(
                    desiredAccuracy: geolocator.LocationAccuracy.high,
                  );
                  await _map.setCamera(CameraOptions(
                    center: Point(coordinates: Position(p.longitude, p.latitude)),
                    zoom: 14,
                  ));
                },
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_pin == null) return;
                  final pos = _pin!.geometry.coordinates;
                  Navigator.pop(context, {'lat': pos.lat, 'lon': pos.lng});
                },
                icon: const Icon(Icons.check),
                label: const Text("Chọn"),
              ),
              const SizedBox(width: 8),
            ]),
          ),
        ),
      ]),
    );
  }
}
