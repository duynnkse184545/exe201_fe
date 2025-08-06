import 'package:exe201/model/assignment/assignment.dart';
import 'package:exe201/model/event/event.dart';
import 'package:exe201/ui/budget/widgets/balance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../provider/calendar_providers.dart';
import '../../../../provider/service_providers.dart';
import '../../calendar_theme.dart';


class AddEditView extends ConsumerStatefulWidget {
  final Map<String, dynamic>? eventData;
  final Map<String, dynamic>? assignmentData;
  const AddEditView({super.key, this.eventData, this.assignmentData});

  @override
  ConsumerState<AddEditView> createState() => _AddEditViewState();
}

class _AddEditViewState extends ConsumerState<AddEditView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _selectedRecurrence = 'None';
  final _recEndDate = TextEditingController(text: 'dd/MM/yyyy');
  final _recEndTime = TextEditingController(text: 'HH:mm');

  final _eventTitle = TextEditingController();
  final _eventDesc = TextEditingController();
  final _eventStartDate = TextEditingController(text: 'dd/MM/yyyy');
  final _eventStartTime = TextEditingController(text: 'HH:mm');
  final _eventEndDate = TextEditingController(text: 'dd/MM/yyyy');
  final _eventEndTime = TextEditingController(text: 'HH:mm');

  final _assTitle = TextEditingController();
  final _assDesc = TextEditingController();
  final _assDueDate = TextEditingController(text: 'dd/MM/yyyy');
  final _assDueTime = TextEditingController(text: 'HH:mm');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() { if (mounted) setState(() {}); });

    if (widget.eventData != null) {
      final e = widget.eventData!;
      _tabController.index = 0;
      _eventTitle.text = e['title'] ?? '';
      _eventDesc.text = e['description'] ?? '';
      final sd = DateTime.parse(e['startDateTime'] as String);
      final ed = DateTime.parse(e['endDateTime'] as String);
      _eventStartDate.text = _fmtDate(sd);
      _eventStartTime.text = _fmtTime(sd);
      _eventEndDate.text = _fmtDate(ed);
      _eventEndTime.text = _fmtTime(ed);
      _selectedCategoryId = e['evCategoryId'] as String?;
      _selectedRecurrence = (e['recurrencePattern'] ?? 'none').toString().capitalize();
    }

    if (widget.assignmentData != null) {
      final a = widget.assignmentData!;
      _tabController.index = 1;
      _assTitle.text = a['title'] ?? '';
      _assDesc.text = a['description'] ?? '';
      final due = DateTime.parse(a['dueDate'] as String);
      _assDueDate.text = _fmtDate(due);
      _assDueTime.text = _fmtTime(due);
      _selectedSubjectId = a['subjectId'] as String?;
      _selectedPriorityId = a['priorityId'] as int?;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required TextEditingController dateCtrl, required TextEditingController timeCtrl}) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
    );
    if (time == null) return;
    dateCtrl.text = '${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year}';
    timeCtrl.text = '${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}';
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
          _buildEventForm(),
          _buildAssignmentForm(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (_tabController.index == 0) {
                  await _submitEvent();
                } else {
                  await _submitAssignment();
                }
              },
              icon: const Icon(Icons.save),
              label: Text(_tabController.index == 0 ? 'Save Event' : 'Save Assignment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _tabController.index == 0 ? CalendarTheme.primaryColor : CalendarTheme.secondaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _rowDateTime({required String label, required TextEditingController dateCtrl, required TextEditingController timeCtrl}) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: dateCtrl,
            readOnly: true,
            decoration: InputDecoration(
              labelText: label,
              hintText: 'dd/MM/yyyy',
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _pickDateTime(dateCtrl: dateCtrl, timeCtrl: timeCtrl),
              ),
            ),
            onTap: () => _pickDateTime(dateCtrl: dateCtrl, timeCtrl: timeCtrl),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 110,
          child: TextFormField(
            controller: timeCtrl,
            readOnly: true,
            decoration: const InputDecoration(labelText: 'Time', hintText: 'HH:mm'),
            onTap: () => _pickDateTime(dateCtrl: dateCtrl, timeCtrl: timeCtrl),
          ),
        ),
      ],
    );
  }

  Widget _buildEventForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(controller: _eventTitle, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 16),
          TextFormField(controller: _eventDesc, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
          const SizedBox(height: 16),
          _rowDateTime(label: 'Start Date', dateCtrl: _eventStartDate, timeCtrl: _eventStartTime),
          const SizedBox(height: 16),
          _rowDateTime(label: 'End Date', dateCtrl: _eventEndDate, timeCtrl: _eventEndTime),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              final categoriesAsync = ref.watch(eventCategoriesProvider);
              return categoriesAsync.when(
                data: (categories) => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories.map((c) => DropdownMenuItem(value: c.evCategoryId, child: Text(c.categoryName))).toList(),
                  onChanged: (v) { _selectedCategoryId = v; },
                  value: _selectedCategoryId,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              );
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Recurrence Pattern'),
            items: const [
              DropdownMenuItem(value: 'None', child: Text('None')),
              DropdownMenuItem(value: 'Daily', child: Text('Daily')),
              DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
              DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
              DropdownMenuItem(value: 'Yearly', child: Text('Yearly')),
            ],
            onChanged: (v) {
              setState(() {
                _selectedRecurrence = v ?? 'None';
              });
            },
            value: _selectedRecurrence,
          ),
          if (_selectedRecurrence != 'None') ...[
            const SizedBox(height: 16),
            _rowDateTime(label: 'Recurrence End Date', dateCtrl: _recEndDate, timeCtrl: _recEndTime),
          ],
        ],
      ),
    );
  }

  Widget _buildAssignmentForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(controller: _assTitle, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 16),
          TextFormField(controller: _assDesc, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
          const SizedBox(height: 16),
          _rowDateTime(label: 'Due Date', dateCtrl: _assDueDate, timeCtrl: _assDueTime),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              final subjectsAsync = ref.watch(subjectsProvider);
              return subjectsAsync.when(
                data: (subjects) => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Subject'),
                  items: subjects.map((s) => DropdownMenuItem(value: s.subjectId, child: Text(s.subjectName))).toList(),
                  onChanged: (v) { _selectedSubjectId = v; },
                  value: _selectedSubjectId,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              );
            },
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              final prioritiesAsync = ref.watch(prioritiesProvider);
              return prioritiesAsync.when(
                data: (priorities) => DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: priorities.map((p) => DropdownMenuItem(value: p.priorityId!, child: Text(p.levelName ?? ''))).toList(),
                  onChanged: (v) { _selectedPriorityId = v; },
                  value: _selectedPriorityId,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              );
            },
          ),
        ],
      ),
    );
  }

  String? _selectedSubjectId;
  int? _selectedPriorityId;
  String? _selectedCategoryId;

  Future<void> _submitEvent() async { final isEdit = widget.eventData != null;
    try {
      final start = _parseDateTime(_eventStartDate.text, _eventStartTime.text);
      final end = _parseDateTime(_eventEndDate.text, _eventEndTime.text);
      final recEnd = _selectedRecurrence != 'None' ? _parseDateTime(_recEndDate.text, _recEndTime.text) : null;
      final payload = {
        'title': _eventTitle.text,
        'description': _eventDesc.text,
        'startDateTime': start.toIso8601String(),
        'endDateTime': end.toIso8601String(),
        'recurrencePattern': (_selectedRecurrence).toLowerCase(),
        'recurrenceEndDate': recEnd?.toIso8601String().split('T').first,
        'evCategoryId': _selectedCategoryId,
      };
      if (isEdit) {
        final id = widget.eventData!['eventId'];
        final body = Map<String, dynamic>.from(payload)..['eventId'] = id;
        if (body['recurrenceEndDate'] == null) { body.remove('recurrenceEndDate'); }
        debugPrint('Event update req: $body');
        await ref.read(eventServiceProvider).updateEvent(body as EventRequest);
      } else {
        debugPrint('Event create req: $payload');
        await ref.read(eventServiceProvider).create<Map<String, dynamic>>(payload);
      }
      ref.invalidate(eventsProvider);
      ref.invalidate(monthEventsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Event updated' : 'Event created')));
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Event submit error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add event: $e')));
    }
  }

  Future<void> _submitAssignment() async { final isEdit = widget.assignmentData != null;
    try {
      final due = _parseDateTime(_assDueDate.text, _assDueTime.text);
      final payload = {
        'title': _assTitle.text,
        'description': _assDesc.text,
        'dueDate': due.toIso8601String(),
        'status': widget.assignmentData?['status'] ?? 'in_progress',
        'subjectId': _selectedSubjectId,
        'priorityId': _selectedPriorityId,
        'estimatedTime': 0,
      };
      if (isEdit) {
        final id = widget.assignmentData!['assignmentId'];
        final body = Map<String, dynamic>.from(payload)..['assignmentId'] = id;
        debugPrint('Assignment update req: $body');
        await ref.read(assignmentServiceProvider).updateAssignment(body as AssignmentRequest);
      } else {
        debugPrint('Assignment create req: $payload');
        await ref.read(assignmentServiceProvider).create<Map<String, dynamic>>(payload);
      }
      ref.invalidate(assignmentsProvider);
      ref.invalidate(monthAssignmentsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Assignment updated' : 'Assignment created')));
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Assignment submit error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add assignment: $e')));
    }
  }

  String _fmtDate(DateTime d){return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';}
  String _fmtTime(DateTime d){return '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';}

  DateTime _parseDateTime(String d, String t) {
    final parts = d.split('/');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    final tp = t.split(':');
    final hour = int.parse(tp[0]);
    final minute = int.parse(tp[1]);
    return DateTime(year, month, day, hour, minute);
  }
}
