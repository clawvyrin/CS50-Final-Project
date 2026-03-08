import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/core/log/logger.dart';
import 'package:task_companion/features/conversations/models/conversation_model.dart';
import 'package:task_companion/features/conversations/models/message_model.dart';

class ChatServices {
  final supabase = Supabase.instance.client;

  Future<List<Message>> getConversationMessages({
    int offset = 0,
    String conversationId = "",
    int limit = 20,
    bool hasMore = true,
  }) async {
    try {
      appLogger.i(" Gettig task onversation messages");

      final response = await supabase.rpc(
        'get_task_conversation_messages',
        params: {'c_id': conversationId, 'offset': offset, 'limit': limit},
      );

      final List<Message> newMessages = (response as List)
          .map((m) => Message.fromJson(m))
          .toList();

      if (newMessages.length < limit) hasMore = false;
      return newMessages;
    } catch (e, st) {
      appLogger.e(
        "Email fetching task conversation messages Error",
        error: e,
        stackTrace: st,
        time: DateTime.now().toUtc(),
      );
      return [];
    }
  }

  Future<List<Conversation>> getConversationsDetails(
    List<String> conversationId,
  ) async {
    try {
      appLogger.i(" Gettig conversation details");

      final response = await supabase.rpc(
        'get_conversations_details',
        params: {'c_ids': conversationId},
      );

      final List<Conversation> newConversations = (response as List)
          .map((m) => Conversation.fromJson(m))
          .toList();

      return newConversations;
    } catch (e, st) {
      appLogger.e(
        "Email fetching task conversation",
        error: e,
        stackTrace: st,
        time: DateTime.now().toUtc(),
      );
      return [];
    }
  }
}

final chatServicesProvider = Provider<ChatServices>((ref) {
  return ChatServices();
});
