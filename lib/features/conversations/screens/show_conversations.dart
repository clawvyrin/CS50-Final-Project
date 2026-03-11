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
    final inboxAsync = ref.watch(inboxProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Conversations")),
      body: inboxAsync.when(
        data: (list) => list.isEmpty
            ? const Center(child: Text("No conversations"))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final conversation = list[index];
                  bool isSeen = conversation.lastMessage?.seenAt != null;
                  return ListTile(
                    // leading: ProfilePicture(
                    //   avatarUrl: conversation.participants
                    //       .where((p) => p.user.id != AuthServices.id!)
                    //       .first
                    //       .user
                    //       .avatarUrl!,
                    // ),
                    title: Text(
                      conversation.title,
                      style: TextStyle(
                        fontWeight: isSeen
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      conversation.lastMessage?.sentAt.toString() ?? '',
                    ),
                    trailing: isSeen != false
                        ? const Icon(Icons.circle, color: Colors.blue, size: 12)
                        : null,
                    onTap: () {
                      context.goNamed(
                        "conversation",
                        pathParameters: {"conversationId": conversation.id},
                      );
                    },
                  );
                },
              ),
        loading: () => OnLoading(),
        error: (e, _) => OnError(e: e),
      ),
    );
  }
}
