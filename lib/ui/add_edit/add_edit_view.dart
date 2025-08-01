import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../calendar/calendar_theme.dart';
import '../../provider/calendar_providers.dart';
import '../../model/event_category.dart';
import '../../model/subject.dart';

class AddEditView extends ConsumerStatefulWidget {
  const AddEditView({super.key});

  @override
  ConsumerState<AddEditView> createState() => _AddEditViewState();
}

class _AddEditViewState extends ConsumerState<AddEditView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add/Edit'),
        backgroundColor: CalendarTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Event'),
            Tab(text: 'Assignment'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Event form will go here
          _buildEventForm(),
          // Assignment form will go here
          _buildAssignmentForm(),
        ],
      ),
    );
  }
  
  Widget _buildEventForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          // We'll use a simple text field for now and add a date picker later
          TextFormField(
            decoration: const InputDecoration(labelText: 'Start Date & Time'),
          ),
          const SizedBox(height: 16),
          // We'll use a simple text field for now and add a date picker later
          TextFormField(
            decoration: const InputDecoration(labelText: 'End Date & Time'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Recurrence'),
            items: ['Daily', 'Weekly', 'Monthly', 'Yearly', 'None']
                .map((label) => DropdownMenuItem(
                      value: label,
                      child: Text(label),
                    ))
                .toList(),
            onChanged: (value) {},
          ),
          const SizedBox(height: 16),
          // Use a Consumer to get the event categories
          Consumer(
            builder: (context, ref, child) {
              final categoriesAsync = ref.watch(eventCategoriesProvider);
              
              return categoriesAsync.when(
                data: (categories) {
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category.evCategoryId,
                        child: Text(category.categoryName),
                      );
                    }).toList(),
                    onChanged: (value) {},
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              );
            },
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  // Save logic will go here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E81F4), // Blue
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAssignmentForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          // We'll use a simple text field for now and add a date picker later
          TextFormField(
            decoration: const InputDecoration(labelText: 'Due Date'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Priority'),
            items: ['High', 'Medium', 'Low']
                .map((label) => DropdownMenuItem(
                      value: label,
                      child: Text(label),
                    ))
                .toList(),
            onChanged: (value) {},
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Estimated Time (minutes)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          // Use a Consumer to get the subjects
          Consumer(
            builder: (context, ref, child) {
              final subjectsAsync = ref.watch(subjectsProvider);
              
              return subjectsAsync.when(
                data: (subjects) {
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Subject'),
                    items: subjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject.subjectId,
                        child: Text(subject.subjectName),
                      );
                    }).toList(),
                    onChanged: (value) {},
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              );
            },
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  // Save logic will go here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E81F4), // Blue
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}