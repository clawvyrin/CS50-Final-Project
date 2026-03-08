import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';

class AuthenticationMethod extends StatelessWidget {
  const AuthenticationMethod({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(title: Center(child: Text("Task Companion"))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 255,
                height: 55,
                child: PlatformElevatedButton(
                  child: Center(child: Text("Sign In")),
                  onPressed: () => context.goNamed("sign_in"),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: 255,
                height: 55,
                child: PlatformElevatedButton(
                  child: Center(child: Text("Sign Up")),
                  onPressed: () => context.goNamed("sign_up"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
