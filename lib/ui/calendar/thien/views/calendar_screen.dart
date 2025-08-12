import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../provider/calendar_providers.dart' as cal;
import '../../../extra/header.dart';
import '../../../extra/speed_dial_menu.dart';
import '../../calendar_theme.dart';
import 'day_detail_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(cal.selectedDayProvider);
    final eventsAsync = ref.watch(cal.eventsProvider);
    final assignmentsAsync = ref.watch(cal.assignmentsProvider);

    return Scaffold(
      appBar: const Header(title: 'Calendar'),
      body: Column(
        children: [
          // Calendar widget
          Container(
            margin: const EdgeInsets.all(16),
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
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(selectedDate, day),
              eventLoader: (day) {
                final events = ref.read(cal.dayEventsProvider).value ?? [];
                final assignments = ref.read(cal.dayAssignmentsProvider).value ?? [];
                return [...events, ...assignments];
              },
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                selectedDecoration: const BoxDecoration(
                  color: CalendarTheme.accentColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: const BoxDecoration(
                  color: CalendarTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: CalendarTheme.secondaryColor,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
                markerSize: CalendarTheme.indicatorSize,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: CalendarTheme.primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                formatButtonTextStyle: TextStyle(
                  color: Colors.white,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                ref.read(cal.selectedDayProvider.notifier).state = selectedDay;
                setState(() {
                  _focusedDay = focusedDay;
                });
                
                // Navigate to day detail view
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DayDetailScreen(selectedDate: selectedDay),
                  ),
                );
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
            ),
          ),
          
          // Quick overview section
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today\'s Overview',
                    style: CalendarTheme.titleStyle,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: eventsAsync.when(
                      data: (events) => assignmentsAsync.when(
                        data: (assignments) {
                          final todayEvents = ref.watch(cal.dayEventsProvider).value ?? [];
                          final todayAssignments = ref.watch(cal.dayAssignmentsProvider).value ?? [];
                          
                          if (todayEvents.isEmpty && todayAssignments.isEmpty) {
                            return const Center(
                              child: Text(
                                'No events or assignments for today',
                                style: CalendarTheme.subtitleStyle,
                              ),
                            );
                          }
                          
                          return ListView(
                            children: [
                              ...todayEvents.map((event) => Card(
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
                                  subtitle: Text(
                                    '${event.startDateTime.hour.toString().padLeft(2, '0')}:${event.startDateTime.minute.toString().padLeft(2, '0')} - ${event.endDateTime.hour.toString().padLeft(2, '0')}:${event.endDateTime.minute.toString().padLeft(2, '0')}',
                                  ),
                                  trailing: const Icon(Icons.event),
                                ),
                              )),
                              ...todayAssignments.map((assignment) => Card(
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
                                  subtitle: Text('Due: ${assignment.dueDate.day}/${assignment.dueDate.month}'),
                                  trailing: const Icon(Icons.assignment),
                                ),
                              )),
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
            ),
          ),
        ],
      ),
      floatingActionButton: const SpeedDialMenu(),
    );
  }
}