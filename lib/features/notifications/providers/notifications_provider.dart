// lib/providers/notification_provider.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/features/notifications/models/notification_model.dart';
import 'package:task_companion/features/authentication/services/auth_services.dart';

final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final supabaseClient = ref.watch(supabaseProvider);
  final userId = supabaseClient.auth.currentUser?.id;

  if (userId == null) return Stream.value([]);

  return supabaseClient
      .from('notification_details_view')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .map(
        (data) => data.map((json) => NotificationModel.fromJson(json)).toList(),
      );
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  return notificationsAsync.maybeWhen(
    data: (list) => list.where((n) => n.seenAt != null).length,
    orElse: () => 0,
  );
});

final notificationActionsProvider =
    AsyncNotifierProvider<NotificationActionsNotifier, void>(() {
      return NotificationActionsNotifier();
    });

class NotificationActionsNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> markAsRead(String id) async {
    final supabaseClient = ref.read(supabaseProvider);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await supabaseClient
          .from('notifications')
          .update({'seen_at': DateTime.now()})
          .eq('id', id);
    });
  }

  Future<void> markAllAsRead() async {
    final supabaseClient = ref.read(supabaseProvider);
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await supabaseClient
          .from('notifications')
          .update({'is_read': true})
          .eq('notified_id', userId);
    });
  }
}
