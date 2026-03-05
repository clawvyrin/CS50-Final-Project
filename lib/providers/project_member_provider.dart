import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/models/project_member_model.dart';
import 'package:task_companion/services/auth_services.dart';

final projectMembersProvider =
    AsyncNotifierProvider.family<
      ProjectMembersNotifier,
      List<ProjectMember>,
      String
    >(ProjectMembersNotifier.new);

class ProjectMembersNotifier extends AsyncNotifier<List<ProjectMember>> {
  String projectId;
  ProjectMembersNotifier(this.projectId);

  @override
  FutureOr<List<ProjectMember>> build() async {
    return _fetchMembers();
  }

  Future<List<ProjectMember>> _fetchMembers() async {
    final supabase = ref.read(supabaseProvider);
    final response = await supabase.value!
        .from('project_members')
        .select('*, profiles(display_name, avatar_url)')
        .eq('project_id', projectId);

    return (response as List)
        .map((json) => ProjectMember.fromJson(json))
        .toList();
  }

  Future<void> addMember(String userId, String role) async {
    final supabase = ref.read(supabaseProvider);
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await supabase.value!.from('project_members').insert({
        'project_id': projectId,
        'user_id': userId,
        'role': role, // 'admin' ou 'worker'
      });
      return _fetchMembers(); // On rafraîchit la liste
    });
  }

  Future<void> removeMember(String userId) async {
    final supabase = ref.read(supabaseProvider);
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await supabase.value!
          .from('project_members')
          .delete()
          .eq('project_id', projectId)
          .eq('user_id', userId);
      return _fetchMembers();
    });
  }
}
