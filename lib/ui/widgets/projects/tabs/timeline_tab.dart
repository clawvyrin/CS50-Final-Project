import 'package:flutter/material.dart';
import 'package:task_companion/models/timeline_event_model.dart';

class TimelineTab extends StatelessWidget {
  final List<TimelineEvent> events;
  const TimelineTab({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    // Trier par date décroissante (plus récent en haut)
    final sortedEvents = [...events]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.builder(
      itemCount: sortedEvents.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final event = sortedEvents[index];
        return IntrinsicHeight(
          child: Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, size: 12, color: Colors.blue),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.blue.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.content,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${event.createdAt.day}/${event.createdAt.month} à ${event.createdAt.hour}:${event.createdAt.minute}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
