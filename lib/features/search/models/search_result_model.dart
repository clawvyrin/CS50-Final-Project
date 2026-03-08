enum SearchRestultType { users, projects, tasks }

class SearchResultModel {
  List results;
  SearchRestultType type;

  SearchResultModel({required this.results, required this.type});
}
