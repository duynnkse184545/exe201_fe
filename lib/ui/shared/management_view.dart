import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/assignment.dart';
import '../../model/event.dart';
import '../../provider/calendar_providers.dart';
import '../extra/header.dart';
import '../extra/speed_dial_menu.dart';
import '../calendar/calendar_theme.dart';

class ManagementView extends ConsumerWidget {
  const ManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final assignmentsAsync = ref.watch(assignmentsProvider);

    return Scaffold(
      appBar: const Header(title: 'Overview'),
      body: eventsAsync.when(
        data: (events) => assignmentsAsync.when(
          data: (assignments) {
            final combinedList = [...events, ...assignments];
            combinedList.sort((a, b) {
              final aDate = a is Event ? a.startDateTime : (a as Assignment).dueDate;
              final bDate = b is Event ? b.startDateTime : (b as Assignment).dueDate;
              return aDate.compareTo(bDate);
            });

            return ListView.builder(
              itemCount: combinedList.length,
              itemBuilder: (context, index) {
                final item = combinedList[index];
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: const SpeedDialMenu(),
    );
  }
} 