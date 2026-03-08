import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/features/conversations/models/message_model.dart';
import 'package:task_companion/features/conversations/services/chat_services.dart';

final taskChatMessagesProvider =
    AsyncNotifierProvider.family<TaskChatNotifier, List<Message>, String>((
      conversationId,
    ) {
      return TaskChatNotifier(conversationId: conversationId);
    });

final chatServicesProvider = Provider<ChatServices>((ref) {
  return ChatServices();
});

class TaskChatNotifier extends AsyncNotifier<List<Message>> {
  final String conversationId;
  TaskChatNotifier({required this.conversationId});

  static const int _pageSize = 20;
  bool _hasMore = true;

  @override
  FutureOr<List<Message>> build() async {
    _hasMore = true;
    return await _fetchFromService(offset: 0);
  }

  Future<List<Message>> _fetchFromService({required int offset}) async {
    return await ref
        .read(chatServicesProvider)
        .getTaskConversationMessages(
          conversationId: conversationId,
          offset: offset,
          limit: _pageSize,
        );
  }

  Future<void> loadMore() async {
    if (state.isLoading || !_hasMore) return;

    final currentMessages = state.value ?? [];
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final moreMessages = await ref
          .read(chatServicesProvider)
          .getTaskConversationMessages(offset: currentMessages.length);
      return [...currentMessages, ...moreMessages];
    });
  }

  void addLiveMessage(Message message) {
    state = AsyncValue.data([message, ...state.value ?? []]);
  }
}
