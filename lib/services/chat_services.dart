import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/core/logger.dart';
import 'package:task_companion/models/message_model.dart';

class ChatServices {
  final supabase = Supabase.instance.client;

  Future<List<Message>> getTaskConversationMessages({
    int offset = 0,
    String conversationId = "",
    int limit = 20,
    bool hasMore = true,
  }) async {
    try {
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
}
