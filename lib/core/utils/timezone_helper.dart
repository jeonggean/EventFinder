import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class TimezoneHelper {
  TimezoneHelper() {
    tz.initializeTimeZones();
  }

  String _getConvertedTime(tz.TZDateTime eventTime, String locationName) {
    try {
      final location = tz.getLocation(locationName);
      final convertedTime = tz.TZDateTime.from(eventTime, location);
      return DateFormat('HH:mm').format(convertedTime);
    } catch (e) {
      return "N/A";
    }
  }

  Map<String, String> getConvertedTimes(
    String isoDateTime,
    String eventTimezone,
  ) {
    tz.TZDateTime eventTime;
    try {
      final eventLocation = tz.getLocation(eventTimezone);
      eventTime = tz.TZDateTime.from(
        DateTime.parse(isoDateTime),
        eventLocation,
      );
    } catch (e) {
      eventTime = tz.TZDateTime.now(tz.local);
    }

    return {
      'WIB': _getConvertedTime(eventTime, 'Asia/Jakarta'),
      'WITA': _getConvertedTime(eventTime, 'Asia/Makassar'),
      'WIT': _getConvertedTime(eventTime, 'Asia/Jayapura'),
      'London': _getConvertedTime(eventTime, 'Europe/London'),
    };
  }

  String getIsoDateTime(String localDate, String localTime) {
    if (localDate == 'No Date' || localTime == 'No Time') {
      return DateTime.now().toIso8601String();
    }
    try {
      return "${localDate}T${localTime}";
    } catch (e) {
      return DateTime.now().toIso8601String();
    }
  }
}
