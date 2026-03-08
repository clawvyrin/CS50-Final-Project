import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/features/search/providers/search_provider.dart';
import 'package:task_companion/features/search/screens/search_results.dart';

class Search extends ConsumerWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Search...",
              border: InputBorder.none,
            ),
            onChanged: (val) =>
                ref.read(searchQueryProvider.notifier).update(val),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: "Users"),
              Tab(icon: Icon(Icons.folder), text: "Projects"),
              Tab(icon: Icon(Icons.task), text: "Tasks"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            UsersSearchResultsList(),
            ProjectsSearchResultsList(),
            TasksSearchResultsList(),
          ],
        ),
      ),
    );
  }
}
