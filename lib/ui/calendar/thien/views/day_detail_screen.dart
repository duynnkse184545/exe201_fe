import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/assignment/assignment.dart';
import '../../../../model/event/event.dart';
import '../../../../provider/calendar_providers.dart';
import '../../../extra/header.dart';
import '../../../extra/speed_dial_menu.dart';
import '../../calendar_theme.dart';


class DayDetailScreen extends ConsumerWidget {
  final DateTime selectedDate;

  const DayDetailScreen({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Set the selected day in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedDayProvider.notifier).setDay(selectedDate);
    });

    final dayEventsAsync = ref.watch(dayEventsProvider);
    final dayAssignmentsAsync = ref.watch(dayAssignmentsProvider);

    return Scaffold(
      appBar: Header(
        title: 'Day Detail - ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
      ),
      body: Row(
        children: [
          // Left Panel - Timeline
          Expanded(
            flex: 1,
            child: _buildTimelinePanel(),
          ),
          // Right Panel - Events & Assignments
          Expanded(
            flex: 2,
            child: _buildEventsAssignmentsPanel(dayEventsAsync, dayAssignmentsAsync),
          ),
        ],
      ),
      floatingActionButton: const SpeedDialMenu(),
    );
  }

  Widget _buildTimelinePanel() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Timeline',
              style: CalendarTheme.titleStyle,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 18, // 6:00 AM to 11:00 PM
              itemBuilder: (context, index) {
                final hour = 6 + index;
                final timeString = '${hour.toString().padLeft(2, '0')}:00';
                
                return Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(
                          timeString,
                          style: CalendarTheme.subtitleStyle,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsAssignmentsPanel(
    AsyncValue<List<Event>> dayEventsAsync,
    AsyncValue<List<Assignment>> dayAssignmentsAsync,
  ) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Events & Assignments',
              style: CalendarTheme.titleStyle,
            ),
          ),
          Expanded(
            child: dayEventsAsync.when(
              data: (events) => dayAssignmentsAsync.when(
                data: (assignments) {
                  if (events.isEmpty && assignments.isEmpty) {
                    return const Center(
                      child: Text(
                        'No events or assignments for this day',
                        style: CalendarTheme.subtitleStyle,
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Events section
                      if (events.isNotEmpty) ...[
                        const Text(
                          'Events',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CalendarTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...events.map((event) => _buildEventItem(event)),
                        const SizedBox(height: 16),
                      ],
                      
                      // Assignments section
                      if (assignments.isNotEmpty) ...[
                        const Text(
                          'Assignments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CalendarTheme.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...assignments.map((assignment) => _buildAssignmentItem(assignment)),
                      ],
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: CalendarTheme.primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(event.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${event.startDateTime.hour.toString().padLeft(2, '0')}:${event.startDateTime.minute.toString().padLeft(2, '0')} - ${event.endDateTime.hour.toString().padLeft(2, '0')}:${event.endDateTime.minute.toString().padLeft(2, '0')}',
            ),
            if (event.description != null && event.description!.isNotEmpty)
              Text(
                event.description!,
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () {
                // TODO: Navigate to edit event
              },
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () {
                // TODO: Delete event
              },
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentItem(Assignment assignment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: CalendarTheme.secondaryColor,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(assignment.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Due: ${assignment.dueDate.day}/${assignment.dueDate.month}/${assignment.dueDate.year}'),
            Text('Status: ${assignment.status}'),
            if (assignment.subjectName != null)
              Text('Subject: ${assignment.subjectName}'),
            if (assignment.description != null && assignment.description!.isNotEmpty)
              Text(
                assignment.description!,
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () {
                // TODO: Navigate to edit assignment
              },
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () {
                // TODO: Delete assignment
              },
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}