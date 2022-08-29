import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> downloadingNotification(
    maxProgress, progress, isDownloaded) async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ignore: prefer_const_declarations
  final IOSInitializationSettings initializationSettingsIOS =
      const IOSInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  if (!isDownloaded) {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            "downloading files", "downloading Files Notifications",
            channelDescription: "show to user progress for downloading files",
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.high,
            onlyAlertOnce: true,
            showProgress: true,
            maxProgress: maxProgress,
            progress: progress,
            autoCancel: false);
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      6,
      'Downloading file',
      '',
      platformChannelSpecifics,
    );
  } else {
    flutterLocalNotificationsPlugin.cancel(6);
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      "files",
      "Files Notifications",
      channelDescription: "Inform user files downloaded",
      channelShowBadge: false,
      importance: Importance.max,
      priority: Priority.high,
      onlyAlertOnce: true,
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      Random().nextInt(1000000),
      'File Downloaded',
      '',
      platformChannelSpecifics,
    );
  }
}
