import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/features/authentication/services/auth_services.dart';
import 'package:task_companion/features/authentication/screens/auth_method.dart';
import 'package:task_companion/features/authentication/screens/sign_in.dart';
import 'package:task_companion/features/conversations/screens/conversation_screen.dart';
import 'package:task_companion/features/conversations/screens/show_conversations.dart';
import 'package:task_companion/features/home/screens/home.dart';
import 'package:task_companion/features/authentication/screens/sign_up.dart';
import 'package:task_companion/features/notifications/screens/notifications.dart';
import 'package:task_companion/features/projects/screens/project_dashboard.dart';
import 'package:task_companion/features/search/screens/search.dart';
import 'package:task_companion/features/settings/screens/settings.dart';
import 'package:task_companion/features/tasks/screens/task_details.dart';

late GoTrueClient authClient;

final routerProvider = Provider<GoRouter>((ref) {
  final supabaseClient = ref.watch(supabaseProvider).auth;

  authClient = supabaseClient;
  return AppRouter.router;
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
            routes: [],
          ),
          GoRoute(
            path: 'notifications',
            name: 'notifications',
            builder: (context, state) => NotificationsPage(),
          ),
          GoRoute(
            path: 'conversations',
            name: 'conversations',
            builder: (context, state) => ShowConversations(),
            routes: [
              GoRoute(
                path: "conversation/:conversationId",
                name: "conversation",
                builder: (context, state) {
                  final conversationId = state.pathParameters['conversationId'];
                  return ConversationScreen(conversationId: conversationId!);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'project/:projectId/task/:taskId',
            name: 'task_details',
            builder: (context, state) {
              final taskId = state.pathParameters['taskId'];
              final projectId = state.pathParameters['projectId'];
              return TaskDetails(taskId: taskId!, projectId: projectId!);
            },
          ),
          GoRoute(
            path: 'search',
            name: 'search',
            builder: (context, state) => Search(),
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
        return '/home';
      } else if (!isLoggedIn && state.fullPath!.contains("/home")) {
        return '/auth';
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(authClient.onAuthStateChange),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((auth) {
      AuthServices().setUserId(auth.session?.user.id);
      return notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
