import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:seiiarty_package/Package/Core/shared_preference.dart';
import 'StoredProcedures/user.dart';
import 'app_theme.dart';
import 'general_const.dart';
import 'general_function.dart';

class FirebaseService {
  final _firebaseMessaging = FirebaseMessaging.instance;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> initFCM({int maxRetries = 5}) async {
    await _firebaseMessaging.requestPermission();
    await _initializeAwesomeNotifications();

    // Retry logic for getting FCM token
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        if (kDebugMode) {
          print('${AppTheme.colorCyan} FCM Token attempt $attempt/$maxRetries... ${AppTheme.colorReset}');
        }

        final token = await _firebaseMessaging.getToken();

        if (token != null) {
          _fcmToken = token;
          GeneralConstant.firebaseToken = token;

          if (kDebugMode) {
            print('${AppTheme.colorCyan} FCM Token: $token ${AppTheme.colorReset}');
            print('${AppTheme.colorCyan} ${GeneralConstant.firebaseToken} ${AppTheme.colorReset}');
          }

          SharedPreference.sharedPreferencesSetString(
            SharedPreference.firebaseTokenKey,
            GeneralConstant.firebaseToken,
          );

          // Token obtained successfully, set up listeners and exit
          _setupListeners();
          return;
        }

        if (kDebugMode) {
          print('${AppTheme.colorCyan} FCM token was null on attempt $attempt, retrying... ${AppTheme.colorReset}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('${AppTheme.colorCyan} FCM attempt $attempt/$maxRetries failed: $e ${AppTheme.colorReset}');
        }
      }

      if (attempt < maxRetries) {
        // Exponential backoff: 2s, 4s, 6s, 8s
        await Future.delayed(Duration(seconds: 2 * attempt));
      }
    }

    // All retries exhausted — throw so main.dart can show the retry screen
    throw Exception(
      'Failed to obtain FCM token after $maxRetries attempts. '
          'Check internet connection and Google Play Services.',
    );
  }

  void _setupListeners() {
    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      _updateTokenInDatabase(newToken);
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      if(GeneralFunctions.ifMapOrNull(GeneralConstant.userLogged["ID"] ,whenEmpty: null)!= null){
        if (kDebugMode) {
          print('Token refreshed: $newToken');
        }
        SpUser.update(fireBaseToken: GeneralConstant.firebaseToken);
        SharedPreference.sharedPreferencesSetString(
          SharedPreference.firebaseTokenKey,
          GeneralConstant.firebaseToken,
        );
      }

    });

    FirebaseMessaging.onMessageOpenedApp.listen(handleNotifications);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  // Initialize awesome notifications
  Future<void> _initializeAwesomeNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic notifications',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'scheduled_channel',
          channelName: 'Scheduled notifications',
          channelDescription: 'Notification channel for scheduled notifications',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
      ],
    );

    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onNotificationTapped,
      onNotificationCreatedMethod: _onNotificationCreated,
      onNotificationDisplayedMethod: _onNotificationDisplayed,
      onDismissActionReceivedMethod: _onNotificationDismissed,
    );
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Foreground message received: ${message.notification?.title}');
    }

    showNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      payload: message.data.map((key, value) => MapEntry(key, value?.toString())),
    );

    handleNotifications(message);
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationCreated(ReceivedNotification receivedNotification) async {
    if (kDebugMode) {
      print('Notification created: ${receivedNotification.title}');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationDisplayed(ReceivedNotification receivedNotification) async {
    if (kDebugMode) {
      print('Notification displayed: ${receivedNotification.title}');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationDismissed(ReceivedAction receivedAction) async {
    if (kDebugMode) {
      print('Notification dismissed: ${receivedAction.title}');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationTapped(ReceivedAction receivedAction) async {
    if (kDebugMode) {
      print('Notification tapped: ${receivedAction.title}');
      print('Payload: ${receivedAction.payload}');
    }

    if (receivedAction.payload != null) {
      // NavigationService.navigateTo(receivedAction.payload!['route']);
    }
  }

  Future<void> _updateTokenInDatabase(String newToken) async {
    if (GeneralConstant.userLogged != null) {
      await SpUser.update(fireBaseToken: newToken);
      GeneralConstant.userLogged = await SpUser.get(id: GeneralConstant.userLogged['ID']);
    } else {
      GeneralConstant.firebaseToken = newToken;
    }
    if (kDebugMode) {
      print('Token updated in database: $newToken');
    }
  }

  void handleNotifications(RemoteMessage? message) async {
    if (message == null) return;

    if (kDebugMode) {
      print('Notification Title: ${message.notification?.title}');
      print('Notification Body: ${message.notification?.body}');
    }
  }

  Future initPushNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleNotifications);
  }

  Future<void> showNotification({
    required String title,
    required String body,
    Map<String, String?>? payload,
    int id = 0,
    String? imageUrl,
    String? largeIcon,
    NotificationLayout layout = NotificationLayout.Default,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'basic_channel',
        title: title,
        body: body,
        payload: payload,
        notificationLayout: layout,
        bigPicture: imageUrl,
        largeIcon: largeIcon,
        wakeUpScreen: true,
        category: NotificationCategory.Message,
      ),
    );
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    Map<String, String?>? payload,
    int id = 0,
    String? imageUrl,
    bool repeats = false,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'scheduled_channel',
        title: title,
        body: body,
        payload: payload,
        bigPicture: imageUrl,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationCalendar(
        year: scheduledDate.year,
        month: scheduledDate.month,
        day: scheduledDate.day,
        hour: scheduledDate.hour,
        minute: scheduledDate.minute,
        second: scheduledDate.second,
        repeats: repeats,
      ),
    );
  }

  Future<void> showNotificationWithActions({
    required String title,
    required String body,
    required List<NotificationActionButton> actionButtons,
    Map<String, String?>? payload,
    int id = 0,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'basic_channel',
        title: title,
        body: body,
        payload: payload,
        wakeUpScreen: true,
        category: NotificationCategory.Message,
      ),
      actionButtons: actionButtons,
    );
  }

  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  Future<void> cancelScheduledNotifications() async {
    await AwesomeNotifications().cancelAllSchedules();
  }

  Future<bool> areNotificationsAllowed() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  Future<bool> requestNotificationPermission() async {
    return await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  Future<List<NotificationModel>> getScheduledNotifications() async {
    return await AwesomeNotifications().listScheduledNotifications();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    if (kDebugMode) print('Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    if (kDebugMode) print('Unsubscribed from topic: $topic');
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Background message: ${message.notification?.title}');
  }

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      channelKey: 'basic_channel',
      title: message.notification?.title ?? 'New Message',
      body: message.notification?.body ?? '',
      payload: message.data.map((key, value) => MapEntry(key, value?.toString())),
      wakeUpScreen: true,
    ),
  );
}