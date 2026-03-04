import 'package:flutter/material.dart';

class ShowProject extends StatefulWidget {
  const ShowProject({super.key});

  @override
  State<ShowProject> createState() => _ShowProjectState();
}

class _ShowProjectState extends State<ShowProject> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Project")));
  }
}
