import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/features/home/widgets/helpers/on_error.dart';
import 'package:task_companion/features/home/widgets/helpers/on_loading.dart';
import 'package:task_companion/features/notifications/models/notification_model.dart';
import 'package:task_companion/features/notifications/providers/notifications_provider.dart';
import 'package:task_companion/features/notifications/services/push_services.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: notificationsAsync.when(
        data: (list) => list.isEmpty
            ? const Center(child: Text("No notifications"))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final notif = list[index];
                  return ListTile(
                    leading: _buildIcon(notif.type),
                    title: _getNotificationTitle(notif),
                    subtitle: Text(notif.notifier.displayName),
                    trailing: notif.seenAt == null
                        ? const Icon(Icons.circle, color: Colors.blue, size: 12)
                        : null,
                    onTap: () => PushNotificationService()
                        .onNotificationClicked(context, ref, notif),
                  );
                },
              ),
        loading: () => OnLoading(),
        error: (e, _) => OnError(e: e),
      ),
    );
  }

  Widget _getNotificationTitle(NotificationModel notfication) {
    String title;
    switch (notfication.type) {
      case 'report_pending':
        title = 'Report pending';
      case 'collaboration_request':
        title = 'Collaboration request';
      case 'task_assignment':
        title = 'Task assignment';
      default:
        title = 'Notification';
    }
    return Text(
      title,
      style: TextStyle(
        fontWeight: notfication.seenAt != null
            ? FontWeight.normal
            : FontWeight.bold,
      ),
    );
  }

  Icon _buildIcon(String type) {
    switch (type) {
      case 'report_pending':
        return const Icon(Icons.assignment_late, color: Colors.orange);
      case 'task_assignment':
        return const Icon(Icons.task);
      default:
        return const Icon(Icons.notifications);
    }
  }
}
