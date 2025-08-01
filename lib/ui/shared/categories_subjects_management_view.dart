import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/calendar_providers.dart';
import '../extra/header.dart';
import '../calendar/calendar_theme.dart';

class CategoriesSubjectsManagementView extends ConsumerWidget {
  const CategoriesSubjectsManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(eventCategoriesProvider);
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: const Header(title: 'Categories & Subjects'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Event Categories Section
          const Text('Event Categories', style: CalendarTheme.titleStyle),
          const SizedBox(height: 8),
          categoriesAsync.when(
            data: (categories) => Column(
              children: categories.map((c) => Card(
                child: ListTile(
                  leading: const Icon(Icons.folder, color: CalendarTheme.primaryColor),
                  title: Text(c.categoryName),
                  subtitle: c.description != null && c.description!.isNotEmpty
                      ? Text(c.description!)
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Tooltip(message: 'Edit Category', child: Icon(Icons.edit, size: 20)),
                      SizedBox(width: 8),
                      Tooltip(message: 'Delete Category', child: Icon(Icons.delete, size: 20)),
                    ],
                  ),
                ),
              )).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),

          const SizedBox(height: 24),

          // Subjects Section
          const Text('Subjects', style: CalendarTheme.titleStyle),
          const SizedBox(height: 8),
          subjectsAsync.when(
            data: (subjects) => Column(
              children: subjects.map((s) => Card(
                child: ListTile(
                  leading: const Icon(Icons.book_outlined, color: CalendarTheme.secondaryColor),
                  title: Text(s.subjectName),
                  subtitle: s.description != null && s.description!.isNotEmpty
                      ? Text(s.description!)
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Tooltip(message: 'Edit Subject', child: Icon(Icons.edit, size: 20)),
                      SizedBox(width: 8),
                      Tooltip(message: 'Delete Subject', child: Icon(Icons.delete, size: 20)),
                    ],
                  ),
                ),
              )).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }
}
