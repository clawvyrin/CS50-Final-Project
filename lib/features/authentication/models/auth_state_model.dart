import 'package:supabase_flutter/supabase_flutter.dart';

class AuthState {
  final Session? session;

  const AuthState({this.session});

  bool get isAuthenticated => session != null;

  String? get userId => session?.user.id;
}
