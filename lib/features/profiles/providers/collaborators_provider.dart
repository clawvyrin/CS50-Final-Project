import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/features/authentication/services/auth_services.dart';
import 'package:task_companion/features/profiles/models/profile_model.dart';

final allCollaboratorProvider = FutureProvider.family<List<Profile>, String>((
  ref,
  query,
) async {
  final supabase = ref.watch(supabaseProvider);

  var request = supabase
      .from("profiles_with_relation")
      .select()
      .eq("is_collaborator", true)
      .eq("is_current_user", false);

  if (query.isNotEmpty) {
    request = request.ilike("display_name", '%$query%');
  }

  final response = await request.order("display_name");

  return (response as List).map((json) => Profile.fromJson(json)).toList();
});
