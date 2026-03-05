import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/models/message_model.dart';
import 'package:task_companion/providers/chat_provider.dart';
import 'package:task_companion/services/auth_services.dart';
import 'package:task_companion/ui/widgets/tasks/task_chat_widgets.dart';

class TaskMessageList extends ConsumerStatefulWidget {
  final String conversationId;
  const TaskMessageList({super.key, required this.conversationId});

  @override
  ConsumerState<TaskMessageList> createState() => _TaskMessageListState();
}

class _TaskMessageListState extends ConsumerState<TaskMessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Activer le realtime ici
    _setupRealtime();
  }

  RealtimeChannel messageSubscription() {
    return ref
        .read(supabaseProvider)
        .value!
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
    // Si le message est lié à un rapport (via metadata ou type)
    if (msg.metaData!["type"] == 'report_notification') {
      return ReportNotificationBubble(
        report: msg.metaData!["report"], // Lien vers le rapport complet
      );
    }

    // Sinon, bulle de chat classique
    return ChatBubble(message: msg.content, isMe: msg.isMe);
  }
}
