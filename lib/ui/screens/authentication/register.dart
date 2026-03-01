import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/core/functions.dart';
import 'package:task_companion/services/supabase_services.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final emailKey = GlobalKey<FormState>();
  final passwordKey = GlobalKey<FormState>();
  final firstNameKey = GlobalKey<FormState>();
  final lastNameKey = GlobalKey<FormState>();
  final bioKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  File? avatar;

  bool isLoading = false;

  Widget avatarForm() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 80,
          foregroundImage: avatar != null
              ? FileImage(avatar!)
              : const AssetImage('assets/images/default_avatar.jpg')
                    as ImageProvider,
        ),
        Positioned(
          left: 105.0,
          top: 110.0,
          child: IconButton(
            color: Theme.of(context).iconTheme.color,
            onPressed: () async {
              var pickedImage = await pickImage(true);
              if (pickedImage != null) setState(() => avatar = pickedImage);
            },
            icon: const Icon(Icons.add, size: 30),
          ),
        ),
      ],
    );
  }

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

  Widget displayNameForm() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PlatformTextFormField(
          key: firstNameKey,
          controller: firstNameController,
          hintText: "First name",
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          onChanged: (value) => firstNameKey.currentState!.validate(),
          validator: (value) => formValidator(value!, Validator.displayName),
        ),
        SizedBox(width: 5),
        PlatformTextFormField(
          key: lastNameKey,
          controller: lastNameController,
          hintText: "Last name",
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          onChanged: (value) => lastNameKey.currentState!.validate(),
          validator: (value) => formValidator(value!, Validator.displayName),
        ),
      ],
    );
  }

  Widget bioForm() {
    return PlatformTextFormField(
      key: bioKey,
      controller: bioController,
      hintText: "Biography",
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      onChanged: (value) => bioKey.currentState!.validate(),
      validator: (value) => formValidator(value!, Validator.bio),
    );
  }

  Widget signUpButton() {
    return PlatformElevatedButton(
      onPressed: isLoading
          ? null
          : () async {
              if (emailKey.currentState!.validate() == false ||
                  passwordKey.currentState!.validate() == false) {
                return;
              }

              setState(() => isLoading = true);

              bool isLoggedIn = await SupabaseServices().signUp({
                "email": emailController.text.trim(),
                "password": passwordController.text.trim(),
                "firstName": firstNameController.text.trim(),
                "lastName": lastNameController.text.trim(),
                "biography": bioController.text.trim(),
                "avatarUrl": "",
              });

              setState(() => isLoading = false);

              if (mounted && isLoggedIn) context.pop();
            },
      child: isLoading ? const CircularProgressIndicator() : Text("Sign Up"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(title: Text("Task Companion")),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            avatarForm(),
            const SizedBox(height: 15),
            emailForm(),
            const SizedBox(height: 15),
            passwordForm(),
            const SizedBox(height: 15),
            displayNameForm(),
            const SizedBox(height: 15),
            bioForm(),
            const SizedBox(height: 25),
            signUpButton(),
          ],
        ),
      ),
    );
  }
}
