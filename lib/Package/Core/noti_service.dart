import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotiService {
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Initialize Awesome Notifications only
  Future<void> initNotification() async {
    if (_isInitialized) return;

    // Initialize Awesome Notifications
    await AwesomeNotifications().initialize(
      null, // null uses the default app icon
      [
        NotificationChannel(
          channelKey: 'basic',
          channelName: 'Basic Notifications',
          channelDescription: 'Notification channel for basic instant notifications',
          defaultColor: Colors.teal,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'scheduled',
          channelName: 'Scheduled Notifications',
          channelDescription: 'Notification channel for scheduled notifications',
          defaultColor: Colors.blue,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'reminder',
          channelName: 'Reminder Notifications',
          channelDescription: 'Notification channel for reminders',
          defaultColor: Colors.orange,
          ledColor: Colors.orange,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
      ],
      debug: kDebugMode, // Only debug in debug mode
    );

    // Request notification permissions
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    _isInitialized = true;
  }

  // Show immediate notification
  Future<void> showNotification({
    int? id,
    required String title,
    required String body,
    Map<String, String>? payload,
    String channelKey = 'basic',
    NotificationLayout layout = NotificationLayout.Default,
    String? bigPicture,
    String? largeIcon,
    bool autoDismissible = true,
    Color? color,
    NotificationCategory? category,
  }) async {
    // Make sure the service is initialized
    if (!_isInitialized) {
      await initNotification();
    }

    final notificationId = id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: channelKey,
        title: title,
        body: body,
        payload: payload,
        notificationLayout: layout,
        bigPicture: bigPicture,
        largeIcon: largeIcon,
        autoDismissible: autoDismissible,
        color: color,
        category: category,
      ),
    );

    if (kDebugMode) {
      print("Immediate notification #$notificationId shown");
    }
  }

  // Schedule notification for specific DateTime
  Future<void> scheduleNotification({
    int? id,
    required DateTime scheduledDate,
    required String title,
    required String body,
    Map<String, String>? payload,
    bool repeats = false,
    String channelKey = 'scheduled',
    NotificationLayout layout = NotificationLayout.Default,
    String? bigPicture,
    String? largeIcon,
    bool autoDismissible = true,
    Color? color,
  }) async {
    // Make sure the service is initialized
    if (!_isInitialized) {
      await initNotification();
    }

    final notificationId = id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);
    String timeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: channelKey,
        title: title,
        body: body,
        payload: payload,
        notificationLayout: layout,
        bigPicture: bigPicture,
        largeIcon: largeIcon,
        autoDismissible: autoDismissible,
        color: color,
      ),
      schedule: NotificationCalendar(
        allowWhileIdle: true,
        repeats: repeats,
        year: scheduledDate.year,
        month: scheduledDate.month,
        day: scheduledDate.day,
        hour: scheduledDate.hour,
        minute: scheduledDate.minute,
        second: scheduledDate.second,
        millisecond: 0,
        timeZone: timeZone,
      ),
    );

    if (kDebugMode) {
      print("Notification #$notificationId scheduled at ${scheduledDate.toString()}");
    }
  }


  Future<void> scheduleAtTime({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    int second = 0,
    bool repeatsDaily = false,
    Map<String, String>? payload,
    String channelKey = 'scheduled',
  }) async {
    if (!_isInitialized) {
      await initNotification();
    }

    final notificationId = id ;

    // Calculate the scheduled date
    DateTime now = DateTime.now();
    DateTime scheduledDate = DateTime(now.year, now.month, now.day, hour, minute, second);

    // If the time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    String timeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: channelKey,
        title: title,
        body: body,
        payload: payload,
      ),
      schedule: NotificationCalendar(
        allowWhileIdle: true,
        repeats: repeatsDaily,
        hour: hour,
        minute: minute,
        second: second,
        millisecond: 0,
        timeZone: timeZone,
      ),
    );

    if (kDebugMode) {
      print("Notification #$notificationId scheduled at $hour:$minute:$second ${repeatsDaily ? '(Daily)' : '(Once)'}");
    }
  }

  // Schedule notification after a specific duration from now
  Future<void> scheduleAfterDuration({
    int? id,
    required Duration duration,
    required String title,
    required String body,
    Map<String, String>? payload,
    String channelKey = 'scheduled',
  }) async {
    if (!_isInitialized) {
      await initNotification();
    }

    final notificationId = id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);
    DateTime scheduledDate = DateTime.now().add(duration);

    await scheduleNotification(
      id: notificationId,
      scheduledDate: scheduledDate,
      title: title,
      body: body,
      payload: payload,
      channelKey: channelKey,
    );
  }


  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
    if (kDebugMode) {
      print("Notification #$id cancelled");
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
    if (kDebugMode) {
      print("All notifications cancelled");
    }
  }

  // Get all scheduled notifications
  Future<List<NotificationModel>> getScheduledNotifications() async {
    return await AwesomeNotifications().listScheduledNotifications();
  }

  // Check if notification is allowed
  Future<bool> isNotificationAllowed() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  // Request permission
  Future<void> requestPermission() async {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }
  Future<int> generateId() async {
    List<NotificationModel> scheduledNotifications = await getScheduledNotifications();

    if (scheduledNotifications.isEmpty) {
      return 1;
    }

    // Get all IDs and find the maximum
    List<int> existingIds = scheduledNotifications
        .map((notification) => notification.content?.id ?? 0)
        .toList();

    int maxId = existingIds.reduce((max, id) => id > max ? id : max);
    return maxId + 1;
  }

  // Alternative: Get all used IDs
  Future<List<int>> getAllNotificationIds() async {
    List<NotificationModel> scheduledNotifications = await getScheduledNotifications();

    return scheduledNotifications
        .map((notification) => notification.content?.id ?? 0)
        .where((id) => id > 0)
        .toList();
  }
}