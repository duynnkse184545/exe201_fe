import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/assignment.dart';
import '../model/event.dart';
import '../model/event_category.dart';
import '../model/subject.dart';
import '../model/priority_level.dart';
import 'service_providers.dart';

part 'calendar_providers.g.dart';

// Provider for the currently selected month
@riverpod
class SelectedMonth extends _$SelectedMonth {
  @override
  DateTime build() {
    return DateTime.now();
  }

  void setMonth(DateTime month) {
    state = DateTime(month.year, month.month, 1);
  }
}

// Provider for events in the current month
@riverpod
Future<List<Event>> monthEvents(MonthEventsRef ref) async {
  // Instead of watching the selectedMonth provider directly,
  // we'll use it only when needed to avoid unnecessary rebuilds
  final selectedMonth = ref.read(selectedMonthProvider);
  
  try {
    final startDate = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final endDate = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    
    // Get events directly from service (which now returns mock data)
    return ref.watch(eventServiceProvider).getEventsForDateRange(startDate, endDate);
  } catch (e) {
    print('Error fetching events: $e');
    // Return empty list on error
    return [];
  }
}

// Provider for assignments in the current month
@riverpod
Future<List<Assignment>> monthAssignments(MonthAssignmentsRef ref) async {
  // Instead of watching the selectedMonth provider directly,
  // we'll use it only when needed to avoid unnecessary rebuilds
  final selectedMonth = ref.read(selectedMonthProvider);
  
  try {
    final endDate = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    
    // Get assignments directly from service (which now returns mock data)
    return ref.watch(assignmentServiceProvider).getUpcomingAssignments(endDate);
  } catch (e) {
    print('Error fetching assignments: $e');
    // Return empty list on error
    return [];
  }
}

// Provider for all events (used in management view)
@riverpod
Future<List<Event>> events(EventsRef ref) async {
  final events = await ref.watch(eventServiceProvider).getAll();
  final categories = await ref.watch(eventCategoriesProvider.future);
  final catMap = {for (final c in categories) c.evCategoryId!: c.categoryName};
  return events
      .map((e) => e.copyWith(categoryName: e.categoryName ?? catMap[e.evCategoryId]))
      .toList();
}

// Provider for all assignments (used in management view)
@riverpod
Future<List<Assignment>> assignments(AssignmentsRef ref) async {
  final items = await ref.watch(assignmentServiceProvider).getAll();
  final subjects = await ref.watch(subjectsProvider.future);
  final priorities = await ref.watch(prioritiesProvider.future);
  final subjMap = {for (final s in subjects) s.subjectId!: s.subjectName};
  final priMap = {for (final p in priorities) p.priorityId!: p.levelName};
  return items
      .map((a) => a.copyWith(
            subjectName: a.subjectName ?? subjMap[a.subjectId],
            priorityName: a.priorityName ?? priMap[a.priorityId],
          ))
      .toList();
}

// Provider for all event categories
@riverpod
Future<List<EventCategory>> eventCategories(EventCategoriesRef ref) async {
  return ref.watch(eventCategoryServiceProvider).getAll();
}

// Provider for all subjects
@riverpod
Future<List<Subject>> subjects(SubjectsRef ref) async {
  return ref.watch(subjectServiceProvider).getAll();
}

// Provider for priorities (readonly)
@riverpod
Future<List<PriorityLevel>> priorities(PrioritiesRef ref) async {
  return ref.watch(priorityLevelServiceProvider).getAll();
}

// Provider for the selected day
@riverpod
class SelectedDay extends _$SelectedDay {
  @override
  DateTime build() {
    return DateTime.now();
  }

  void setDay(DateTime day) {
    state = day;
  }
}

// Provider for events on the selected day
@riverpod
Future<List<Event>> dayEvents(DayEventsRef ref) async {
  final selectedDay = ref.watch(selectedDayProvider);
  final events = await ref.watch(monthEventsProvider.future);
  
  return events.where((event) => 
    event.startDateTime.year == selectedDay.year &&
    event.startDateTime.month == selectedDay.month &&
    event.startDateTime.day == selectedDay.day
  ).toList();
}

// Provider for assignments due on the selected day
@riverpod
Future<List<Assignment>> dayAssignments(DayAssignmentsRef ref) async {
  final selectedDay = ref.watch(selectedDayProvider);
  final assignments = await ref.watch(monthAssignmentsProvider.future);
  
  return assignments.where((assignment) => 
    assignment.dueDate.year == selectedDay.year &&
    assignment.dueDate.month == selectedDay.month &&
    assignment.dueDate.day == selectedDay.day
  ).toList();
} 