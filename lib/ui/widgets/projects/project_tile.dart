import 'package:flutter/material.dart';
import 'package:task_companion/models/project_model.dart';

class ProjectTile extends StatefulWidget {
  final Project project;
  const ProjectTile({super.key, required this.project});

  @override
  State<ProjectTile> createState() => _ProjectTileState();
}

class _ProjectTileState extends State<ProjectTile> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
