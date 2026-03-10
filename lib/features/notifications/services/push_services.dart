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
import 'package:task_companion/features/authentication/services/auth_services.dart';
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

  Future<void> initialize() async {
    NotificationSettings settings = await _fcm.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _fcm.getToken();
      if (token != null) {
        _saveTokenToDatabase(token);
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
          // On transforme le payload en modèle
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
    _fcm.onTokenRefresh.listen(_saveTokenToDatabase);
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
      final context = navigatorKey.currentContext!;

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

    await _localNotifs.show(
      id: message.data["id"],
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

  void _saveTokenToDatabase(String token) async {
    final userId = AuthServices.id;
    if (userId == null) return;

    await _supabaseClient.from("notification_tokens").upsert({
      "user_id": userId,
      "token": token,
      "platform": Platform.isIOS ? "ios" : "android",
    }, onConflict: 'token');
  }
}
