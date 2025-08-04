import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../model/assignment.dart';
import '../../model/event.dart';
import '../../provider/calendar_providers.dart';
import '../extra/header.dart';
import 'calendar_theme.dart';

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  late final ValueNotifier<List<dynamic>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final events = ref.watch(eventsProvider).asData?.value ?? [];
    final assignments = ref.watch(assignmentsProvider).asData?.value ?? [];
    
    final eventsForDay = events.where((event) => isSameDay(event.startDateTime, day)).toList();
    final assignmentsForDay = assignments.where((assignment) => isSameDay(assignment.dueDate, day)).toList();

    return [...eventsForDay, ...assignmentsForDay];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: 'Calendar'),
      body: Column(
        children: [
          _buildTableCalendar(),
          const SizedBox(height: 8.0),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  Widget _buildTableCalendar() {
    final events = ref.watch(eventsProvider);
    final assignments = ref.watch(assignmentsProvider);

    return events.when(
      data: (eventData) => assignments.when(
        data: (assignmentData) {
          return TableCalendar<dynamic>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: CalendarTheme.accentColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: CalendarTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: CalendarTheme.secondaryColor,
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildEventList() {
    return ValueListenableBuilder<List<dynamic>>(
      valueListenable: _selectedEvents,
      builder: (context, value, _) {
        return ListView.builder(
          itemCount: value.length,
          itemBuilder: (context, index) {
            final item = value[index];
            if (item is Event) {
              return ListTile(
                title: Text(item.title),
                subtitle: Text('Event at ${item.startDateTime.hour}:${item.startDateTime.minute}'),
                leading: const Icon(Icons.event, color: CalendarTheme.primaryColor),
              );
            }
            if (item is Assignment) {
              return ListTile(
                title: Text(item.title),
                subtitle: Text('Due on ${item.dueDate.toLocal()}'),
                leading: const Icon(Icons.assignment, color: CalendarTheme.secondaryColor),
              );
            }
            return Container();
          },
        );
      },
    );
  }
}