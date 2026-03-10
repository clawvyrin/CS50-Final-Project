import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/features/authentication/models/supabase_model.dart';
import 'package:task_companion/core/data/shared_preferences_service.dart';
import 'package:task_companion/features/home/models/bootstrap_model.dart';
import 'package:task_companion/features/notifications/services/push_services.dart';
import 'package:task_companion/firebase_options.dart';

class AppBootstrap {
  static Future<BootstrapData> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await dotenv.load(fileName: ".env");
    await FastCachedImageConfig.init();

    final settings = await SharedPreferencesService().loadSettings();

    final supabaseCredentials = SupabaseCredentials(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );

    await Supabase.initialize(
      url: supabaseCredentials.url,
      anonKey: supabaseCredentials.anonKey,
    );

    final client = Supabase.instance.client;

    await PushNotificationService().initialize();

    return BootstrapData(settings: settings, supabaseClient: client);
  }
}
