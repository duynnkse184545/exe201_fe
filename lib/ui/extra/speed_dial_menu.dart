import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../calendar/calendar_theme.dart';
import '../calendar/thien/views/categories_subjects_management_view.dart';
import '../calendar/thien/views/management_view.dart';
import '../calendar/widgets/deadline_dialog.dart';
import '../calendar/widgets/event_dialog.dart';
import 'ai_create_dialog.dart';

class SpeedDialMenu extends StatelessWidget {
  const SpeedDialMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: CalendarTheme.primaryColor,
      foregroundColor: Colors.white,
      activeBackgroundColor: CalendarTheme.secondaryColor,
      activeForegroundColor: Colors.white,
      buttonSize: const Size(56.0, 56.0),
      visible: true,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.schedule),
          backgroundColor: CalendarTheme.accentColor,
          label: 'Add Deadline',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () {
            DeadlineDialog.show(context);
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.event),
          backgroundColor: CalendarTheme.accentColor,
          label: 'Add Event',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () {
            EventDialog.show(context);
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.event_note),
          backgroundColor: CalendarTheme.accentColor,
          label: 'Day Detail View',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () {
            // For now just show a snackbar since we haven't implemented the day detail view yet
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Day Detail View coming soon!')),
            );
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.list),
          backgroundColor: CalendarTheme.accentColor,
          label: 'Management View',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ManagementView()),
            );
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.category),
          backgroundColor: CalendarTheme.accentColor,
          label: 'Categories & Subjects',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CategoriesSubjectsManagementView()),
            );
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.auto_awesome),
          backgroundColor: CalendarTheme.accentColor,
          label: 'AI Create',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () async {
            final updated = await showDialog<bool>(
              context: context,
              builder: (_) => const AICreateDialog(),
            );
            if (updated == true) {
              // No history; just refresh screens when returning to lists if needed.
            }
          },
        ),
      ],
    );
  }
} 