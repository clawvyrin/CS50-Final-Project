import 'package:flutter/material.dart';
import 'package:task_companion/models/enums.dart';
import 'package:task_companion/models/project_member_model.dart';

class MembersTab extends StatelessWidget {
  final List<ProjectMember> members;
  const MembersTab({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(
            "ID Utilisateur: ${member.userId.substring(0, 8)}...",
          ), // À remplacer par le nom si jointure faite
          subtitle: Text("Rôle: ${member.role.name}"),
          trailing: Chip(
            label: Text(
              member.status.name,
              style: const TextStyle(fontSize: 10),
            ),
            backgroundColor: member.status == AssignmentStatus.accepted
                ? Colors.green.shade50
                : Colors.grey.shade100,
          ),
        );
      },
    );
  }
}
