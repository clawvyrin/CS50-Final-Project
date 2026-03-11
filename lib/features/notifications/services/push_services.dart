import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/core/log/logger.dart';
import 'package:task_companion/core/utils/string_extensions.dart';
import 'package:task_companion/features/home/models/enums.dart';
import 'package:task_companion/features/notifications/models/notification_model.dart';
import 'package:task_companion/features/notifications/providers/notifications_provider.dart';
import 'package:task_companion/features/notifications/widgets/notification_action_dialog.dart';

Future<void> handleBackGroundMessage(RemoteMessage message) async {
  try {
    appLogger.i(message.data.toString());
    await PushNotificationService().onNotification(message);
  } catch (e, st) {
    appLogger.e(
      "Couldn't handle background messaging because",
      error: e,
      time: DateTime.now().toUtc(),
      stackTrace: st,
    );
  }
}

class PushNotificationService {
  static final navigatorKey = GlobalKey<NavigatorState>();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  final androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.max,
  );

  final _localNotifs = FlutterLocalNotificationsPlugin();

  Future<void> initialize(String? id) async {
    NotificationSettings settings = await _fcm.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _fcm.getToken();
      if (token != null) {
        await _saveTokenToDatabase(token, id);
      }
    }

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifs.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          final notif = NotificationModel.fromJson(data);

          _handleGlobalNavigation(notif);
        }
      },
    );

    await _localNotifs
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    FirebaseMessaging.onBackgroundMessage(handleBackGroundMessage);
    _fcm.onTokenRefresh.listen((t) async {
      await _saveTokenToDatabase(t, id);
    });
  }

  void _handleGlobalNavigation(NotificationModel notif) {
    final data = notif.metaData;

    final router = GoRouter.of(navigatorKey.currentContext!);

    if (notif.type == 'task_assignment' || notif.type == 'report_pending') {
      router.pushNamed(
        'task_details',
        pathParameters: {
          'projectId': data!['project_id'],
          'taskId': data['task_id'],
        },
      );
    } else {
      router.pushNamed('notifications');
    }
  }

  Future onUserLoggedIn(WidgetRef ref) async {
    try {
      final context = navigatorKey.currentContext;
      if (context == null) return;

      await _fcm.getInitialMessage().then((message) async {
        if (context.mounted && message != null) {
          onNotificationClicked(ref, NotificationModel.fromJson(message.data));
        }
      });

      FirebaseMessaging.onMessage.listen((message) async {
        if (context.mounted) await onNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) async {
        if (context.mounted) {
          onNotificationClicked(ref, NotificationModel.fromJson(message.data));
        }
      });
    } catch (e, st) {
      appLogger.e(
        "Couldn't initialize firebase messaging because",
        error: e,
        time: DateTime.now().toUtc(),
        stackTrace: st,
      );
    }
  }

  Future<void> onNotification(RemoteMessage message) async {
    if (message.notification == null) return;

    final notification = message.notification;
    if (notification == null) return;

    final notifId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _localNotifs.show(
      id: notifId,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          androidChannel.id,
          androidChannel.name,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void onNotificationClicked(WidgetRef ref, NotificationModel notif) {
    ref.read(notificationActionsProvider.notifier).markAsRead(notif.id);

    final router = GoRouter.of(navigatorKey.currentContext!);

    final data = notif.metaData;

    switch (notif.type) {
      case 'report_pending':
      case 'task_assignment':
        router.pushNamed(
          'task_details',
          pathParameters: {
            'projectId': data!['project_id'],
            'taskId': data['task_id'],
          },
        );
        break;

      case 'collaboration_request':
      case 'project_collaboration_request':
        if (notif.status == NotificationStatus.pending) {
          showDialog(
            context: navigatorKey.currentContext!,
            builder: (context) => NotificationActionDialog(
              title: notif.type.replaceAll('_', ' ').capitalize(),
              content: "Accept invitation from ${notif.notifier.displayName} ?",
              onAction: (accepted) => ref
                  .read(notificationActionsProvider.notifier)
                  .handleRequest(notif, accepted),
            ),
          );
        } else {
          router.pushNamed(
            'user_profile',
            pathParameters: {'userId': notif.notifier.id},
          );
        }
        break;

      default:
        debugPrint("Type de notification non géré : ${notif.type}");
    }
  }

  Future<void> _saveTokenToDatabase(String token, String? id) async {
    if (id == null) return;

    await _supabaseClient.from("notification_tokens").upsert({
      "user_id": id,
      "token": token,
      "platform": Platform.isIOS ? "ios" : "android",
    }, onConflict: 'token');
  }
}
