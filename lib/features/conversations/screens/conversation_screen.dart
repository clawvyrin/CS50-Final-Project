import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/features/authentication/services/auth_services.dart';
import 'package:task_companion/features/conversations/providers/chat_provider.dart';
import 'package:task_companion/features/conversations/widgets/message_list.dart';
import 'package:task_companion/features/conversations/widgets/participant_alert_dialog.dart';
import 'package:task_companion/features/home/widgets/helpers/on_error.dart';
import 'package:task_companion/features/home/widgets/helpers/on_loading.dart';

class ConversationScreen extends ConsumerWidget {
  final String conversationId;

  const ConversationScreen({super.key, required this.conversationId});

  Widget _buildMessageInput(WidgetRef ref, BuildContext context) {
    TextEditingController messageController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(hintText: "Message..."),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () async {
              final text = messageController.text.trim();
              if (text.isEmpty) return;

              messageController.clear();

              bool success = await ref
                  .read(messagesProvider(conversationId).notifier)
                  .sendMessage(text);

              if (!success && context.mounted) {
                messageController.text = text;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error sending message")),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxAsync = ref.watch(inboxProvider);

    return inboxAsync.when(
      data: (conversations) {
        final conversation = conversations
            .where((conv) => conv.id == conversationId)
            .first;

        return Scaffold(
          appBar: AppBar(
            title: ListTile(
              title: Text(conversation.title),
              onTap: () {
                if (conversation.task != null) {
                  context.pushNamed(
                    "task_details",
                    pathParameters: {
                      "projectId": conversation.task!.project.id,
                      "taskId": conversation.task!.id,
                    },
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => ParticipantAlertDialog(
                      participant: conversation.participants
                          .where((p) => p.user.id != AuthServices.id)
                          .first,
                    ),
                  );
                }
              },
            ),
          ),
          body: Column(
            children: [
              Expanded(child: MessageList(conversationId: conversationId)),
              _buildMessageInput(ref, context),
            ],
          ),
        );
      },
      error: (e, _) => OnError(e: e),
      loading: () => OnLoading(),
    );
  }
}
