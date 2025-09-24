import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:joy_way/widgets/notifications/confirm_notification.dart';
import 'package:http/http.dart' as http;
import 'package:joy_way/widgets/notifications/show_notification.dart';
import 'dart:convert';


import 'package:geolocator/geolocator.dart' as geolocator;



import 'mapbox_config.dart';

class GeneralMapServices {

  /// Trả về Position hoặc null nếu user từ chối
  static Future<GeoPoint?> getCurrentLocation(BuildContext context) async {
    // 1) Dịch vụ
    final serviceEnabled = await geolocator.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await geolocator.Geolocator.openLocationSettings();
      ConfirmNotification.showAnimatedSnackBar(
        context,
        "Location services are off, we will be back soon.",
        1,
        onConfirm: () async => await geolocator.Geolocator.openLocationSettings(),
      );
      return null;
    }

    // 2) Quyền
    var permission = await geolocator.Geolocator.checkPermission();
    if (permission == geolocator.LocationPermission.denied) {
      permission = await geolocator.Geolocator.requestPermission();
      if (permission == geolocator.LocationPermission.denied) {
        ConfirmNotification.showAnimatedSnackBar(
          context,
          "It looks like you just opted out of us tracking your location, go to settings and allow us to track your location to use this feature.",
          1,
          onConfirm: () async => await geolocator.Geolocator.openLocationSettings(),
        );
        return null;
      }
    }
    if (permission == geolocator.LocationPermission.deniedForever) {
      ConfirmNotification.showAnimatedSnackBar(
        context,
        "Action denied, go to settings and allow us to track your location.",
        1,
        onConfirm: () async => await geolocator.Geolocator.openLocationSettings(),
      );
      return null;
    }

    // 3) Vị trí -> GeoPoint (lat, lon)
    final pos = await geolocator.Geolocator.getCurrentPosition(
      desiredAccuracy: geolocator.LocationAccuracy.high,
    );
    return GeoPoint(pos.latitude, pos.longitude);
  }


  /// Chuyển tọa độ thành địa điểm
  static Future<String> reverseGeocode(GeoPoint geoPoint, BuildContext context) async {
    try {
      final lon = geoPoint.longitude;
      final lat = geoPoint.latitude;
      final url = Uri.https(
        'api.mapbox.com',
        '/geocoding/v5/mapbox.places/$lon,$lat.json',
        {
          'access_token': MapboxConfig.accessToken,
          'language': 'vi',
          'types': 'poi,address,place,locality,neighborhood,district,region,country',
          'country': 'VN',
        },
      );

      final res = await http.get(url).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        final features = (body['features'] as List?) ?? const [];
        if (features.isEmpty) return 'Unknown location';
        final f = features.first as Map<String, dynamic>;

        final placeName = f['place_name_vi'] as String?;
        return ( placeName ?? 'Unknown location').toString();
      } else {
        final msg = 'Geocoding error: HTTP ${res.statusCode}';
        ShowNotification.showAnimatedSnackBar(
          context, msg, 0, const Duration(milliseconds: 500),
        );
        return 'Unknown location';
      }
    } on TimeoutException {
      ShowNotification.showAnimatedSnackBar(
        context, 'Geocoding timeout', 1, const Duration(milliseconds: 500),
      );
      return 'Unknown location';
    } catch (e) {
      ShowNotification.showAnimatedSnackBar(
        context, 'Geocoding failed: $e', 1, const Duration(milliseconds: 500),
      );
      return 'Unknown location';
    }
  }





}

