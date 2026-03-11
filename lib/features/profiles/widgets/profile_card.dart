import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/features/authentication/services/auth_services.dart';
import 'package:task_companion/features/home/models/enums.dart';
import 'package:task_companion/features/profiles/models/profile_model.dart';
import 'package:task_companion/features/profiles/providers/profiles_provider.dart';
import 'package:task_companion/features/profiles/widgets/profile_picture.dart';

class ProfileCard extends ConsumerWidget {
  final Profile user;
  const ProfileCard({super.key, required this.user});

  Future<void> _handleRequest(WidgetRef ref, RequestStatus status) async {
    await ref
        .read(profileProvider(AuthServices.id!).notifier)
        .handleRequest(
          user.id,
          user.currentUserRequested,
          RequestStatus.accepted,
        );
  }

  Future<void> _sendInitialRequest(WidgetRef ref) async {
    await ref.read(profileProvider(user.id).notifier).sendInvitation();
  }

  Widget showActionButtons(WidgetRef ref) {
    if (user.isCollaborator) return const SizedBox.shrink();

    if (user.otherUserRequested) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async =>
                await _handleRequest(ref, RequestStatus.accepted),
            child: Text("Accept", style: TextStyle(color: Colors.green)),
          ),
          ElevatedButton(
            onPressed: () async =>
                await _handleRequest(ref, RequestStatus.denied),
            child: Text("Decline", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    }

    if (user.currentUserRequested) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "Invitation sent...",
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    return ElevatedButton(
      onPressed: () => _sendInitialRequest(ref),
      child: const Text("Add Collaborator"),
    );
  }

  Widget collaboratorsButtons(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () {
        if (user.conversationId == null) return;
        context.pop();
        context.goNamed(
          "conversations",
          pathParameters: {"conversation_id": user.conversationId!},
        );
      },
      icon: Icon(Icons.message),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ProfilePicture(avatarUrl: user.avatarUrl),
        Text(user.displayName),
        Text(user.biography!),
        if (!user.isCurrentUser) showActionButtons(ref),
        if (user.isCollaborator && !user.isCurrentUser)
          collaboratorsButtons(context, ref),
      ],
    ),
  );
}
