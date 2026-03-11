import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/core/log/logger.dart';
import 'package:task_companion/features/authentication/services/auth_services.dart';
import 'package:task_companion/features/home/models/enums.dart';
import 'package:task_companion/features/profiles/models/profile_model.dart';

class ProfileServices {
  final supabase = Supabase.instance.client;

  Future getProfileData(String id) async {
    try {
      final result = await supabase
          .from('profiles_with_relation')
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
            'display_name': '$firstName $lastName',
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

  Future<bool> handleCollaboratorRequest(
    String collaboratorId,
    bool isCurrentUserRequest,
    RequestStatus status,
  ) async {
    try {
      final result = await supabase
          .from('collaborators')
          .update({"status": status.name})
          .eq(
            "requested_by",
            isCurrentUserRequest ? AuthServices.id! : collaboratorId,
          )
          .eq(
            "requested_to",
            isCurrentUserRequest ? collaboratorId : AuthServices.id!,
          )
          .select()
          .maybeSingle();

      return result != null;
    } catch (e, st) {
      appLogger.e(
        "Email handling request status Error",
        error: e,
        stackTrace: st,
        time: DateTime.now().toUtc(),
      );
      return false;
    }
  }

  Future<bool> createCollaboratorRequest(String targetUserId) async {
    try {
      final currentUserId = AuthServices.id;
      if (currentUserId == null) return false;

      await supabase.from('collaborators').insert({
        "requested_by": currentUserId,
        "requested_to": targetUserId,
        "status": "pending",
      });

      return true;
    } catch (e, st) {
      appLogger.e(
        "Error sending collaborator request",
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }
}

final profileServiceProvider = Provider<ProfileServices>((ref) {
  return ProfileServices();
});
