import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/features/settings/models/settings_model.dart';

class BootstrapData {
  final Settings settings;
  final SupabaseClient supabaseClient;

  const BootstrapData({required this.settings, required this.supabaseClient});
}
