import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      () async => await ProfileServices().getProfileData(id),
    );
  }
}
