import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/features/notifications/models/notification_model.dart';
import 'package:task_companion/features/notifications/providers/notifications_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: notificationsAsync.when(
        data: (list) => list.isEmpty
            ? const Center(child: Text("Aucune notification"))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final notif = list[index];
                  return ListTile(
                    leading: _buildIcon(notif.type),
                    title: Text(
                      notif.type,
                      style: TextStyle(
                        fontWeight: notif.seenAt != null
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(notif.type),
                    trailing: notif.seenAt != null
                        ? const Icon(Icons.circle, color: Colors.blue, size: 12)
                        : null,
                    onTap: () => _handleNotificationClick(context, ref, notif),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erreur: $e")),
      ),
    );
  }

  void _handleNotificationClick(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notif,
  ) {
    ref.read(notificationActionsProvider.notifier).markAsRead(notif.id);

    final data = notif.metaData;
    switch (notif.type) {
      case 'report_pending':
        context.goNamed(
          'task_details',
          pathParameters: {
            'projectId': data!['project_id'],
            'taskId': data['task_id'],
          },
        );
        break;
      case 'new_message':
        context.goNamed(
          'task_conversation',
          pathParameters: {
            'projectId': data!['project_id'],
            'taskId': data['task_id'],
          },
        );
        break;
    }
  }

  Widget _buildIcon(String type) {
    switch (type) {
      case 'report_pending':
        return const Icon(Icons.assignment_late, color: Colors.orange);
      case 'new_message':
        return const Icon(Icons.chat_bubble, color: Colors.blue);
      default:
        return const Icon(Icons.notifications);
    }
  }
}
