import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/core/functions.dart';
import 'package:task_companion/core/logger.dart';
import 'package:task_companion/services/supabase_services.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final emailKey = GlobalKey<FormState>();
  final passwordKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Widget emailForm() {
    return PlatformTextFormField(
      key: emailKey,
      controller: emailController,
      hintText: "Email",
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: (value) => emailKey.currentState!.validate(),
      validator: (value) => formValidator(value!, Validator.email),
    );
  }

  Widget passwordForm() {
    return PlatformTextFormField(
      key: passwordKey,
      obscureText: true,
      controller: passwordController,
      hintText: "Password",
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.name,
      onChanged: (value) => passwordKey.currentState!.validate(),
      validator: (value) => formValidator(value!, Validator.password),
    );
  }

  Widget signInButton() {
    return PlatformElevatedButton(
      onPressed: isLoading
          ? null
          : () async {
              if (emailKey.currentState!.validate() == false ||
                  passwordKey.currentState!.validate() == false) {
                return;
              }

              setState(() => isLoading = true);

              bool isLoggedIn = await SupabaseServices().signIn(
                emailController.text.trim(),
                passwordController.text.trim(),
              );

              setState(() => isLoading = false);

              if (mounted && isLoggedIn) context.pop();
            },
      child: isLoading ? const CircularProgressIndicator() : Text("Sign In"),
    );
  }

  @override
  void dispose() {
    try {
      emailController.dispose();
      passwordController.dispose();
      emailKey.currentState?.dispose();
      passwordKey.currentState?.dispose();
    } catch (e, st) {
      appLogger.d(
        "Error disposing controllers in sign in",
        error: e,
        stackTrace: st,
        time: DateTime.now().toUtc(),
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          emailForm(),
          const SizedBox(height: 15),
          passwordForm(),
          const SizedBox(height: 25),
          signInButton(),
        ],
      ),
    );
  }
}
