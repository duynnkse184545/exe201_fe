import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../model/event_category/event_category.dart';
import '../../../../model/subject/subject.dart';
import '../../../../provider/calendar_providers.dart';
import '../../../../provider/service_providers.dart';
import '../../../extra/custom_dialog.dart';
import '../../../extra/header.dart';
import '../../calendar_theme.dart';


class CategoriesSubjectsManagementView extends ConsumerStatefulWidget {
  const CategoriesSubjectsManagementView({super.key});

  @override
  ConsumerState<CategoriesSubjectsManagementView> createState() => _CategoriesSubjectsManagementViewState();
}

class _CategoriesSubjectsManagementViewState extends ConsumerState<CategoriesSubjectsManagementView> with TickerProviderStateMixin {
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

  Future<void> _createOrEditCategory({EventCategory? existing}) async {
    final nameController = TextEditingController(text: existing?.categoryName ?? '');
    final descController = TextEditingController(text: existing?.description ?? '');

    await showCustomBottomSheet(
      context: context,
      title: existing == null ? 'Add event category' : 'Edit event category',
      content: Column(
        children: [
          TextField(decoration: const InputDecoration(labelText: 'Name'), controller: nameController),
          const SizedBox(height: 12),
          TextField(decoration: const InputDecoration(labelText: 'Description'), controller: descController),
        ],
      ),
      actionText: existing == null ? 'Save' : 'Update',
      actionColor: CalendarTheme.primaryColor,
      onActionPressed: () async {
        final name = nameController.text.trim();
        if (name.isEmpty) return;
        if (existing == null) {
          await ref.read(eventCategoryServiceProvider).create<EventCategory>(EventCategory(evCategoryId: '', categoryName: name, description: descController.text.trim().isEmpty ? null : descController.text.trim(), userId: ''));
        } else {
          final updated = existing.copyWith(categoryName: name, description: descController.text.trim().isEmpty ? null : descController.text.trim());
          await ref.read(eventCategoryServiceProvider).update<EventCategory>(updated);
        }
        ref.invalidate(eventCategoriesProvider);
        if (mounted) Navigator.of(context).pop();
      },
    );
  }

  Future<void> _confirmDeleteCategory(EventCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete category'),
        content: Text('Delete "${category.categoryName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(eventCategoryServiceProvider).delete(category.evCategoryId);
      ref.invalidate(eventCategoriesProvider);
    }
  }

  Future<void> _createOrEditSubject({Subject? existing}) async {
    final nameController = TextEditingController(text: existing?.subjectName ?? '');
    final descController = TextEditingController(text: existing?.description ?? '');

    await showCustomBottomSheet(
      context: context,
      title: existing == null ? 'Add subject' : 'Edit subject',
      content: Column(
        children: [
          TextField(decoration: const InputDecoration(labelText: 'Name'), controller: nameController),
          const SizedBox(height: 12),
          TextField(decoration: const InputDecoration(labelText: 'Description'), controller: descController),
        ],
      ),
      actionText: existing == null ? 'Save' : 'Update',
      actionColor: CalendarTheme.secondaryColor,
      onActionPressed: () async {
        final name = nameController.text.trim();
        if (name.isEmpty) return;
        if (existing == null) {
          await ref.read(subjectServiceProvider).create<Subject>(Subject(subjectId: '', subjectName: name, description: descController.text.trim().isEmpty ? null : descController.text.trim(), userId: ''));
        } else {
          final updated = existing.copyWith(subjectName: name, description: descController.text.trim().isEmpty ? null : descController.text.trim());
          await ref.read(subjectServiceProvider).update<Subject>(updated);
        }
        ref.invalidate(subjectsProvider);
        if (mounted) Navigator.of(context).pop();
      },
    );
  }

  Future<void> _confirmDeleteSubject(Subject subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete subject'),
        content: Text('Delete "${subject.subjectName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(subjectServiceProvider).delete(subject.subjectId);
      ref.invalidate(subjectsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(eventCategoriesProvider);
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: const Header(title: 'Categories & Subjects'),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: CalendarTheme.textColor,
            tabs: const [
              Tab(text: 'Event Categories'),
              Tab(text: 'Subjects'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: categoriesAsync.when(
                    data: (categories) => ListView(
                      children: categories.map((c) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.folder, color: CalendarTheme.primaryColor),
                          title: Text(c.categoryName),
                          subtitle: c.description != null && c.description!.isNotEmpty ? Text(c.description!) : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(tooltip: 'Edit', icon: const Icon(Icons.edit, size: 20), onPressed: () => _createOrEditCategory(existing: c)),
                              IconButton(tooltip: 'Delete', icon: const Icon(Icons.delete, size: 20), onPressed: () => _confirmDeleteCategory(c)),
                            ],
                          ),
                        ),
                      )).toList(),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: subjectsAsync.when(
                    data: (subjects) => ListView(
                      children: subjects.map((s) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.book_outlined, color: CalendarTheme.secondaryColor),
                          title: Text(s.subjectName),
                          subtitle: s.description != null && s.description!.isNotEmpty ? Text(s.description!) : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(tooltip: 'Edit', icon: const Icon(Icons.edit, size: 20), onPressed: () => _createOrEditSubject(existing: s)),
                              IconButton(tooltip: 'Delete', icon: const Icon(Icons.delete, size: 20), onPressed: () => _confirmDeleteSubject(s)),
                            ],
                          ),
                        ),
                      )).toList(),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                  ),
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
                if (_tabController.index == 0) {
                  _createOrEditCategory();
                } else {
                  _createOrEditSubject();
                }
              },
              icon: const Icon(Icons.add),
              label: Text(_tabController.index == 0 ? 'Add event category' : 'Add subject'),
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
