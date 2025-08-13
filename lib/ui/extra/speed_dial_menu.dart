import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../calendar/calendar_theme.dart';
import '../calendar/widgets/deadline_dialog.dart';
import '../calendar/widgets/event_dialog.dart';
import 'ai_create_dialog.dart';
import '../../provider/providers.dart';

class SpeedDialMenu extends ConsumerWidget {
  const SpeedDialMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasInvoice = ref.watch(hasUserInvoiceProvider);
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      activeBackgroundColor: CalendarTheme.secondaryColor,
      activeForegroundColor: Colors.white,
      buttonSize: const Size(56.0, 56.0),
      visible: true,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.schedule),
          backgroundColor: CalendarTheme.deadline,
          label: 'Add Deadline',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () {
            DeadlineDialog.show(context);
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.event),
          backgroundColor: CalendarTheme.event,
          label: 'Add Event',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () {
            EventDialog.show(context);
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.auto_awesome),
          backgroundColor: CalendarTheme.secondaryColor,
          label: 'AI Create',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () async {
            if (!hasInvoice) {
              // Show popup asking user to update plan
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Upgrade Required'),
                    content: const Text('Please update your plan to access AI features.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
              return;
            }
            
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