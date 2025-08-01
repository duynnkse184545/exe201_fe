import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../shared/management_view.dart';
import '../shared/categories_subjects_management_view.dart';
import '../calendar/calendar_theme.dart';
import '../add_edit/add_edit_view.dart';

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
          child: const Icon(Icons.add_task),
          backgroundColor: CalendarTheme.accentColor,
          label: 'Add/Edit',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddEditView()),
            );
          },
        ),
      ],
    );
  }
} 