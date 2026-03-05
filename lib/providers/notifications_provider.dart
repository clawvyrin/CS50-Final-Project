// lib/providers/notification_provider.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/models/notification_model.dart';
import 'package:task_companion/services/auth_services.dart';

final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final supabase = ref.watch(
    supabaseProvider,
  ); // On suppose que c'est un simple Provider
  final userId = supabase.value!.auth.currentUser?.id;

  if (userId == null) return Stream.value([]);

  return supabase.value!
      .from('notifications')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .map((data) {
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      });
});

// Provider utilitaire pour compter les notifications non lues
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
    final supabase = ref.read(supabaseProvider);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await supabase.value!
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);
    });
  }

  Future<void> markAllAsRead() async {
    final supabase = ref.read(supabaseProvider);
    final userId = supabase.value!.auth.currentUser?.id;
    if (userId == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await supabase.value!
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId);
    });
  }
}
