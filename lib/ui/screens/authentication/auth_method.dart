import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';

class AuthenticationMethod extends StatelessWidget {
  const AuthenticationMethod({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(title: Text("Task Companion")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlatformElevatedButton(
            child: Text("Sign In"),
            onPressed: () => context.goNamed("sign_in"),
          ),
          PlatformElevatedButton(
            child: Text("Sign Up"),
            onPressed: () => context.goNamed("sign_up"),
          ),
        ],
      ),
    );
  }
}
