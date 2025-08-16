import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/service_providers.dart';
import '../calendar/calendar_theme.dart';

class AICreateDialog extends ConsumerStatefulWidget {
  const AICreateDialog({super.key});

  @override
  ConsumerState<AICreateDialog> createState() => _AICreateDialogState();
}

class _AICreateDialogState extends ConsumerState<AICreateDialog> {
  final _prompt = TextEditingController();
  bool _loading = false;
  List<Map<String, dynamic>> _options = [];
  String? _conversationId;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('AI Create', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _prompt,
                decoration: InputDecoration(
                  hintText: 'Describe what you want to create...',
                  prefixIcon: const Icon(Icons.chat_bubble_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (_) => _generate(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate'),
                  onPressed: _loading ? null : _generate,
                  style: ElevatedButton.styleFrom(backgroundColor: CalendarTheme.secondaryColor, foregroundColor: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _options.isEmpty
                        ? const Center(child: Text('Enter a prompt and tap Generate'))
                        : ListView.separated(
                            itemCount: _options.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final o = _options[i]['option'] as Map<String, dynamic>;
                              final type = (o['type'] as String).toLowerCase();
                              return Card(
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getOptionColor(type), 
                                            borderRadius: BorderRadius.circular(12)
                                          ),
                                          child: Text(type.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                        const Spacer(),
                                        Text('${_validateEstimatedTime(o['estimatedTimeMinutes'], o['type'])} min', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ]),
                                      const SizedBox(height: 8),
                                      Text(o['title'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      if ((o['description'] ?? '').toString().isNotEmpty) Text(o['description']),
                                      const SizedBox(height: 10),
                                      // Only show create button for actual creatable items (not suggestions/help)
                                      if (_isCreatableOption(o))
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () => _create(o),
                                            style: ElevatedButton.styleFrom(backgroundColor: type == 'assignment' ? Colors.blue : Colors.green, foregroundColor: Colors.white),
                                            child: Text('Create $type'),
                                          ),
                                        )
                                      else
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey[300]!),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.info_outline, color: Colors.grey[600], size: 16),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Guidance Only',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generate() async {
    final msg = _prompt.text.trim();
    if (msg.isEmpty) return;
    setState(() { _loading = true; _options = []; });
    try {
      final resp = await ref.read(aiServiceProvider).generateOptions(msg);
      final list = (resp['options'] as List).cast<Map<String, dynamic>>();
      setState(() { _options = list; _conversationId = resp['conversationId'] as String?; });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Generate failed: $e')));
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  // Check if an option is creatable (not suggestion/help)
  bool _isCreatableOption(Map<String, dynamic> option) {
    final type = option['type']?.toString().toLowerCase() ?? '';
    return type == 'assignment' || type == 'event';
  }

  // Get appropriate color for option type
  Color _getOptionColor(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
        return Colors.blue;
      case 'event':
        return Colors.green;
      case 'suggestion':
        return Colors.orange;
      case 'help':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Validate estimated time with 10-hour limit for assignments
  int _validateEstimatedTime(dynamic estimatedTime, String type) {
    final time = estimatedTime is int ? estimatedTime : int.tryParse(estimatedTime?.toString() ?? '60') ?? 60;
    
    // Apply 10-hour (600 minutes) limit for assignments
    if (type.toString().toLowerCase() == 'assignment' && time > 600) {
      return 600;
    }
    
    return time;
  }

  Future<void> _create(Map<String, dynamic> option) async {
    try {
      // Apply validation before creating
      final validatedOption = Map<String, dynamic>.from(option);
      validatedOption['estimatedTimeMinutes'] = _validateEstimatedTime(
        option['estimatedTimeMinutes'], 
        option['type']
      );
      
      final result = await ref.read(aiServiceProvider).createSelected(validatedOption, conversationId: _conversationId);
      if (!mounted) return;
      
      // Show success message with validation info if time was capped
      String message = result['message'] ?? 'Created';
      if (option['type'].toString().toLowerCase() == 'assignment' && 
          (option['estimatedTimeMinutes'] ?? 0) > 600) {
        message += ' (Time capped at 10 hours)';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Create failed: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }
}
