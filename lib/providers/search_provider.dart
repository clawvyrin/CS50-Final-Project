// Le terme de recherche partagé
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show FutureProvider, Notifier, NotifierProvider;
import 'package:task_companion/models/profile_model.dart';
import 'package:task_companion/models/project_model.dart';
import 'package:task_companion/services/auth_services.dart';

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => "";

  void update(String value) => state = value;
}

// Provider pour les Collaborateurs (Profils)
final userSearchProvider = FutureProvider<List<Profile>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.length < 2) return [];

  final supabase = ref.read(supabaseProvider).requireValue;
  final response = await supabase.rpc(
    'search_collaborators',
    params: {'p_query': query},
  );

  return (response as List).map((json) => Profile.fromJson(json)).toList();
});

// Provider pour les Projets
final projectSearchProvider = FutureProvider<List<Project>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.length < 2) return [];

  final supabase = ref.read(supabaseProvider).requireValue;
  final response = await supabase.rpc(
    'search_my_projects',
    params: {'p_query': query},
  );

  return (response as List).map((json) => Project.fromJson(json)).toList();
});
