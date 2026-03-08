import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/features/authentication/services/auth_services.dart';
import 'package:task_companion/features/conversations/models/conversation_model.dart';
import 'package:task_companion/features/conversations/models/message_model.dart';
import 'package:task_companion/features/conversations/services/chat_services.dart';

final inboxProvider = StreamProvider<List<Conversation>>((ref) {
  final supabase = ref.watch(supabaseProvider);
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) return Stream.value([]);

  return supabase
      .from('conversation_participants')
      .stream(primaryKey: ['conversation_id', 'user_id'])
      .eq('user_id', userId)
      .order('last_message_at', ascending: false)
      .asyncMap((participants) async {
        if (participants.isEmpty) return [];

        final ids = participants
            .map((p) => p['conversation_id'] as String)
            .toList();

        final response = await supabase
            .from('conversation_details_view')
            .select()
            .filter('id', 'in', ids);

        final mapped = (response as List)
            .map((json) => Conversation.fromJson(json))
            .toList();

        mapped.sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));

        return mapped;
      });
});

final unreadConversationsCountProvider = Provider<int>((ref) {
  final inboxAsync = ref.watch(inboxProvider);
  return inboxAsync.maybeWhen(
    data: (list) =>
        list.where((conv) => conv.lastMessage!.seenAt == null).length,
    orElse: () => 0,
  );
});

final taskChatMessagesProvider =
    AsyncNotifierProvider.family<TaskChatNotifier, List<Message>, String>((
      conversationId,
    ) {
      return TaskChatNotifier(conversationId: conversationId);
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
        .getConversationMessages(
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
          .getConversationMessages(offset: currentMessages.length);
      return [...currentMessages, ...moreMessages];
    });
  }

  void addLiveMessage(Message message) {
    state = AsyncValue.data([message, ...state.value ?? []]);
  }
}
