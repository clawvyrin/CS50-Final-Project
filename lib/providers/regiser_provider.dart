import 'package:flutter_riverpod/legacy.dart';

final userRegistrationProvider =
    StateNotifierProvider<UserRegistrationProvider, Map<String, dynamic>>(
      (ref) => UserRegistrationProvider(),
    );

class UserRegistrationProvider extends StateNotifier<Map<String, dynamic>> {
  UserRegistrationProvider()
    : super({
        "email": "",
        "password": "",
        "displayName": "",
        "avatarUrl": "",
        "biography": "",
      });

  void setEmail(String email) {
    state = {...state, "email": email};
  }

  void setPassword(String password) {
    state = {...state, "password": password};
  }

  void setDisplayName(String displayName) {
    state = {...state, "display_name": displayName};
  }

  void setBio(String bio) {
    state = {...state, "biography": bio};
  }

  void setAvatarUrl(String photoUrl) {
    state = {...state, "avatar_url": photoUrl};
  }

  Map<String, dynamic> getRegistrationData() {
    return state;
  }
}
