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

  Future<AuthResponse?> manageUser(
    String email,
    String password, {
    bool signIn = false,
  }) async {
    try {
      appLogger.i("Début de fonction manageUser...");
      AuthResponse res;
      if (signIn) {
        res = await authClient.signInWithPassword(
          email: email,
          password: password,
        );
      }

      res = await authClient.signUp(email: email, password: password);

      appLogger.d("Compte utilisateur créé avec succès");
      return res;
    } catch (e, st) {
      appLogger.e(
        "Erreur lors de la ${signIn ? "creation" : "suppression"} du compte utilisateur",
        error: e,
        stackTrace: st,
      );
      return null;
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
