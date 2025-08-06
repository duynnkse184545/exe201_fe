import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../extra/speed_dial_menu.dart';
import '../../model/models.dart';
import '../../provider/calendar_providers.dart';
import 'calendar_theme.dart';
import 'widgets/deadline_dialog.dart';

class CalendarTab extends ConsumerStatefulWidget {
  const CalendarTab({super.key});

  @override
  ConsumerState<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends ConsumerState<CalendarTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const SizedBox(height: 40),
            const Text(
              "Here's your calendar, Afsar!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Text(
              "Stay on track",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thursday, Oct 2nd 2025',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            const SizedBox(height: 20),
            // Month navigation header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(4),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month - 1,
                        );
                      });
                    },
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.grey,
                      size: 25,
                    ),
                  ),
                ),

                Column(
                    children: [
                      Text(
                        DateFormat('MMMM').format(_focusedDay),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      Text(
                        DateFormat('yyyy').format(_focusedDay),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ]
                ),

                Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(4),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month + 1,
                        );
                      });
                    },
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Use a separate method to initialize providers once
            Builder(
              builder: (context) {
                // Only update the providers once when the widget is first built
                // or when the month changes
                if (_selectedDay != null) {
                  // Use a post-frame callback to avoid modifying providers during build
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    // Only update if the month has changed
                    final currentSelectedMonth = ref.read(selectedMonthProvider);
                    if (currentSelectedMonth.month != _focusedDay.month || 
                        currentSelectedMonth.year != _focusedDay.year) {
                      ref.read(selectedMonthProvider.notifier).setMonth(_focusedDay);
                    }
                    
                    // Only update if the day has changed
                    final currentSelectedDay = ref.read(selectedDayProvider);
                    if (currentSelectedDay.day != _selectedDay!.day || 
                        currentSelectedDay.month != _selectedDay!.month || 
                        currentSelectedDay.year != _selectedDay!.year) {
                      ref.read(selectedDayProvider.notifier).setDay(_selectedDay!);
                    }
                  });
                }
                
                // Watch the month events and assignments with a cache policy
                final monthEventsAsync = ref.watch(monthEventsProvider);
                final monthAssignmentsAsync = ref.watch(monthAssignmentsProvider);
                
                return monthEventsAsync.when(
                  data: (events) => monthAssignmentsAsync.when(
                    data: (assignments) {
                      // Create a map of days to their events and assignments
                      final eventsByDay = <DateTime, List<Event>>{};
                      final assignmentsByDay = <DateTime, List<Assignment>>{};
                      
                      for (final event in events) {
                        final day = DateTime(
                          event.startDateTime.year,
                          event.startDateTime.month,
                          event.startDateTime.day,
                        );
                        eventsByDay[day] = [...(eventsByDay[day] ?? []), event];
                      }
                      
                      for (final assignment in assignments) {
                        final day = DateTime(
                          assignment.dueDate.year,
                          assignment.dueDate.month,
                          assignment.dueDate.day,
                        );
                        assignmentsByDay[day] = [...(assignmentsByDay[day] ?? []), assignment];
                      }
                      
                      return TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          // Update the selected day provider
                          ref.read(selectedDayProvider.notifier).setDay(selectedDay);
                        },
                        headerVisible: false,
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: true,
                          outsideTextStyle: TextStyle(color: Colors.grey[400]),
                          defaultTextStyle: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          weekendTextStyle: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: CalendarTheme.primaryColor, // Purple from theme
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: CalendarTheme.accentColor.withOpacity(0.5), // Yellow from theme
                            shape: BoxShape.circle,
                          ),
                          // We'll use the marker builder instead of this
                          markersMaxCount: 3,
                          markersAnchor: 0.7,
                          cellMargin: const EdgeInsets.all(6),
                          cellPadding: const EdgeInsets.all(0),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          weekendStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        eventLoader: (day) {
                          // Return a combined list of events and assignments for the day
                          final normalizedDay = DateTime(day.year, day.month, day.day);
                          final dayEvents = eventsByDay[normalizedDay] ?? [];
                          final dayAssignments = assignmentsByDay[normalizedDay] ?? [];
                          
                          // Return a combined list with a maximum of 3 items
                          return [...dayEvents, ...dayAssignments].take(3).toList();
                        },
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            if (events.isEmpty) return const SizedBox.shrink();
                            
                            final normalizedDay = DateTime(date.year, date.month, date.day);
                            final dayEvents = eventsByDay[normalizedDay] ?? [];
                            final dayAssignments = assignmentsByDay[normalizedDay] ?? [];
                            
                            return Positioned(
                              bottom: 1,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Show event indicators (purple)
                                  if (dayEvents.isNotEmpty)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(horizontal: 1),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: CalendarTheme.primaryColor, // Purple for events
                                      ),
                                    ),
                                  // Show assignment indicators (blue)
                                  if (dayAssignments.isNotEmpty)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(horizontal: 1),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: CalendarTheme.secondaryColor, // Blue for assignments
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Error: $error')),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                );
              },
            ),
            const SizedBox(height: 30),
            // Upcoming deadline section - use cached data from monthAssignments
            Builder(
              builder: (context) {
                // Use the same data we already loaded for the calendar
                final assignmentsAsync = ref.watch(monthAssignmentsProvider);
                
                return assignmentsAsync.when(
                  data: (assignments) {
                    // Sort assignments by due date
                    final sortedAssignments = [...assignments]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
                    
                    // Get the next upcoming assignment
                    final upcomingAssignment = sortedAssignments.isNotEmpty ? sortedAssignments.first : null;
                    
                    if (upcomingAssignment == null) {
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
                        child: const Center(
                          child: Text(
                            'No upcoming deadlines',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }
                    
                    // Format the due date
                    final dueDate = upcomingAssignment.dueDate;
                    final formattedDate = DateFormat('EEEE, MMM d').format(dueDate);
                    
                    // Calculate estimated time remaining
                    final estimatedTime = upcomingAssignment.estimatedTime ?? 0;
                    final studiedTime = estimatedTime > 0 ? (estimatedTime * 0.8).round() : 0; // Simulate 80% completion
                    final remainingTime = estimatedTime - studiedTime;
                    
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
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Upcoming deadline!!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF6B6B),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${upcomingAssignment.subjectName ?? 'Subject'} ${upcomingAssignment.title}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Studied for: $studiedTime hours',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Remaining time: $remainingTime hours',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                );
              },
            ),
          ],
          ),
        ),
      ),
      floatingActionButton: const SpeedDialMenu(),
    );
  }
}
