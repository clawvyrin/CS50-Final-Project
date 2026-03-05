import 'package:flutter/material.dart';
import 'package:task_companion/models/task_report_model.dart';

class ReportsTab extends StatelessWidget {
  final List<DailyTaskReport> reports;
  const ReportsTab({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return const Center(child: Text("Aucun rapport soumis pour le moment."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: const Icon(Icons.history_edu, color: Colors.blue),
            title: Text(
              "Rapport du ${report.reportedAt!.toLocal().toString().split(' ')[0]}",
            ),
            subtitle: Text(
              report.dailySummary ?? "Pas de résumé",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Horaires : ${report.startTime} - ${report.endTime}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(report.dailySummary ?? ""),
                    const Divider(),
                    Text(
                      "Soumis par : ${report.userId}",
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
