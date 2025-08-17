import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../model/models.dart';
import '../../extra/custom_dialog.dart';
import '../../../provider/service_providers.dart';
import '../../../provider/calendar_providers.dart';
import 'event_dialog.dart';
import 'deadline_dialog.dart';

class DayDetailsDialog extends ConsumerWidget {
  final DateTime selectedDate;
  final List<Event> events;
  final List<Assignment> assignments;

  const DayDetailsDialog({
    super.key,
    required this.selectedDate,
    required this.events,
    required this.assignments,
  });

  static void show(
    BuildContext context,
    DateTime selectedDate,
    List<Event> events,
    List<Assignment> assignments,
  ) {
    showDialog(
      context: context,
      builder: (context) => DayDetailsDialog(
        selectedDate: selectedDate,
        events: events,
        assignments: assignments,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormatter = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormatter = DateFormat('h:mm a');
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormatter.format(selectedDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${events.length} events, ${assignments.length} assignments',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Events Section
                    if (events.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.event, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'Events (${events.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...events.map((event) => _buildEventCard(context, ref, event)),
                      const SizedBox(height: 20),
                    ],
                    
                    // Assignments Section
                    if (assignments.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.assignment, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'Assignments (${assignments.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...assignments.map((assignment) => _buildAssignmentCard(context, ref, assignment)),
                    ],
                    
                    // Empty state
                    if (events.isEmpty && assignments.isEmpty) ...[
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No events or assignments',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This day is free!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, WidgetRef ref, Event event) {
    final timeFormatter = DateFormat('h:mm a');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (event.description?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                event.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              '${timeFormatter.format(event.startDateTime)} - ${timeFormatter.format(event.endDateTime)}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              Navigator.of(context).pop();
              _showEditEventDialog(context, event);
            } else if (value == 'delete') {
              _showDeleteConfirmation(context, ref, 'event', event.eventId, event.title);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(BuildContext context, WidgetRef ref, Assignment assignment) {
    final dateFormatter = DateFormat('MMM d, h:mm a');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: _getPriorityColor(assignment.priorityColorCode),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          assignment.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (assignment.description?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                assignment.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ],
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  'Due: ${dateFormatter.format(assignment.dueDate)}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                if (assignment.priorityName != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(assignment.priorityColorCode).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      assignment.priorityName!,
                      style: TextStyle(
                        fontSize: 10,
                        color: _getPriorityColor(assignment.priorityColorCode),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              Navigator.of(context).pop();
              _showEditAssignmentDialog(context, assignment);
            } else if (value == 'delete') {
              _showDeleteConfirmation(context, ref, 'assignment', assignment.assignmentId, assignment.title);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String? colorCode) {
    if (colorCode == null) return Colors.grey;
    try {
      return Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  void _showEditEventDialog(BuildContext context, Event event) {
    EventDialog.show(context, existingEvent: event);
  }

  void _showEditAssignmentDialog(BuildContext context, Assignment assignment) {
    DeadlineDialog.show(context, existingAssignment: assignment);
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String type,
    String id,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $type'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Close the day details dialog too
              
              try {
                if (type == 'event') {
                  await ref.read(eventServiceProvider).delete(id);
                  ref.invalidate(monthEventsProvider);
                } else {
                  await ref.read(assignmentServiceProvider).delete(id);
                  ref.invalidate(monthAssignmentsProvider);
                }
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$type deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete $type: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

