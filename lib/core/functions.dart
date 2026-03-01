import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_companion/core/logger.dart';

enum Validator { email, password, displayName, bio }

String? formValidator(
  String value,
  Validator type, {
  bool isEmailAvailable = true,
  bool isSignIn = true,
}) {
  switch (type) {
    case Validator.email:
      return emailValidator(value, isEmailAvailable, isSignIn);
    case Validator.password:
      return passwordValidator(value);
    case Validator.displayName:
      return value.isEmpty ? "Please provide a name" : null;
    default:
      return null;
  }
}

String? emailValidator(String email, bool isEmailAvailable, bool isSignIn) {
  final emailRegex = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );

  if (email.isEmpty || !emailRegex.hasMatch(email)) {
    return "Please, provide a valid email";
  }

  // Si on est à l'inscription et que l'email est déjà pris
  if (!isSignIn && !isEmailAvailable) {
    return "Email already in use";
  }
  return null;
}

String? passwordValidator(String password) {
  if (password.isEmpty) {
    return "Please, provide a password";
  } else if (password.length < 6) {
    return "Password is too short (min 6)";
  } else if (password.length > 30) {
    return "Password is too long (max 30)";
  }
  return null;
}

Future<File?> pickImage(bool fromGallery) async {
  try {
    final XFile? pickedImage = await ImagePicker().pickImage(
      source: fromGallery ? ImageSource.gallery : ImageSource.camera,
      imageQuality: 50,
    );

    if (pickedImage == null) return null;

    final CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: pickedImage.path,
      aspectRatio: const CropAspectRatio(
        ratioX: 1,
        ratioY: 1,
      ), // Ratio 1:1 pour les avatars
      compressFormat: ImageCompressFormat.png,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop picture',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Crop', aspectRatioLockEnabled: true),
      ],
    );

    // Vérification de sécurité si l'utilisateur annule le recadrage
    if (cropped == null) return null;
    return File(cropped.path);
  } catch (e, st) {
    appLogger.e("Error picking image", error: e, stackTrace: st);
    return null;
  }
}
