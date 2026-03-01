import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/core/functions.dart';
import 'package:task_companion/core/logger.dart';
import 'package:task_companion/services/supabase_services.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  File? avatar;

  bool isLoading = false;
  bool isEmailTaken = false;

  Widget avatarForm() {
    return Stack(
      alignment: AlignmentGeometry.center,
      children: [
        CircleAvatar(
          radius: 70,
          foregroundImage: avatar != null
              ? FileImage(avatar!)
              : const AssetImage('assets/images/default_avatar.jpg')
                    as ImageProvider,
        ),
        Positioned(
          right: 85.0,
          top: 100.0,
          child: PlatformIconButton(
            color: Theme.of(context).iconTheme.color,
            onPressed: () async {
              var pickedImage = await pickImage(true);
              if (pickedImage != null) setState(() => avatar = pickedImage);
            },
            icon: Icon(PlatformIcons(context).edit, size: 30),
          ),
        ),
      ],
    );
  }

  Widget emailForm() {
    return PlatformTextFormField(
      controller: emailController,
      hintText: "Email",
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: (value) {
        final basicError = formValidator(
          value ?? '',
          Validator.email,
          isSignIn: false,
          isEmailTaken: isEmailTaken,
        );
        if (basicError != null) return basicError;
        if (isEmailTaken) return "Email already in use";
        return null;
      },
      onChanged: (value) async {
        // Optionnel : On réinitialise l'erreur quand l'utilisateur modifie le texte
        if (isEmailTaken) setState(() => isEmailTaken = false);

        // On vérifie seulement si le format de l'email est déjà valide pour ne pas spammer la DB
        if (value.contains('@') && value.contains('.')) {
          bool exists = await SupabaseServices().checkEmailExists(value);
          if (exists != isEmailTaken) {
            setState(() => isEmailTaken = exists);
            _formKey.currentState?.validate(); // Relance la validation visuelle
          }
        }
      },
    );
  }

  Widget passwordForm() {
    return PlatformTextFormField(
      obscureText: true,
      controller: passwordController,
      hintText: "Password",
      textInputAction: TextInputAction.done,
      validator: (value) => formValidator(value ?? '', Validator.password),
    );
  }

  Widget displayNameForm() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: PlatformTextFormField(
            controller: firstNameController,
            hintText: "First name",
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            validator: (value) =>
                formValidator(value ?? '', Validator.displayName),
          ),
        ),
        SizedBox(width: 5),
        Expanded(
          child: PlatformTextFormField(
            controller: lastNameController,
            hintText: "Last name",
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            validator: (value) =>
                formValidator(value ?? '', Validator.displayName),
          ),
        ),
      ],
    );
  }

  Widget bioForm() {
    return PlatformTextFormField(
      controller: bioController,
      hintText: "Biography",
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      validator: (value) => formValidator(value ?? '', Validator.bio),
    );
  }

  Future<void> _handleSignUp() async {
    bool alreadyTaken = await SupabaseServices().checkEmailExists(
      emailController.text,
    );
    if (alreadyTaken) {
      setState(() => isEmailTaken = true);
      _formKey.currentState!.validate();
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      bool success = await SupabaseServices().signUp({
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "biography": bioController.text.trim(),
      }, avatar);

      appLogger.i("Connexion réussie");

      if (success && mounted) {
        context.go('/home'); // Redirection manuelle si nécessaire
      }
    } catch (e) {
      appLogger.e("Erreur de connexion", error: e);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget signUpButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: SizedBox(
        width: 255,
        height: 55,
        child: PlatformElevatedButton(
          onPressed: isLoading ? null : _handleSignUp,
          child: isLoading
              ? const CircularProgressIndicator()
              : Text("Sign Up"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(title: Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Form(
          key: _formKey,
          child: Stack(
            alignment: AlignmentGeometry.bottomCenter,
            children: [
              ListView(
                padding: const EdgeInsets.only(bottom: 150),
                shrinkWrap: true,
                children: [
                  avatarForm(),
                  const SizedBox(height: 30),
                  displayNameForm(),
                  const SizedBox(height: 15),
                  bioForm(),
                  const SizedBox(height: 30),
                  emailForm(),
                  const SizedBox(height: 15),
                  passwordForm(),
                ],
              ),
              signUpButton(),
            ],
          ),
        ),
      ),
    );
  }
}
