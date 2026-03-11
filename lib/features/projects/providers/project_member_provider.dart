import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/features/projects/models/project_member_model.dart';
import 'package:task_companion/features/authentication/services/auth_services.dart';

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
    final response = await supabase
        .from('project_member_view')
        .select()
        .eq('project_id', projectId);

    return (response as List)
        .map((json) => ProjectMember.fromJson(json))
        .toList();
  }

  Future<List<ProjectMember>?> addMembers(List<String> userIds) async {
    final supabase = ref.read(supabaseProvider);
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final List<Map<String, dynamic>> toInsert = userIds
          .map(
            (id) => {
              'project_id': projectId,
              'user_id': id,
              'role': 'collaborator',
            },
          )
          .toList();

      await supabase.from('project_members').insert(toInsert);

      return await _fetchMembers();
    });

    return state.value;
  }

  Future<void> removeMember(String userId) async {
    final supabase = ref.read(supabaseProvider);
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await supabase
          .from('project_members')
          .delete()
          .eq('project_id', projectId)
          .eq('user_id', userId);
      return _fetchMembers();
    });
  }
}
