import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/calendar_providers.dart';
import '../extra/header.dart';
import '../calendar/calendar_theme.dart';
import '../add_edit/add_edit_view.dart';
import '../../provider/service_providers.dart';
import 'event_detail_card.dart';
import 'assignment_detail_card.dart';

class ManagementView extends ConsumerStatefulWidget {
  const ManagementView({super.key});

  @override
  ConsumerState<ManagementView> createState() => _ManagementViewState();
}

class _ManagementViewState extends ConsumerState<ManagementView> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
  }

  String _fmtFull(DateTime dt) {
    final d = '${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}';
    final t = '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    return '$d $t';
  }

  Future<bool> _confirm(BuildContext context, String msg) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    return res ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);
    final assignmentsAsync = ref.watch(assignmentsProvider);

    return Scaffold(
      appBar: const Header(title: 'Overview'),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: CalendarTheme.textColor,
            tabs: const [Tab(text: 'Events'), Tab(text: 'Assignments')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                eventsAsync.when(
                  data: (events) => ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final item = events[index];
                      return _ExpandableTile(
                        leadingIcon: const Icon(Icons.event, color: CalendarTheme.primaryColor),
                        title: item.title,
                        subtitle: '${item.categoryName ?? ''} • ${_fmtFull(item.startDateTime)} - ${_fmtFull(item.endDateTime)}',
                        details: EventDetailCard(event: item),
                        onEdit: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditView()));
                          if (!mounted) return;
                          ref.invalidate(eventsProvider);
                        },
                        onDelete: () async {
                          final ok = await _confirm(context, 'Delete this event?');
                          if (!ok) return;
                          try {
                            await ref.read(eventServiceProvider).delete(item.eventId!);
                            ref.invalidate(eventsProvider);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event deleted')));
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                          }
                        },
                      );
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
                assignmentsAsync.when(
                  data: (assignments) => ListView.builder(
                    itemCount: assignments.length,
                    itemBuilder: (context, index) {
                      final item = assignments[index];
                      return _ExpandableTile(
                        leadingIcon: const Icon(Icons.assignment, color: CalendarTheme.secondaryColor),
                        title: item.title,
                        subtitle: '${item.subjectName ?? ''} • ${item.priorityName ?? ''} • ${_fmtFull(item.dueDate)}',
                        details: AssignmentDetailCard(assignment: item),
                        onEdit: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditView()));
                          if (!mounted) return;
                          ref.invalidate(assignmentsProvider);
                        },
                        onDelete: () async {
                          final ok = await _confirm(context, 'Delete this assignment?');
                          if (!ok) return;
                          try {
                            await ref.read(assignmentServiceProvider).delete(item.assignmentId!);
                            ref.invalidate(assignmentsProvider);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assignment deleted')));
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                          }
                        },
                      );
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditView()),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(_tabController.index == 0 ? 'Add Event' : 'Add Assignment'),
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
}

class _ExpandableTile extends StatefulWidget {
  final Widget leadingIcon;
  final String title;
  final String subtitle;
  final Widget details;
  final Future<void> Function()? onEdit;
  final Future<void> Function()? onDelete;
  const _ExpandableTile({
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.details,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<_ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<_ExpandableTile> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        children: [
          ListTile(
            leading: widget.leadingIcon,
            title: Text(widget.title),
            subtitle: Text(widget.subtitle),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.edit), onPressed: widget.onEdit),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: widget.onDelete),
              IconButton(icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more), onPressed: () => setState(() => _expanded = !_expanded)),
            ]),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: widget.details,
            ),
        ],
      ),
    );
  }
}
