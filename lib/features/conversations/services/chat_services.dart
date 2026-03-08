import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/core/log/logger.dart';
import 'package:task_companion/features/conversations/models/message_model.dart';

class ChatServices {
  final supabase = Supabase.instance.client;

  Future<List<Message>> getConversationMessages({
    required String conversationId,
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      appLogger.i("Fetching conversation messages for $conversationId");

      final response = await supabase
          .from('message_view')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map((m) => Message.fromJson(m)).toList();
    } catch (e, st) {
      appLogger.e("Error fetching messages", error: e, stackTrace: st);
      return [];
    }
  }

  Future<bool> sendMessage(Map<String, dynamic> message) async {
    try {
      final response = await supabase
          .from('messages')
          .insert(message)
          .select()
          .maybeSingle();

      return response != null;
    } catch (e, st) {
      appLogger.e("Error sending message", error: e, stackTrace: st);
      return false;
    }
  }
}

final chatServicesProvider = Provider<ChatServices>((ref) {
  return ChatServices();
});
