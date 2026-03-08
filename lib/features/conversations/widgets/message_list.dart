import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/features/conversations/models/message_model.dart';
import 'package:task_companion/features/conversations/providers/chat_provider.dart';
import 'package:task_companion/features/authentication/services/auth_services.dart';
import 'package:task_companion/features/tasks/widgets/task_chat_widgets.dart';

class MessageList extends ConsumerStatefulWidget {
  final String conversationId;
  const MessageList({super.key, required this.conversationId});

  @override
  ConsumerState<MessageList> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _setupRealtime();
  }

  RealtimeChannel messageSubscription() {
    return ref
        .read(supabaseProvider)
        .channel('public:messages:conversation_id=eq.${widget.conversationId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'task_messages',
          callback: (payload) {
            final newMessage = Message.fromJson(payload.newRecord);
            ref
                .read(taskChatMessagesProvider(widget.conversationId).notifier)
                .addLiveMessage(newMessage);
          },
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(taskChatMessagesProvider(widget.conversationId).notifier)
          .loadMore();
    }
  }

  void _setupRealtime() => messageSubscription().subscribe();

  Widget keyboard() {
    return Container();
  }

  @override
  void dispose() {
    messageSubscription().unsubscribe();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(
      taskChatMessagesProvider(widget.conversationId),
    );

    return chatState.when(
      data: (messages) => ListView.builder(
        shrinkWrap: true,
        controller: _scrollController,
        reverse: true,
        itemCount: messages.length + (chatState.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == messages.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final msg = messages[index];
          return _buildMessageTile(msg);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Erreur : $e")),
    );
  }

  Widget _buildMessageTile(Message msg) {
    if (msg.metaData!["type"] == 'report_notification') {
      return ReportNotificationBubble(report: msg.metaData!["report"]);
    }

    return ChatBubble(message: msg.content, isMe: msg.isMe);
  }
}
