import 'dart:async';
import 'dart:math' as Math;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/services/data_processing/map_processing.dart';
import 'package:joy_way/services/mapbox_services/mapbox_config.dart';

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

  /// Đang check quyền và lấy vị trí
  bool _bootstrapping = true;
  /// Tất cả đã sẵn sàng chưa ?
  bool _ready = false;


  Uint8List? _markerBytes;
  CameraOptions? _initCamera;
  String? _pickedName;
  GeoPoint? _picked;






  @override
  void initState() {
    super.initState();
    _bootstrap();
  }




  
  /// Khởi tạo ảnh pin
  Future<void> _ensureMarkerBytes() async {
    if (_markerBytes != null) return;
    final bytes = await rootBundle.load('assets/icons/map/3d_pin.png');
    _markerBytes = bytes.buffer.asUint8List();
  }

  /// Tạo mới pin nếu chưa có, nếu có rồi thì update cái mới.
  Future<void> _showOrMovePin(GeoPoint geoPoint) async {
    Point p = MapProcessing().fromGeoPointToPoint(geoPoint);
    _annoMgr ??= await _map.annotations.createPointAnnotationManager();
    if (_pin == null) {
      // lần đầu tạo pin
      await _ensureMarkerBytes();
      _pin = await _annoMgr!.create(PointAnnotationOptions(
        geometry: p,
        image: _markerBytes,
        iconAnchor: IconAnchor.BOTTOM,
        iconSize: 1.0,
      ));
    } else {
      // di chuyển pin
      _pin!.geometry = p;
      await _annoMgr!.update(_pin!);
    }
  }

  /// Hiển thị pin map và trả ra tên địa điểm
  Future<String?> _showOrMovePinAndReverseGeocode(GeoPoint geoPoint) async {
    await _showOrMovePin(geoPoint);
    final name = await GeneralMapServices.reverseGeocode(geoPoint, context);
    return name;
  }

  /// Lấy vị trí hiện tại của người dùng, check quyền và đặt cam tại vị trí hiện tại.
  Future<void> _bootstrap() async {
    if (mounted) setState(() => _bootstrapping = true);
    final gp = await GeneralMapServices.getCurrentLocation(context);
    if (!mounted) return;
    if (gp == null) {
      _initCamera = null;
      _ready = false;
    } else {
      // 1) Đặt cam tại vị trí hiện tại của người dùng
      _initCamera = CameraOptions(
        center: Point(coordinates: Position(gp.longitude, gp.latitude)),
        zoom: 15,
        bearing: 0,
        pitch: 0,
      );
      _ready = true;
    }
    setState(() => _bootstrapping = false);
  }

  /// Thông số khi khởi tạo bản đồ
  Future<void> _onMapCreated(MapboxMap controller) async {
    _map = controller;
    await _map.gestures.updateSettings( GesturesSettings(
      scrollEnabled: true,
      pinchToZoomEnabled: true,
      rotateEnabled: false,
      pitchEnabled: false,
      quickZoomEnabled: false,
    ));
    await _map.setBounds(CameraBoundsOptions(
      bounds: MapboxConfig.vnBounds,
      minZoom: 4,
      maxZoom: 19,
    ));
    await _ensureMarkerBytes();
    final gp = await GeneralMapServices.getCurrentLocation(context);
    // 2) Hiển thị pin map
    final nameGeocode = await _showOrMovePinAndReverseGeocode(gp!);
    setState(() {
      _picked = gp;
      _pickedName = nameGeocode;
    });

  }




  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      body: Column(
        children: [
          Container(
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
                      AnimatedButton(
                        height: 30,
                        width: 40,
                        text: "Save",
                        fontSize: 18,
                        color: Colors.transparent,
                        shadowColor: Colors.transparent,
                        textColor: Colors.black,
                        fontWeight: FontWeight.w500,
                        onTap: () async {

                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () => {
                      ShowGeneralDialog.General_Dialog(
                        context: context,
                        beginOffset: const Offset(1, 0),
                        child: SearchLocation(
                            /// Tìm địa đểm và hiển thị pin và tên địa điểm
                            onLonLatGeoPoint: (value) async {
                              // 1) lấy dữ liệu
                              if (value == null) return;
                              final lat = value.latitude;
                              final lon = value.longitude;
                              final p = Point(coordinates: Position(lon, lat));
                              final gp = MapProcessing().fromPointToGeoPoint(p);
                              // 2) Bay tời địa điểm đã tìm
                              await _map.flyTo(
                                CameraOptions(center: p, zoom: 15, bearing: 0, pitch: 0),
                                MapAnimationOptions(duration: 500),
                              );
                              // 3) Hiển thị pin và lấy tên địa điểm
                              final nameGeocode = await _showOrMovePinAndReverseGeocode(gp);
                              setState(() {
                                _picked = gp;
                                _pickedName = nameGeocode;
                              });
                            }

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
    double w = MediaQuery.of(context).size.width;
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
            /// Tap trên bản đồ -> đặt pin & hiển thị toạ độ
              onTapListener: (ct) async {
                // 1) lấy tọa độ tap
                final lon = ct.point.coordinates.lng.toDouble();
                final lat = ct.point.coordinates.lat.toDouble();
                final gp = GeoPoint(lat, lon);
                setState(() => _picked = GeoPoint(lat, lon));
                // 2) Hiển thị pin trên bản đồ và lấy tên địa danh
                final nameGeocode = await _showOrMovePinAndReverseGeocode(gp);
                setState(() {
                  _picked = gp;
                  _pickedName = nameGeocode;
                });
              }
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () async {
                  // 1) Lấy vị trí hiện tại
                  GeoPoint? gp = await GeneralMapServices.getCurrentLocation(context);

                  Point p = MapProcessing().fromGeoPointToPoint(gp!);
                  // 2) di chuyển cam dến vị trí hiện tại
                  await _map.flyTo(
                    CameraOptions(center: p, zoom: 15, bearing: 0, pitch: 0),
                    MapAnimationOptions(duration: 500),
                  );
                  // 3) Hiển thị pin và lấy tên địa điểm
                  final nameGeocode = await _showOrMovePinAndReverseGeocode(gp!);
                  setState(() {
                    _pickedName = nameGeocode;
                  });
                },
                child: const SizedBox(
                  width: 48, height: 48,
                  child: Icon(Icons.my_location, size: 24),
                ),
              ),
            ),
          ),

          if (_picked != null && _pickedName != null)
            Positioned(
              left: 15,
              bottom: 15,
              child: Container(
                width: w - 30,
                padding: EdgeInsets.all(12),
                child:      Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 2))],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'lat: ${_picked!.latitude.toStringAsFixed(6)}'
                            '   lon: ${_picked!.longitude.toStringAsFixed(6)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _pickedName ?? "",
                      )

                    ],
                  ),
                ),
              ),
            ),


        ],
      );
    }
  }
}





