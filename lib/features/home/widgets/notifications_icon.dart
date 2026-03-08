import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';

class NotificationsIcon extends StatelessWidget {
  const NotificationsIcon({super.key});

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      PlatformIconButton(
        onPressed: () => context.goNamed('notifications'),
        icon: Icon(Icons.notifications),
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
