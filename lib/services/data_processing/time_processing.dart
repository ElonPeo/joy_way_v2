import 'package:intl/intl.dart';

class TimeProcessing {
  static  String formatTimestamp(String isoTime) {
    final postTime = DateTime.tryParse(isoTime);
    if (postTime == null) return "";

    final now = DateTime.now();
    final diff = now.difference(postTime);

    if (diff.inSeconds < 60) return "Just Now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} minutes ago";
    if (diff.inHours < 24) return "${diff.inHours} hours ago";
    if (diff.inDays < 7) return "${diff.inDays} days ago";
    return DateFormat('dd/MM/yyyy').format(postTime);
  }

  static String? dateToString(DateTime? date) {
    if (date == null) return null;
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String? timeToString(DateTime? date) {
    if (date == null) return null;
    return DateFormat('HH:mm').format(date);
  }



  static  String formatDepartureTime(String isoString) {
    final dateTime = DateTime.tryParse(isoString);
    if (dateTime == null) return "";

    return DateFormat('MM/dd HH:mm').format(dateTime);
  }


  static Map<String, String> formatDepartureTime2(String? isoString) {
    if (isoString == null || isoString.isEmpty) {
      return {
        'date': 'Invalid date',
        'time': 'Invalid time'
      };
    }

    try {
      DateTime dateTime = DateTime.parse(isoString);
      String dateFormatted = DateFormat('EEE, d MMM').format(dateTime);
      String timeFormatted = DateFormat('hh:mm a').format(dateTime);
      return {
        'date': dateFormatted,
        'time': timeFormatted
      };
    } catch (e) {
      return {
        'date': 'Invalid date',
        'time': 'Invalid time'
      };
    }
  }


  DateTime combineDateAndTime(DateTime date, DateTime time) {
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