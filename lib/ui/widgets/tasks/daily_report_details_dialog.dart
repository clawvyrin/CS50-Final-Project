import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/models/activity_model.dart';
import 'package:task_companion/models/task_report_model.dart';
import 'package:task_companion/providers/tasks_provider.dart';

class DailyReportDetailsDialog extends ConsumerWidget {
  final DailyTaskReport report;
  const DailyReportDetailsDialog({super.key, required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AlertDialog(
    title: Row(
      children: [
        const Icon(Icons.description, color: Colors.blue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "Rapport du ${report.reportedAt!.toLocal().toString().split(' ')[0]}",
          ),
        ),
      ],
    ),
    content: SizedBox(
      width: double.maxFinite,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Résumé
            const Text(
              "Résumé de la journée",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(report.dailySummary ?? "Aucun résumé fourni."),
            const Divider(height: 30),

            // 2. Liste des activités du jour
            const Text(
              "Activités réalisées",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...report.dailyActivities.map(
              (act) => _buildActivityDetailItem(act),
            ),

            const Divider(height: 30),

            // 3. État de validation
            _buildValidationStatus(report),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("Fermer"),
      ),
      if (!report.isSigned) // Si l'admin ne l'a pas encore validé
        ElevatedButton.icon(
          onPressed: () => _handleCertification(report, context, ref),
          icon: const Icon(Icons.verified_user),
          label: const Text("Certifier le rapport"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
    ],
  );

  Future<void> _handleCertification(
    DailyTaskReport report,
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      // 1. Appel au service Supabase
      await ref
          .read(taskActionsProvider.notifier)
          .verifyReport(reportId: report.id, taskId: report.taskId);

      // 2. Feedback utilisateur
      if (context.mounted) {
        Navigator.pop(context); // Ferme le dialogue
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Rapport certifié avec succès"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la certification : $e")),
        );
      }
    }
  }

  Widget _buildActivityDetailItem(Activity activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.arrow_right, size: 18),
              Expanded(
                child: Text(
                  activity.description ?? "",
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          // Si l'activité a consommé des ressources
          if (activity.affectedResources != null)
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 4),
              child: Wrap(
                spacing: 8,
                children: activity.affectedResources!
                    .map(
                      (res) => Chip(
                        label: Text(
                          "-${res.allocatedAmount} ${res.unit}",
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: Colors.orange.shade50,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildValidationStatus(DailyTaskReport report) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: report.isSigned ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            report.isSigned ? Icons.check_circle : Icons.pending,
            color: report.isSigned ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 10),
          Text(
            report.isSigned
                ? "Certifié par l'Admin"
                : "En attente de certification",
            style: TextStyle(
              color: report.isSigned ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
