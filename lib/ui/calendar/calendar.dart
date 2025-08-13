import 'package:exe201/ui/extra/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../extra/speed_dial_menu.dart';
import '../../model/models.dart';
import '../../provider/calendar_providers.dart';
import 'calendar_theme.dart';

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
              buildHeader(
                  color: Colors.black87,
                  title: "Here\'s your calendar",
                  subtitle: "Stay on track"
              ),
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
                    ],
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
                      final currentSelectedMonth = ref.read(
                        selectedMonthProvider,
                      );
                      if (currentSelectedMonth.month != _focusedDay.month ||
                          currentSelectedMonth.year != _focusedDay.year) {
                        ref
                            .read(selectedMonthProvider.notifier)
                            .setMonth(_focusedDay);
                      }

                      // Only update if the day has changed
                      final currentSelectedDay = ref.read(selectedDayProvider);
                      if (currentSelectedDay.day != _selectedDay!.day ||
                          currentSelectedDay.month != _selectedDay!.month ||
                          currentSelectedDay.year != _selectedDay!.year) {
                        ref
                            .read(selectedDayProvider.notifier)
                            .setDay(_selectedDay!);
                      }
                    });
                  }

                  // Watch the month events and assignments with a cache policy
                  final monthEventsAsync = ref.watch(monthEventsProvider);
                  final monthAssignmentsAsync = ref.watch(
                    monthAssignmentsProvider,
                  );

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
                          eventsByDay[day] = [
                            ...(eventsByDay[day] ?? []),
                            event,
                          ];
                        }

                        for (final assignment in assignments) {
                          final day = DateTime(
                            assignment.dueDate.year,
                            assignment.dueDate.month,
                            assignment.dueDate.day,
                          );
                          assignmentsByDay[day] = [
                            ...(assignmentsByDay[day] ?? []),
                            assignment,
                          ];
                        }

                        return TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                            // Update the selected day provider
                            ref.read(selectedDayProvider.notifier).setDay(selectedDay);
                          },
                          onPageChanged: (focusedDay) {
                            // Called when user swipes to a different month
                            setState(() {
                              _focusedDay = focusedDay;
                            });
                            ref.read(selectedMonthProvider.notifier).setMonth(focusedDay);
                          },
                          headerVisible: false,
                          calendarStyle: CalendarStyle(
                            outsideDaysVisible: false,
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
                            selectedDecoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(4), // Changed to rounded rectangle
                            ),
                            todayDecoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(4), // Changed to rounded rectangle
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
                            final normalizedDay = DateTime(
                              day.year,
                              day.month,
                              day.day,
                            );
                            final dayEvents = eventsByDay[normalizedDay] ?? [];
                            final dayAssignments =
                                assignmentsByDay[normalizedDay] ?? [];

                            // Return a combined list with a maximum of 3 items
                            return [
                              ...dayEvents,
                              ...dayAssignments,
                            ].take(3).toList();
                          },
                          calendarBuilders: CalendarBuilders(
                            // Custom builder for days with events/assignments
                            defaultBuilder: (context, day, focusedDay) {
                              final normalizedDay = DateTime(
                                day.year,
                                day.month,
                                day.day,
                              );
                              final today = DateTime.now();
                              final normalizedToday = DateTime(today.year, today.month, today.day);
                              final isPastDate = normalizedDay.isBefore(normalizedToday);

                              final dayEvents = eventsByDay[normalizedDay] ?? [];
                              final dayAssignments = assignmentsByDay[normalizedDay] ?? [];
                              final hasEvents = dayEvents.isNotEmpty;
                              final hasAssignments = dayAssignments.isNotEmpty;
                              final isToday = isSameDay(day, DateTime.now());
                              final isSelected = isSameDay(day, _selectedDay);

                              // Default tile color
                              Color? tileColor;
                              Decoration? decoration;

                              // Past dates don't show event/assignment colors, but keep white background
                              if (!isPastDate) {
                                // Only show event/assignment colors for today and future dates
                                if (hasEvents && hasAssignments) {
                                  // Both events and assignments - gradient
                                  decoration = BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Color(0xff6CB28E), Color(0xFFFF7043)], // Green + Orange
                                      stops: [0.5, 0.5],
                                    ),
                                  );
                                } else if (hasEvents) {
                                  // Only events - green
                                  tileColor = const Color(0xff6CB28E);
                                } else if (hasAssignments) {
                                  // Only assignments - orange
                                  tileColor = const Color(0xFFFF7043);
                                }

                                // Handle today and selected states (only for non-past dates)
                                if (isSelected || isToday) {
                                  if (hasEvents || hasAssignments) {
                                    // If it's today/selected AND has events/assignments, combine colors
                                    if (hasEvents && hasAssignments) {
                                      decoration = BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Theme.of(context).primaryColor,
                                            const Color(0xff6CB28E),
                                            const Color(0xFFFF7043)
                                          ],
                                          stops: const [0.33, 0.66, 1.0],
                                        ),
                                      );
                                    } else {
                                      decoration = BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Theme.of(context).primaryColor,
                                            hasEvents ? const Color(0xff6CB28E) : const Color(0xFFFF7043)
                                          ],
                                          stops: const [0.5, 0.5],
                                        ),
                                      );
                                    }
                                  } else {
                                    // Just today/selected with no events
                                    tileColor = Theme.of(context).primaryColor;
                                  }
                                }
                              }

                              // Always render with proper text color
                              return Container(
                                margin: const EdgeInsets.all(6),
                                decoration: decoration ?? (tileColor != null ? BoxDecoration(
                                  color: tileColor,
                                  borderRadius: BorderRadius.circular(4),
                                ) : null),
                                child: Center(
                                  child: Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      color: isPastDate
                                          ? Colors.grey[400] // Grey text for past dates
                                          : (tileColor != null || decoration != null)
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },

                            // Override selected and today builders to prevent default styling
                            selectedBuilder: (context, day, focusedDay) {
                              // Let defaultBuilder handle selected days
                              return null;
                            },

                            todayBuilder: (context, day, focusedDay) {
                              // Let defaultBuilder handle today
                              return null;
                            },

                            markerBuilder: (context, date, events) {
                              // Remove markers since we're using background colors instead
                              return const SizedBox.shrink();
                            },
                          ),
                        );
                      },
                      loading: () =>
                      const Center(child: CircularProgressIndicator()),
                      error: (error, stack) =>
                          Center(child: Text('Error: $error')),
                    ),
                    loading: () =>
                    const Center(child: CircularProgressIndicator()),
                    error: (error, stack) =>
                        Center(child: Text('Error: $error')),
                  );
                },
              ),
              const SizedBox(height: 30),
              // Upcoming items section - scrollable with deadlines and events
              SizedBox(
                height: 200, // Fixed height for scrollable area
                child: Scrollbar(
                  thumbVisibility: true,
                  thickness: 4,
                  radius: Radius.circular(2),
                  child: SingleChildScrollView(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Upcoming deadlines section
                      Builder(
                        builder: (context) {
                          final assignmentsAsync = ref.watch(monthAssignmentsProvider);

                          return assignmentsAsync.when(
                            data: (assignments) {
                              final now = DateTime.now();
                              // Filter assignments for upcoming deadlines (next 7 days)
                              final upcomingAssignments = assignments.where((assignment) {
                                final daysUntilDue = assignment.dueDate.difference(now).inDays;
                                return daysUntilDue >= 0 && daysUntilDue <= 7;
                              }).toList()
                                ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

                              if (upcomingAssignments.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  margin: const EdgeInsets.only(bottom: 16),
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

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4, bottom: 12),
                                    child: Text(
                                      'Upcoming Deadlines',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  ...upcomingAssignments.map((assignment) {
                                    final dueDate = assignment.dueDate;
                                    final formattedDate = DateFormat('EEEE, MMM d').format(dueDate);
                                    final daysUntil = dueDate.difference(now).inDays;
                                    
                                    String urgencyText;
                                    Color urgencyColor;
                                    if (daysUntil == 0) {
                                      urgencyText = 'Due Today!';
                                      urgencyColor = const Color(0xFFFF6B6B);
                                    } else if (daysUntil == 1) {
                                      urgencyText = 'Due Tomorrow!';
                                      urgencyColor = const Color(0xFFFF8A65);
                                    } else {
                                      urgencyText = 'Due in $daysUntil days';
                                      urgencyColor = const Color(0xFFFFB74D);
                                    }

                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      margin: const EdgeInsets.only(bottom: 12),
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
                                                Text(
                                                  urgencyText,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: urgencyColor,
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
                                                  '${assignment.subjectName ?? 'Subject'} ${assignment.title}',
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
                                              color: urgencyColor,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Estimated for: ${assignment.estimatedTime ?? 0}h',
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
                                  }),
                                ],
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (error, stack) => Center(child: Text('Error: $error')),
                          );
                        },
                      ),
                      
                      // Upcoming events section
                      Builder(
                        builder: (context) {
                          final eventsAsync = ref.watch(monthEventsProvider);

                          return eventsAsync.when(
                            data: (events) {
                              final now = DateTime.now();
                              final tomorrow = now.add(const Duration(days: 1));
                              
                              // Filter events for tomorrow only
                              final tomorrowEvents = events.where((event) {
                                final eventDate = DateTime(
                                  event.startDateTime.year,
                                  event.startDateTime.month,
                                  event.startDateTime.day,
                                );
                                final tomorrowDate = DateTime(
                                  tomorrow.year,
                                  tomorrow.month,
                                  tomorrow.day,
                                );
                                return eventDate.isAtSameMomentAs(tomorrowDate);
                              }).toList()
                                ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

                              if (tomorrowEvents.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  margin: const EdgeInsets.only(bottom: 16),
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
                                      'No events tomorrow',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4, bottom: 12),
                                    child: Text(
                                      'Tomorrow\'s Events',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  ...tomorrowEvents.map((event) {
                                    final startTime = DateFormat('HH:mm').format(event.startDateTime);
                                    final endTime = DateFormat('HH:mm').format(event.endDateTime);
                                    
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      margin: const EdgeInsets.only(bottom: 12),
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
                                                Text(
                                                  'Tomorrow Event',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color(0xff6CB28E),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  event.title,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                if (event.description?.isNotEmpty == true)
                                                  Text(
                                                    event.description!,
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
                                              color: const Color(0xff6CB28E),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '$startTime - $endTime',
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
                                  }).toList(),
                                ],
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
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const SpeedDialMenu(),
    );
  }
}