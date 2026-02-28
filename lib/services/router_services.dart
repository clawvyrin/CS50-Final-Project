import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/services/supabase_services.dart';
import 'package:task_companion/ui/screens/home.dart';
import 'package:task_companion/ui/screens/register.dart';
import 'package:task_companion/ui/widgets/on_error.dart';
import 'package:task_companion/ui/widgets/on_loading';

late GoTrueClient authClient;

final routerProvider = Provider<GoRouter>((ref) {
  return ref
      .watch(supabaseProvider)
      .when(
        data: (supabaseClient) {
          authClient = supabaseClient.auth;
          return AppRouter.router;
        },
        error: (e, _) => GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => OnError(e: e),
            ),
          ],
        ),
        loading: () => GoRouter(
          routes: [GoRoute(path: '/', builder: (_, _) => const OnLoading())],
        ),
      );
});

class AppRouter {
  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() => _instance;
  AppRouter._internal();

  static final GoRouter router = GoRouter(
    initialLocation: '/auth',
    routes: [
      GoRoute(path: '/auth', builder: (context, state) => const Register()),
      GoRoute(path: '/home', builder: (context, state) => const Home()),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final session = authClient.currentSession;
      final bool isLoggedIn = session != null;

      if (isLoggedIn && state.fullPath!.contains("auth")) {
        if (authClient.currentUser!.userMetadata!.containsKey("username")) {
          return "/home";
        } else {
          return "/onBoard";
        }
      }

      if (!isLoggedIn && state.fullPath!.contains("auth")) {
        return "/auth";
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(authClient.onAuthStateChange),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic_) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
