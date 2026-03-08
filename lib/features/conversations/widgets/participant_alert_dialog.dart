import 'package:flutter/material.dart';
import 'package:task_companion/features/conversations/models/conversation_participant_model.dart';
import 'package:task_companion/features/profiles/widgets/profile_picture.dart';

class ParticipantAlertDialog extends StatelessWidget {
  final ConversationParticipant participant;
  const ParticipantAlertDialog({super.key, required this.participant});

  @override
  Widget build(BuildContext context) => AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ProfilePicture(avatarUrl: participant.user.avatarUrl!),
        Text(participant.user.displayName),
      ],
    ),
  );
}
