import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/providers/tasks_provider.dart';
import 'package:task_companion/ui/widgets/on_error.dart';
import 'package:task_companion/ui/widgets/on_loading.dart';
import 'package:task_companion/ui/widgets/tasks/task_message_list.dart';

class TaskConversationPage extends ConsumerWidget {
  final String taskId;
  final String projectId;
  const TaskConversationPage({
    super.key,
    required this.taskId,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .read(taskDetailsProvider({"projectId": projectId, "taskId": taskId}))
        .when(
          error: (e, _) => OnError(e: e),
          loading: () => const OnLoading(),
          data: (task) {
            return Scaffold(
              appBar: AppBar(
                title: ListTile(
                  onTap: () => context.goNamed("task_details"),
                  title: Text(
                    task!.title,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {},
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(child: TaskMessageList()),
                  _buildMessageInput(),
                ],
              ),
            );
          },
        );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(hintText: "Message..."),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () {
              //add send message logic here
            },
          ),
        ],
      ),
    );
  }
}
