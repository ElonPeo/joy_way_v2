import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:joy_way/widgets/notifications/confirm_notification.dart';

class GeneralMapServices {
  /// Trả về Position hoặc null nếu user từ chối
  static Future<Position?> getCurrentLocation(BuildContext context) async {
    // 1) Kiểm tra dịch vụ
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      ConfirmNotification.showAnimatedSnackBar(context,
          "Location services are off, we will be back soon.",
          1 , onConfirm: () async {
            await Geolocator.openLocationSettings();
          });
      return null;
    }

    // 2) Quyền truy cập
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ConfirmNotification.showAnimatedSnackBar(context,
            "It looks like you just opted out of us tracking your location, go to settings and allow us to track your location to use this feature.",
            1 , onConfirm: () async {
          await Geolocator.openLocationSettings();
        });
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ConfirmNotification.showAnimatedSnackBar(context, "Action denied, go to settings and allow us to track your location.", 1 , onConfirm: () async {
        await Geolocator.openLocationSettings();
      });
      return null;
    }

    // 3) Lấy vị trí
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return pos;
  }


}
