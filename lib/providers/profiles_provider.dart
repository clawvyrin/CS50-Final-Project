import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/models/profile_model.dart';
import 'package:task_companion/services/supabase_services.dart';

final profileProvider = AsyncNotifierProvider.autoDispose
    .family<ProfilesNotifier, Profiles, String>(ProfilesNotifier.new);

class ProfilesNotifier extends AsyncNotifier<Profiles> {
  ProfilesNotifier(this.id);
  String id;

  @override
  FutureOr<Profiles> build() async =>
      await SupabaseServices().getProfileData(id);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => await SupabaseServices().getProfileData(id),
    );
  }
}
