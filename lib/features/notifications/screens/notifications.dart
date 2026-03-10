import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/core/utils/string_extensions.dart';
import 'package:task_companion/features/home/models/enums.dart';
import 'package:task_companion/features/home/widgets/helpers/on_error.dart';
import 'package:task_companion/features/home/widgets/helpers/on_loading.dart';
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
                    onTap: () => _handleNotificationClick(context, ref, notif),
                  );
                },
              ),
        loading: () => OnLoading(),
        error: (e, _) => OnError(e: e),
      ),
    );
  }

  void _showActionDialog(
    BuildContext context, {
    required String title,
    required String content,
    required Function(bool) onAction,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text("Decline", style: TextStyle(color: Colors.red)),
            onPressed: () {
              onAction(false);
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
            onPressed: () {
              onAction(true);
              Navigator.pop(context);
            },
            child: const Text("Accept"),
          ),
        ],
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

  void _handleNotificationClick(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notif,
  ) {
    ref.read(notificationActionsProvider.notifier).markAsRead(notif.id);

    final data = notif.metaData;

    switch (notif.type) {
      case 'report_pending':
      case 'task_assignment':
        context.pushNamed(
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
          _showActionDialog(
            context,
            title: notif.type.replaceAll('_', ' ').capitalize(),
            content: "Accept invitation from ${notif.notifier.displayName} ?",
            onAction: (accepted) => ref
                .read(notificationActionsProvider.notifier)
                .handleRequest(notif, accepted),
          );
        } else {
          context.pushNamed(
            'user_profile',
            pathParameters: {'userId': notif.notifier.id},
          );
        }
        break;

      default:
        debugPrint("Type de notification non géré : ${notif.type}");
    }
  }

  Widget _buildIcon(String type) {
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
