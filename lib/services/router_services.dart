import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/services/auth_services.dart';
import 'package:task_companion/ui/screens/authentication/auth_method.dart';
import 'package:task_companion/ui/screens/authentication/sign_in.dart';
import 'package:task_companion/ui/screens/home/home.dart';
import 'package:task_companion/ui/screens/authentication/sign_up.dart';
import 'package:task_companion/ui/screens/notifications/notifications.dart';
import 'package:task_companion/ui/screens/projects/project_dashboard.dart';
import 'package:task_companion/ui/screens/search/search.dart';
import 'package:task_companion/ui/screens/search/search_results.dart';
import 'package:task_companion/ui/screens/settings/settings.dart';
import 'package:task_companion/ui/screens/tasks/task_conversation_page.dart';
import 'package:task_companion/ui/screens/tasks/task_details.dart';
import 'package:task_companion/ui/widgets/on_error.dart';
import 'package:task_companion/ui/widgets/on_loading.dart';

late GoTrueClient authClient;

final routerProvider = Provider<GoRouter>((ref) {
  return ref
      .watch(supabaseProvider)
      .maybeWhen(
        data: (supabaseClient) {
          authClient = supabaseClient.auth;
          return AppRouter.router;
        },
        orElse: () => GoRouter(
          routes: [GoRoute(path: '/', builder: (_, _) => const OnLoading())],
        ),
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
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthenticationMethod(),
        routes: [
          GoRoute(
            path: 'sign_up',
            name: 'sign_up',
            builder: (context, state) => const Register(),
          ),
          GoRoute(
            path: 'sign_in',
            name: 'sign_in',
            builder: (context, state) => const SignIn(),
          ),
        ],
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const Home(),
        routes: [
          GoRoute(
            path: 'project/:projectId',
            name: 'project',
            builder: (context, state) {
              final projectId = state.pathParameters['projectId'];
              return ProjectDashboard(projectId: projectId!);
            },
            routes: [
              GoRoute(
                path: 'tasks/:taskId',
                name: 'tasks',
                builder: (context, state) {
                  final taskId = state.pathParameters['taskId'];
                  final projectId = state.pathParameters['projectId'];
                  return TaskConversationPage(
                    taskId: taskId!,
                    projectId: projectId!,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'task_details/',
                    name: 'task_details',
                    builder: (context, state) {
                      final taskId = state.pathParameters['taskId'];
                      final projectId = state.pathParameters['projectId'];
                      return TaskDetails(
                        taskId: taskId!,
                        projectId: projectId!,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'notifications',
            name: 'notifications',
            builder: (context, state) => Notifications(),
          ),
          GoRoute(
            path: 'search',
            name: 'search',
            builder: (context, state) => Search(),
            routes: [
              GoRoute(
                path: 'search_results',
                name: 'search_results',
                builder: (context, state) => SearchResults(),
              ),
            ],
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const Settings(),
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final session = authClient.currentSession;
      final bool isLoggedIn = session != null;

      if (isLoggedIn && state.fullPath!.contains("/auth")) {
        return "/home";
      } else if (!isLoggedIn && state.fullPath!.contains("/home")) {
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
