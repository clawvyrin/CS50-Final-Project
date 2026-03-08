import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/features/conversations/models/message_model.dart';
import 'package:task_companion/features/conversations/providers/chat_provider.dart';
import 'package:task_companion/features/home/widgets/helpers/on_error.dart';
import 'package:task_companion/features/home/widgets/helpers/on_loading.dart';
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
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(messagesProvider(widget.conversationId).notifier).loadMore();
    }
  }

  Widget keyboard() {
    return Container();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(messagesProvider(widget.conversationId));

    return chatState.when(
      data: (messages) {
        final hasMore = ref
            .read(messagesProvider(widget.conversationId).notifier)
            .hasMore;

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          itemCount: messages.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == messages.length && hasMore) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildMessageTile(messages[index]);
          },
        );
      },
      loading: () => OnLoading(),
      error: (e, _) => OnError(e: e),
    );
  }

  Widget _buildMessageTile(Message msg) {
    if (msg.metaData!["type"] == 'report_notification') {
      return ReportNotificationBubble(report: msg.metaData!["report"]);
    }

    return ChatBubble(message: msg.content, isMe: msg.isMe);
  }
}
