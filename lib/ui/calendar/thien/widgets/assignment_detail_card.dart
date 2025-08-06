import 'package:flutter/material.dart';
import '../../../../model/assignment/assignment.dart';

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
            Text(
              assignment.title, 
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
            if (assignment.description != null && assignment.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(assignment.description!),
            ],
            const SizedBox(height: 8),
            Text('Due: ${_formatDate(assignment.dueDate)}'),
            if (assignment.subjectName != null) ...[
              const SizedBox(height: 4),
              Text('Subject: ${assignment.subjectName}'),
            ],
            const SizedBox(height: 4),
            Text('Status: ${assignment.status}'),
            if (assignment.priorityName != null) ...[
              const SizedBox(height: 4),
              Text('Priority: ${assignment.priorityName}'),
            ],
            if (assignment.estimatedTime != null) ...[
              const SizedBox(height: 4),
              Text('Estimated Time: ${assignment.estimatedTime} hours'),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}