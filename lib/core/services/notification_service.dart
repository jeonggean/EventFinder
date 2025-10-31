import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const int _dailyNotificationId = 1;

  static Future<void> initNotifications() async {
    if (kIsWeb) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> configureLocalTimeZone() async {
    if (kIsWeb) return;
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  static Future<bool> _isAndroidPermissionGranted() async {
    return await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.areNotificationsEnabled() ??
        false;
  }

  static Future<bool> _requestAndroidNotificationsPermission() async {
    return await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ??
        false;
  }

  static Future<bool> requestNotificationPermission() async {
    if (kIsWeb) return false;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iOSImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await iOSImplementation?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final notificationEnabled = await _isAndroidPermissionGranted();

      if (!notificationEnabled) {
        final requestNotificationsPermission =
            await _requestAndroidNotificationsPermission();
        return requestNotificationsPermission;
      }
      return notificationEnabled;
    } else {
      return false;
    }
  }

  static Future<void> showNotification(String title, String body) async {
    if (kIsWeb) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'eventfinder_channel',
          'EventFinder Notifications',
          channelDescription: 'EventFinder app notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
    print('DEBUG: Instant notification shown - $title: $body');
  }

  static Future<void> testNotification() async {
    await showNotification(
      'Test Notification',
      'Ini adalah test notifikasi dari EventFinder!',
    );
  }

  static tz.TZDateTime _nextInstanceOfNineAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      9,
      0,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<void> scheduleDailyReminder() async {
    if (kIsWeb) return;

    await configureLocalTimeZone();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminder',
          channelDescription: 'Daily event reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    final tz.TZDateTime scheduledDate = _nextInstanceOfNineAM();
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      _dailyNotificationId,
      '🎉 Event Reminder!',
      'Jangan lupa cek event menarik hari ini di EventFinder!',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.inexact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelDailyReminder() async {
    if (kIsWeb) return;
    await _flutterLocalNotificationsPlugin.cancel(_dailyNotificationId);
  }

  static Future<List<PendingNotificationRequest>>
  pendingNotificationRequests() async {
    if (kIsWeb) return [];
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pendingNotificationRequests;
  }

  static Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<void> scheduleEventReminder(
    String eventId,
    String eventName,
    DateTime eventDateTime,
  ) async {
    if (kIsWeb) return;

    try {
      await configureLocalTimeZone();

      // Convert DateTime biasa ke TZDateTime dengan timezone lokal
      final tz.TZDateTime eventTZDateTime = tz.TZDateTime.from(
        eventDateTime,
        tz.local,
      );

      // Notifikasi 1 jam (60 menit) sebelum event dimulai
      final tz.TZDateTime scheduledDate = eventTZDateTime.subtract(
        const Duration(hours: 1),
      );
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

      // Debug print
      print('DEBUG NOTIF: Event ID: $eventId');
      print('DEBUG NOTIF: Event Name: $eventName');
      print('DEBUG NOTIF: Event DateTime: $eventDateTime');
      print('DEBUG NOTIF: Event TZ DateTime: $eventTZDateTime');
      print('DEBUG NOTIF: Scheduled Date: $scheduledDate');
      print('DEBUG NOTIF: Now: $now');
      print(
        'DEBUG NOTIF: Is scheduled before now? ${scheduledDate.isBefore(now)}',
      );

      // Jika waktu notifikasi sudah lewat, skip
      if (scheduledDate.isBefore(now)) {
        print('DEBUG NOTIF: Skipped - waktu sudah lewat');
        return;
      }

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'event_reminder_channel',
            'Event Reminders',
            channelDescription: 'Reminders for favorite events',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      // Gunakan eventId.hashCode sebagai notification ID agar unik per event
      final notificationId = eventId.hashCode.abs();
      print('DEBUG NOTIF: Notification ID: $notificationId');

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        '⏰ Event favorit akan dimulai!',
        '$eventName akan dimulai dalam 1 jam!',
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('DEBUG NOTIF: Successfully scheduled notification');
    } catch (e) {
      print('ERROR NOTIF: Failed to schedule notification - $e');
      rethrow;
    }
  }

  static Future<void> cancelEventReminder(String eventId) async {
    if (kIsWeb) return;
    final notificationId = eventId.hashCode.abs();
    print('DEBUG NOTIF: Cancelling notification ID: $notificationId');
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  static Future<void> scheduleAllFavoriteEventReminders(
    List<dynamic> favoriteEvents,
  ) async {
    if (kIsWeb) return;

    await configureLocalTimeZone();

    print(
      'DEBUG SYNC: Starting to sync ${favoriteEvents.length} favorite events',
    );

    // Cancel semua notifikasi event yang ada
    final pendingNotifications = await pendingNotificationRequests();
    print(
      'DEBUG SYNC: Found ${pendingNotifications.length} pending notifications',
    );

    for (var notification in pendingNotifications) {
      if (notification.id != _dailyNotificationId) {
        await _flutterLocalNotificationsPlugin.cancel(notification.id);
        print('DEBUG SYNC: Cancelled notification ID: ${notification.id}');
      }
    }

    // Jadwalkan notifikasi untuk semua event favorit
    int successCount = 0;
    int skipCount = 0;
    int errorCount = 0;

    for (var event in favoriteEvents) {
      try {
        final String eventId = event.id;
        final String eventName = event.name;
        final String localDate = event.localDate;
        final String localTime = event.localTime;

        print('DEBUG SYNC: Processing event: $eventName');

        // Format datetime string dengan robust
        String dateTimeString = '$localDate $localTime';
        if (!localTime.contains(':00:00') && localTime.split(':').length == 2) {
          dateTimeString = '$localDate $localTime:00';
        }

        // Parse datetime dari event
        final DateTime eventDateTime = DateTime.parse(dateTimeString);
        print('DEBUG SYNC: Parsed datetime: $eventDateTime');

        // Jadwalkan notifikasi 1 jam sebelum event
        await scheduleEventReminder(eventId, eventName, eventDateTime);
        successCount++;
      } catch (e) {
        print('ERROR SYNC: Failed to schedule for event - $e');
        errorCount++;
        // Skip event yang gagal di-parse
        continue;
      }
    }

    print(
      'DEBUG SYNC: Completed - Success: $successCount, Skip: $skipCount, Error: $errorCount',
    );

    // Show pending notifications after sync
    final afterSync = await pendingNotificationRequests();
    print(
      'DEBUG SYNC: Total pending notifications after sync: ${afterSync.length}',
    );
  }
}
