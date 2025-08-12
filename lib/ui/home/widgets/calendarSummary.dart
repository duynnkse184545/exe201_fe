import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../model/models.dart';
import '../../../provider/calendar_providers.dart';
import '../../calendar/calendar_theme.dart';

class CalendarSummary extends ConsumerWidget {
  const CalendarSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final monthEventsAsync = ref.watch(monthEventsProvider);
    final monthAssignmentsAsync = ref.watch(monthAssignmentsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: monthEventsAsync.when(
        data: (events) => monthAssignmentsAsync.when(
          data: (assignments) {
            return _buildCompactCalendar(context, now, events, assignments);
          },
          loading: () => const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => const SizedBox(
            height: 120,
            child: Center(child: Text('Error loading data')),
          ),
        ),
        loading: () => const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => const SizedBox(
          height: 120,
          child: Center(child: Text('Error loading data')),
        ),
      ),
    );
  }

  Widget _buildCompactCalendar(
      BuildContext context,
      DateTime currentMonth,
      List<Event> events,
      List<Assignment> assignments,
      ) {
    // Create maps for quick lookup
    final eventsByDay = <int, List<Event>>{};
    final assignmentsByDay = <int, List<Assignment>>{};

    for (final event in events) {
      if (event.startDateTime.month == currentMonth.month &&
          event.startDateTime.year == currentMonth.year) {
        final day = event.startDateTime.day;
        eventsByDay[day] = [...(eventsByDay[day] ?? []), event];
      }
    }

    for (final assignment in assignments) {
      if (assignment.dueDate.month == currentMonth.month &&
          assignment.dueDate.year == currentMonth.year) {
        final day = assignment.dueDate.day;
        assignmentsByDay[day] = [...(assignmentsByDay[day] ?? []), assignment];
      }
    }

    // Get calendar info
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7; // Make Sunday = 0
    final daysInMonth = lastDayOfMonth.day;
    final today = DateTime.now();

    // Calculate grid size - aim for 5 rows max
    final totalCells = firstWeekday + daysInMonth;

    return Column(
      children: [
        // Day headers
        Row(
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map(
                (day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          )
              .toList(),
        ),
        const SizedBox(height: 8),

        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: firstWeekday + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstWeekday) {
              // Empty cell before month starts
              return const SizedBox();
            }

            final day = index - firstWeekday + 1;
            final hasEvents = eventsByDay.containsKey(day);
            final hasAssignments = assignmentsByDay.containsKey(day);
            final isToday =
                day == today.day &&
                    currentMonth.month == today.month &&
                    currentMonth.year == today.year;

            // Determine tile color based on the image pattern
            Color tileColor = const Color(0xFFE0E0E0);

            if (hasEvents && hasAssignments) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xff6CB28E), Color(0xFFFF7043)],
                    stops: [0.5, 0.5],
                  ),
                ),
              );
            } else if (hasEvents) {
              tileColor = const Color(0xFF5C6BC0); // Blue
            } else if (hasAssignments) {
              tileColor = const Color(0xFFFF7043); // Orange/red
            }

            if (isToday && hasEvents) {
              Color eventColor = Theme.of(context).primaryColor;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [eventColor, const Color(0xff6CB28E)],
                    stops: const [0.5, 0.5],
                  ),
                ),
              );
            } else if (isToday) {
              tileColor = Theme.of(context).primaryColor;
            }

            return Container(
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        ),

        // Legend/Explanation
        const SizedBox(height: 12),
        _buildLegend(context),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(
          color: Theme.of(context).primaryColor,
          label: 'Today',
        ),
        _buildLegendItem(
          color: const Color(0xff6CB28E),
          label: 'Event',
        ),
        _buildLegendItem(
          color: const Color(0xFFFF7043),
          label: 'Deadline',
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}