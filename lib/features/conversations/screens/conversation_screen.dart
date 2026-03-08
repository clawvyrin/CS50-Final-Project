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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .read(inboxProvider)
        .when(
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
                      context.goNamed(
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
                          participant: conversation.participants!
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
                  _buildMessageInput(),
                ],
              ),
            );
          },
          error: (e, _) => OnError(e: e),
          loading: () => OnLoading(),
        );
  }
}
