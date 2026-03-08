import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';

class ConversationsIcon extends StatelessWidget {
  const ConversationsIcon({super.key});

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      PlatformIconButton(
        onPressed: () => context.goNamed('conversation'),
        icon: Icon(Icons.messenger),
      ),
      Positioned(
        right: 8,
        top: 8,
        child: CircleAvatar(
          radius: 8,
          backgroundColor: Colors.red,
          child: Text('9', style: const TextStyle(fontSize: 10)),
        ),
      ),
    ],
  );
}
