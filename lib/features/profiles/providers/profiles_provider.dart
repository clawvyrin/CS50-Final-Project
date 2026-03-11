import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/features/home/models/enums.dart';
import 'package:task_companion/features/profiles/models/profile_model.dart';
import 'package:task_companion/features/profiles/services/profile_services.dart';

final profileProvider = AsyncNotifierProvider.autoDispose
    .family<ProfilesNotifier, Profile, String>(ProfilesNotifier.new);

class ProfilesNotifier extends AsyncNotifier<Profile> {
  ProfilesNotifier(this.id);
  String id;

  @override
  FutureOr<Profile> build() async =>
      await ref.read(profileServiceProvider).getProfileData(id);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => await ref.read(profileServiceProvider).getProfileData(id),
    );
  }

  Future handleRequest(
    String collaboratorId,
    bool isCurrentUserRequest,
    RequestStatus status,
  ) async {
    bool success = await ref
        .read(profileServiceProvider)
        .handleCollaboratorRequest(
          collaboratorId,
          isCurrentUserRequest,
          status,
        );

    if (success && state.hasValue) {
      state = AsyncValue.data(
        state.value!.copyWith(
          isCollaborator: status == RequestStatus.accepted,
          otherUserRequested: false,
          currentUserRequested: false,
        ),
      );
    }
  }

  Future<void> sendInvitation() async {
    final success = await ref
        .read(profileServiceProvider)
        .createCollaboratorRequest(id);

    if (success && state.hasValue) {
      state = AsyncValue.data(
        state.value!.copyWith(
          currentUserRequested: true,
          isCollaborator: false,
        ),
      );
    }
  }
}
