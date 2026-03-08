import 'package:flutter/material.dart';

class OnLoading extends StatelessWidget {
  const OnLoading({super.key});

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: CircularProgressIndicator.adaptive()));
}
