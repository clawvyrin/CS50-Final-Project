import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/core/start/bootstrap.dart';
import 'package:task_companion/features/settings/providers/settings_provider.dart';
import 'package:task_companion/features/settings/providers/theme_provider.dart';
import 'package:task_companion/features/authentication/services/auth_services.dart';
import 'package:task_companion/core/router/router_services.dart';

void main() async {
  final bootstrap = await AppBootstrap.initialize();

  runApp(
    ProviderScope(
      overrides: [
        settingsProvider.overrideWith(
          () => SettingsNotifier(bootstrap.settings),
        ),
        supabaseProvider.overrideWith(
          () => SupabaseNotifier(bootstrap.supabaseClient),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return PlatformProvider(
      builder: (context) => PlatformTheme(
        themeMode: themeMode,
        builder: (context) => PlatformApp.router(
          title: "Task Companion",
          debugShowCheckedModeBanner: false,
          routerConfig: ref.watch(routerProvider),
        ),
      ),
    );
  }
}
