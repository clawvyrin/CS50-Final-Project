import 'dart:io';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_companion/core/logger.dart';

enum Validator { email, password, displayName, bio }

String? formValidator(
  String value,
  Validator type, {
  bool isEmailAvailable = false,
  bool isSignIn = true,
}) {
  switch (type) {
    case Validator.email:
      return emailValidator(value, isEmailAvailable, isSignIn);
    case Validator.password:
      return paswordValidator(value);
    default:
      return null;
  }
}

String? emailValidator(String email, bool isEmailAvailable, bool isSignIn) {
  if (email.isEmpty ||
      !RegExp(
        r"""
^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+""",
      ).hasMatch(email)) {
    return "Please, provide a valid email";
  } else if (isEmailAvailable == false && !isSignIn) {
    return "Email already in use";
  }
  return null;
}

String? paswordValidator(String password) {
  if (password.isEmpty) {
    return "Please, provide a password";
  } else if (password.length < 6) {
    return "Provided pasword is too short";
  } else if (password.length > 30) {
    return "Provided pasword is too long";
  }
  return null;
}

Future<File?> pickImage(bool fromGallery) async {
  try {
    XFile? pickedImage = await ImagePicker().pickImage(
      source: fromGallery ? ImageSource.gallery : ImageSource.camera,
      imageQuality: 50,
    );

    if (pickedImage == null) return null;

    CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: pickedImage.path,
      aspectRatio: const CropAspectRatio(ratioX: 10, ratioY: 10),
      //  cropStyle: CropStyle.circle,
      compressFormat: ImageCompressFormat.png,
    );

    return File(cropped!.path);
  } catch (e, st) {
    appLogger.e(
      "Error picking image",
      error: e,
      time: DateTime.now().toUtc(),
      stackTrace: st,
    );
    return null;
  }
}
