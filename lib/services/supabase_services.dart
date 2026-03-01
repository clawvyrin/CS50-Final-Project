import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/core/logger.dart';
import 'package:task_companion/services/router_services.dart';

final supabaseProvider =
    AsyncNotifierProvider<SupabaseNotifier, SupabaseClient>(
      SupabaseNotifier.new,
    );

class SupabaseServices {
  final supabase = Supabase.instance.client;

  static String? id = "";

  void setUserId(String? id) => SupabaseServices.id = id;

  Future<bool> signUp(Map<String, dynamic> userData) async {
    try {
      appLogger.i("Début de fonction manageUser...");
      AuthResponse? response;

      response = await authClient.signUp(
        email: userData["email"],
        password: userData["password"],
        data: {
          "display_name": userData["displayName"],
          "avatar_url": userData["avatarUrl"],
          "biography": userData["biography"],
        },
      );

      if (response.user == null) return false;

      appLogger.d("Utilisateur créé avec succès: ${response.user!.id}");
      setUserId(response.user!.id);

      return true;
    } catch (e, st) {
      appLogger.e(
        "Erreur lors de la creation du compte utilisateur",
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      appLogger.i("Tentative de connexion pour: $email");
      AuthResponse? response;

      response = await authClient.signInWithPassword(
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
      );
      return false;
    }
  }
}

class SupabaseNotifier extends AsyncNotifier<SupabaseClient> {
  @override
  Future<SupabaseClient> build() async {
    await Supabase.initialize(url: '', anonKey: '');

    SupabaseServices().setUserId(Supabase.instance.client.auth.currentUser?.id);

    return Supabase.instance.client;
  }
}
