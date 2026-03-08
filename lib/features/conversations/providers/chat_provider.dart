import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/core/log/logger.dart';
import 'package:task_companion/features/authentication/services/auth_services.dart';
import 'package:task_companion/features/conversations/models/conversation_model.dart';
import 'package:task_companion/features/conversations/models/message_model.dart';
import 'package:task_companion/features/conversations/services/chat_services.dart';

final inboxProvider = StreamProvider<List<Conversation>>((ref) {
  final supabase = ref.watch(supabaseProvider);

  return supabase
      .from('conversation_view')
      .stream(primaryKey: ['id'])
      .order('updated_at', ascending: false)
      .map((data) => data.map((json) => Conversation.fromJson(json)).toList());
});

final unreadConversationsCountProvider = Provider<int>((ref) {
  final inboxAsync = ref.watch(inboxProvider);

  return inboxAsync.maybeWhen(
    data: (conversations) => conversations.where((conv) {
      if (conv.lastMessage == null) return false;

      final myParticipant = conv.participants
          .where((p) => p.user.id == AuthServices.id)
          .firstOrNull;

      if (myParticipant == null) return false;

      final lastSeen = myParticipant.lastSeenAt;
      if (lastSeen == null) return true;

      return lastSeen.isBefore(conv.lastMessage!.sentAt);
    }).length,
    orElse: () => 0,
  );
});

final messagesProvider =
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
  bool get hasMore => _hasMore;
  RealtimeChannel? _subscription;

  @override
  FutureOr<List<Message>> build() async {
    ref.onDispose(() {
      _subscription?.unsubscribe();
      appLogger.i("Unsubscribed from chat: $conversationId");
    });

    final initialMessages = await _fetchFromService(offset: 0);
    _hasMore = true;

    _listenToNewMessages();

    return initialMessages;
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

  void _listenToNewMessages() {
    _subscription?.unsubscribe();
    _subscription = ref
        .read(supabaseProvider)
        .channel('public:messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: "conversation_id",
            value: conversationId,
          ),
          callback: (payload) async {
            final newMessage = await getMessageView(payload.newRecord["id"]);
            final current = state.value ?? [];
            if (!current.any((m) => m.id == newMessage!.id) &&
                newMessage != null) {
              state = AsyncValue.data([newMessage, ...current]);
            }
          },
        )
        .subscribe();
  }

  Future<Message?> getMessageView(String id) async {
    try {
      final response = await ref
          .read(supabaseProvider)
          .from('message_view')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Message.fromJson(response);
    } catch (e, st) {
      appLogger.e(
        "Erreur getMessageView",
        error: e,
        stackTrace: st,
        time: DateTime.now(),
      );
      return null;
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !_hasMore) return;

    final currentMessages = state.value ?? [];
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final moreMessages = await ref
          .read(chatServicesProvider)
          .getConversationMessages(
            offset: currentMessages.length,
            conversationId: conversationId,
            limit: _pageSize,
          );
      return [...currentMessages, ...moreMessages];
    });
  }

  void addLiveMessage(Message message) {
    state = AsyncValue.data([message, ...state.value ?? []]);
  }
}
