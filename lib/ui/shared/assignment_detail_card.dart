import 'package:flutter/material.dart';
import '../../model/assignment.dart';

class AssignmentDetailCard extends StatelessWidget {
  final Assignment assignment;
  const AssignmentDetailCard({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(assignment.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (assignment.description != null && assignment.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(assignment.description!),
            ],
            const SizedBox(height: 8),
            Text('Subject: ${assignment.subjectName ?? ''}'),
            Text('Priority: ${assignment.priorityName ?? ''}'),
          ],
        ),
      ),
    );
  }
}
