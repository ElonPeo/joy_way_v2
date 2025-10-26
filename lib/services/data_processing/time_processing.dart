import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeProcessing {
  /// Hiển thị dạng "Just now", "5 minutes ago", "2 days ago", hoặc dd/MM/yyyy
  static String formatTimestamp(dynamic time) {
    DateTime? postTime;

    if (time is DateTime) {
      postTime = time;
    } else if (time is String) {
      postTime = DateTime.tryParse(time);
    }

    if (postTime == null) return "";

    final now = DateTime.now();
    final diff = now.difference(postTime);

    if (diff.inSeconds < 5) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} minutes ago";
    if (diff.inHours < 24) return "${diff.inHours} hours ago";
    if (diff.inDays < 7) return "${diff.inDays} days ago";

    return DateFormat('dd/MM/yyyy').format(postTime);
  }

  /// Định dạng chỉ ngày (dd/MM/yyyy)
  static String? dateToString(DateTime? date) {
    if (date == null) return null;
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Định dạng chỉ giờ (HH:mm)
  static String formatHourMinute(DateTime? date) {
    if (date == null) return "";
    return DateFormat('HH:mm').format(date);
  }

  /// Chuyển TimeOfDay sang chuỗi theo locale hiện tại
  static String? timeToString(TimeOfDay? time, BuildContext context) {
    if (time == null) return null;
    return time.format(context);
  }

  /// Định dạng đầy đủ ngày–giờ (d/M/y - HH:mm)
  static String? formattedDepartureTime(DateTime? dateTime) {
    if (dateTime == null) return null;
    return DateFormat('d/M/y - HH:mm').format(dateTime);
  }

  /// Tách định dạng riêng ngày + giờ từ ISO string
  static Map<String, String> formatDepartureTime2(String? isoString) {
    if (isoString == null || isoString.isEmpty) {
      return {'date': 'Invalid date', 'time': 'Invalid time'};
    }

    try {
      final dateTime = DateTime.parse(isoString);
      final dateFormatted = DateFormat('EEE, d MMM').format(dateTime);
      final timeFormatted = DateFormat('hh:mm a').format(dateTime);
      return {'date': dateFormatted, 'time': timeFormatted};
    } catch (_) {
      return {'date': 'Invalid date', 'time': 'Invalid time'};
    }
  }

  /// Gộp ngày và giờ (dùng khi người dùng chọn riêng ngày + giờ)
  static DateTime combineDateAndTime(DateTime date, DateTime time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
      time.second,
    );
  }
}
