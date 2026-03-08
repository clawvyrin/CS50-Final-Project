import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/features/conversations/providers/chat_provider.dart';

class ConversationsIcon extends ConsumerWidget {
  const ConversationsIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadConversationsCountProvider);
    return Stack(
      children: [
        PlatformIconButton(
          onPressed: () => context.goNamed('conversations'),
          icon: Icon(Icons.messenger),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: CircleAvatar(
              radius: 8,
              backgroundColor: Colors.red,
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }
}
