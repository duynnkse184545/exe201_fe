import 'package:flutter/material.dart';
import '../../model/event.dart';

class EventDetailCard extends StatelessWidget {
  final Event event;
  const EventDetailCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (event.description != null && event.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(event.description!),
            ],
            const SizedBox(height: 8),
            Text('Category: ${event.categoryName ?? ''}')
          ],
        ),
      ),
    );
  }
}
