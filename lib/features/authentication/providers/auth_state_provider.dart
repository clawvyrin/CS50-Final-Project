import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/features/authentication/models/auth_state_model.dart';
import 'package:task_companion/features/authentication/services/auth_services.dart';

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  StreamSubscription<AuthState>? _sub;

  @override
  AuthState build() {
    final supabase = ref.read(supabaseProvider);

    final session = supabase.auth.currentSession;

    _sub = supabase.auth.onAuthStateChange.listen((event) {
      state = AuthState(session: event.session);
    }) as StreamSubscription<AuthState>?;

    ref.onDispose(() {
      _sub?.cancel();
    });

    return AuthState(session: session);
  }
}
