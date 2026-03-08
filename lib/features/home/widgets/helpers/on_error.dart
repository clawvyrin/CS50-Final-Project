import 'package:flutter/material.dart';

class OnError extends StatelessWidget {
  final Object e;
  const OnError({super.key, required this.e});

  @override
  Widget build(BuildContext context) =>
      Center(child: Text(e.toString(), style: TextStyle(fontSize: 16)));
}
