import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/core/logger.dart';
import 'package:task_companion/models/profile_model.dart';

class ProfileServices {
  final supabase = Supabase.instance.client;

  Future getProfileData(String id) async {
    try {
      final result = await supabase
          .from('profiles')
          .select()
          .eq("id", id)
          .maybeSingle();

      if (result != null) return Profile.fromJson(result);

      return null;
    } catch (e, st) {
      appLogger.e(
        "Email Validity Error",
        error: e,
        stackTrace: st,
        time: DateTime.now().toUtc(),
      );
      return null;
    }
  }

  Future<bool> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      await supabase
          .from('profiles')
          .update({
            'first_name': ?firstName,
            'last_name': ?lastName,
            'biography': ?bio,
            'avatar_url': ?avatarUrl,
            'display_name':
                '$firstName $lastName', // On reconstruit le nom complet
          })
          .eq('id', userId);

      return true;
    } catch (e, st) {
      appLogger.e(
        "Profile Update Error",
        error: e,
        stackTrace: st,
        time: DateTime.now().toUtc(),
      );
      return false;
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final result = await supabase
          .from('profiles')
          .select('id')
          .eq("email", email)
          .maybeSingle();

      return result != null;
    } catch (e, st) {
      appLogger.e(
        "Email Validity Error",
        error: e,
        stackTrace: st,
        time: DateTime.now().toUtc(),
      );
      return false;
    }
  }
}

final profileServiceProvider = Provider<ProfileServices>((ref) {
  return ProfileServices();
});
