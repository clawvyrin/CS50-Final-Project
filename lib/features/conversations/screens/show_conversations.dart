import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/features/conversations/providers/chat_provider.dart';
import 'package:task_companion/features/home/widgets/helpers/on_error.dart';
import 'package:task_companion/features/home/widgets/helpers/on_loading.dart';

class ShowConversations extends ConsumerWidget {
  const ShowConversations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .read(inboxProvider)
        .when(
          data: (conversations) {
            return Scaffold(
              appBar: AppBar(title: Text("Conversations")),
              body: ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  return ListTile(
                    title: Text(conversation.title),
                    subtitle: Text(conversation.lastMessage!.sentAt.toString()),
                    trailing: CircleAvatar(
                      backgroundColor: conversation.lastMessage!.seenAt != null
                          ? Colors.transparent
                          : Colors.blue,
                    ),
                    onTap: () {
                      context.goNamed(
                        "conversation",
                        pathParameters: {"conversationId": conversation.id},
                      );
                    },
                  );
                },
              ),
            );
          },
          error: (e, _) => OnError(e: e),
          loading: () => OnLoading(),
        );
  }
}
