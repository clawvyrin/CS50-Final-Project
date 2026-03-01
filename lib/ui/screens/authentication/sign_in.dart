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
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Widget emailForm() {
    return PlatformTextFormField(
      controller: emailController,
      hintText: "Email",
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: (value) => formValidator(value ?? '', Validator.email),
    );
  }

  Widget passwordForm() {
    return PlatformTextFormField(
      obscureText: true,
      controller: passwordController,
      hintText: "Password",
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.name,
      validator: (value) => formValidator(value ?? '', Validator.password),
    );
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // Ton appel Supabase (à décommenter quand ton service est prêt)
      /*
      await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      */

      appLogger.i("Connexion réussie");
    } catch (e) {
      appLogger.e("Erreur de connexion", error: e);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget signInButton() {
    return SizedBox(
      width: 255,
      height: 55,
      child: PlatformElevatedButton(
        onPressed: isLoading ? null : _handleSignIn,
        child: isLoading ? const CircularProgressIndicator() : Text("Sign In"),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              emailForm(),
              const SizedBox(height: 15),
              passwordForm(),
              const SizedBox(height: 25),
              signInButton(),
            ],
          ),
        ),
      ),
    );
  }
}
