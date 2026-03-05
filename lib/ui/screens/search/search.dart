import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/providers/search_provider.dart';
import 'package:task_companion/ui/screens/search/search_results.dart';

class Search extends ConsumerWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Rechercher...",
              border: InputBorder.none,
            ),
            onChanged: (val) =>
                ref.read(searchQueryProvider.notifier).update(val),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: "Collaborateurs"),
              Tab(icon: Icon(Icons.folder), text: "Projets"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [UsersSearchResultsList(), ProjectsSearchResultsList()],
        ),
      ),
    );
  }
}
