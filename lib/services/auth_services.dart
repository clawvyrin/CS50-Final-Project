import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/core/logger.dart';
import 'package:task_companion/services/router_services.dart';

final supabaseProvider =
    AsyncNotifierProvider<SupabaseNotifier, SupabaseClient>(
      SupabaseNotifier.new,
    );

class AuthServices {
  final supabase = Supabase.instance.client;

  static String? id = "";

  void setUserId(String? id) => AuthServices.id = id;

  ///////////////////////////////////////////////////////
  ///                                                ///
  ///               AUTHENTICATION                   ///
  ///                                                ///
  //////////////////////////////////////////////////////

  Future<bool> signUp(Map<String, dynamic> userData, File? avatarFile) async {
    try {
      appLogger.i("Début de l'inscription...");

      final AuthResponse response = await authClient.signUp(
        email: userData["email"],
        password: userData["password"],
        data: {
          "first_name": userData["firstName"],
          "last_name": userData["lastName"],
          "display_name": "${userData["firstName"]} ${userData["lastName"]}",
          "biography": userData["biography"],
        },
      );

      if (response.user == null) return false;
      String userId = response.user!.id;

      bool uploaded = await uploadPicture(avatarFile, userId);
      setUserId(userId);

      return uploaded;
    } catch (e, st) {
      appLogger.e(
        "Erreur lors de la creation du compte utilisateur",
        error: e,
        stackTrace: st,
        time: DateTime.now().toUtc(),
      );
      return false;
    }
  }

  Future<bool> signOut() async {
    try {
      appLogger.i("Début de la deconnexion...");

      await supabase.auth.signOut();
      return true;
    } catch (e, st) {
      appLogger.e(
        "Erreur lors de la deconnexion du compte utilisateur",
        error: e,
        stackTrace: st,
        time: DateTime.now().toUtc(),
      );
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      appLogger.i("Tentative de connexion pour: $email");

      AuthResponse response = await authClient.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) return false;

      appLogger.i("Connexion réussie");
      setUserId(response.user!.id);

      return true;
    } catch (e, st) {
      appLogger.e(
        "Erreur lors de la connexion au compte utilisateur $email",
        error: e,
        stackTrace: st,
        time: DateTime.now().toUtc(),
      );
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      appLogger.i("Attempt to delete account");
      await supabase.rpc('delete_my_account');
      return true;
    } catch (e, st) {
      appLogger.e(
        "Error deleting account",
        error: e,
        stackTrace: st,
        time: DateTime.now().toUtc(),
      );
      return false;
    }
  }

  ///////////////////////////////////////////////////////
  ///                                                ///
  ///                    TASKS                       ///
  ///                                                ///
  //////////////////////////////////////////////////////

  Future createTask(String projectId) async {
    try {
      appLogger.i("Attempt to edit project");

      await supabase.rpc('create_project', params: {'p_id': id});
    } catch (e, st) {
      appLogger.e(
        "Error editing project",
        error: e,
        stackTrace: st,
        time: DateTime.now().toUtc(),
      );
    }
  }

  ///////////////////////////////////////////////////////
  ///                                                ///
  ///                    MILESTONES                  ///
  ///                                                ///
  //////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////
  ///                                                ///
  ///                    RESSOURCES                  ///
  ///                                                ///
  //////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////
  ///                                                ///
  ///                    HELPERS                     ///
  ///                                                ///
  //////////////////////////////////////////////////////

  Future<bool> uploadPicture(File? avatarFile, String userId) async {
    try {
      String? publicUrl;

      if (avatarFile == null) return true;
      final fileName = '$userId/avatar.png';

      await supabase.storage.from('avatars').upload(fileName, avatarFile);
      publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

      await authClient.updateUser(
        UserAttributes(data: {'avatar_url': publicUrl}),
      );

      return true;
    } catch (e, st) {
      appLogger.e(
        "Error uploading picture",
        error: e,
        stackTrace: st,
        time: DateTime.now().toUtc(),
      );
      return false;
    }
  }
}

class SupabaseNotifier extends AsyncNotifier<SupabaseClient> {
  @override
  Future<SupabaseClient> build() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );

    AuthServices().setUserId(Supabase.instance.client.auth.currentUser?.id);

    return Supabase.instance.client;
  }
}
