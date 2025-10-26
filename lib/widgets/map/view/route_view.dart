import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter/material.dart';

class DirectionsResult {
  final String geometry;        // polyline6
  final double distanceMeters;  // m
  final double durationSeconds; // s
  DirectionsResult({
    required this.geometry,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}

Future<DirectionsResult> fetchDirections({
  required GeoPoint departureCoordinate,
  required GeoPoint arrivalCoordinate,
  required String accessToken,
}) async {
  final startLng = departureCoordinate.longitude;
  final startLat = departureCoordinate.latitude;
  final endLng   = arrivalCoordinate.longitude;
  final endLat   = arrivalCoordinate.latitude;

  final url = Uri.parse(
    'https://api.mapbox.com/directions/v5/mapbox/driving/'
        '$startLng,$startLat;$endLng,$endLat'
        '?geometries=polyline6'
        '&overview=full'
        '&alternatives=false'
        '&steps=false'
        '&access_token=$accessToken',
  );

  final res = await http.get(url);
  if (res.statusCode != 200) {
    throw Exception('Directions error: ${res.statusCode} ${res.body}');
  }

  final data = json.decode(res.body);
  final routes = data['routes'] as List?;
  if (routes == null || routes.isEmpty) {
    throw Exception('No route found for the given coordinates.');
  }
  final route = routes.first as Map<String, dynamic>;
  return DirectionsResult(
    geometry: route['geometry'] as String,
    distanceMeters: (route['distance'] as num).toDouble(),
    durationSeconds: (route['duration'] as num).toDouble(),
  );
}

/// Decode polyline6 -> List<Position> (lng, lat)
List<Point> decodePolyline6ToPoints(String polyline) {
  final points = <Point>[];
  int index = 0, lat = 0, lng = 0;

  int decodeChunk() {
    int result = 0, shift = 0, b;
    do {
      b = polyline.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    return (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
  }

  while (index < polyline.length) {
    lat += decodeChunk();
    lng += decodeChunk();
    final dLat = lat / 1e6;
    final dLng = lng / 1e6;
    points.add(Point(coordinates: Position(dLng, dLat)));
  }
  return points;
}

class RoutePreviewBox extends StatefulWidget {
  final GeoPoint start;
  final GeoPoint end;
  final String accessToken;
  final double height;
  final double width;

  const RoutePreviewBox({
    super.key,
    this.width = 300,
    this.height = 300,
    required this.start,
    required this.end,
    required this.accessToken,
  });

  @override
  State<RoutePreviewBox> createState() => _RoutePreviewBoxState();
}

class _RoutePreviewBoxState extends State<RoutePreviewBox> {
  MapboxMap? _mapboxMap;
  PolylineAnnotationManager? _polylineManager;
  PointAnnotationManager? _pointManager;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width, height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: MapWidget(
          key: const ValueKey('route_preview'),
          onMapCreated: (controller) async {
            _mapboxMap = controller;
            _polylineManager = await controller.annotations.createPolylineAnnotationManager();
            _pointManager = await controller.annotations.createPointAnnotationManager();

            // 🔒 Tắt toàn bộ tương tác
            await _mapboxMap!.gestures.updateSettings(
              GesturesSettings(
                rotateEnabled: false,
                pinchToZoomEnabled: false,
                scrollEnabled: false,
                quickZoomEnabled: false,
                doubleTapToZoomInEnabled: false,
                doubleTouchToZoomOutEnabled: false,
                pitchEnabled: false,
                simultaneousRotateAndPinchToZoomEnabled: false,
              ),
            );

            // 🧹 Ẩn các UI mặc định để nhìn gọn như preview ảnh
            await _mapboxMap!.compass.updateSettings( CompassSettings(enabled: false));
            await _mapboxMap!.scaleBar.updateSettings( ScaleBarSettings(enabled: false));
            await _mapboxMap!.attribution.updateSettings( AttributionSettings(enabled: false));
            await _mapboxMap!.logo.updateSettings( LogoSettings(enabled: false));

            await _drawRoute();
          },

          cameraOptions: CameraOptions(
            center: Point(
              coordinates: Position(
                widget.start.longitude,
                widget.start.latitude,
              ),
            ),
            zoom: 10.0,
          ),
          gestureRecognizers: const {},
          styleUri: MapboxStyles.MAPBOX_STREETS,
        ),
      ),
    );
  }

  Future<void> _drawRoute() async {
    if (_mapboxMap == null) return;

    // 1) Directions
    final dir = await fetchDirections(
      departureCoordinate: widget.start,
      arrivalCoordinate: widget.end,
      accessToken: widget.accessToken,
    );

    // 2) Decode polyline6 → List<Position>
    final points = decodePolyline6ToPoints(dir.geometry);
    if (points.isEmpty) return;

    // 3) Polyline (LineString requires List<Position>)
    await _polylineManager?.create(
      PolylineAnnotationOptions(
        geometry: LineString(
          coordinates: points.map((p) => p.coordinates).toList(),
        ),
        lineColor: Colors.blue.value,
        lineWidth: 4.0,
        lineOpacity: 0.9,
      ),
    );

    // 4) Markers đầu/cuối
    await _pointManager?.create(
      PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(widget.start.longitude, widget.start.latitude),
        ),
        iconImage: "marker-15",
        iconSize: 1.2,
      ),
    );
    await _pointManager?.create(
      PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(widget.end.longitude, widget.end.latitude),
        ),
        iconImage: "marker-15",
        iconSize: 1.2,
      ),
    );

    // 5) Fit bounds theo tuyến: cameraForCoordinates + flyTo
    final padding = MbxEdgeInsets(top: 40.0, left: 20.0, bottom: 40.0, right: 20.0);
    final camera = await _mapboxMap!.cameraForCoordinates(
      points,
      padding,
      null,
      null,
    );


    await _mapboxMap!.flyTo(
      camera,
      MapAnimationOptions(duration: 800),
    );
  }
}
