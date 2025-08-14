import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/service_providers.dart';
import '../calendar/calendar_theme.dart';

// Enhanced AI response types
enum AIResponseType {
  welcome,
  creationOptions,
  suggestions,
  greeting,
  help,
  mixed,
  error
}

// Enhanced AI Option model
class AIOption {
  final String type;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String priority;
  final int estimatedTimeMinutes;
  final String reminderType;
  final int reminderValueMinutes;
  final String reasoning;
  final String? subjectName;
  final String? categoryName;
  
  // New fields for handling different response types
  final bool isCreatable;
  final bool isSuggestion;
  final bool isGreeting;
  final bool isHelp;

  AIOption({
    required this.type,
    required this.title,
    this.description,
    this.dueDate,
    required this.priority,
    required this.estimatedTimeMinutes,
    required this.reminderType,
    required this.reminderValueMinutes,
    required this.reasoning,
    this.subjectName,
    this.categoryName,
    this.isCreatable = true,
    this.isSuggestion = false,
    this.isGreeting = false,
    this.isHelp = false,
  });

  factory AIOption.fromJson(Map<String, dynamic> json) {
    final type = json['type']?.toString().toLowerCase() ?? '';
    
    return AIOption(
      type: type,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      dueDate: json['dueDate'] != null 
          ? DateTime.tryParse(json['dueDate'].toString()) 
          : null,
      priority: json['priority']?.toString() ?? 'Medium',
      estimatedTimeMinutes: int.tryParse(json['estimatedTimeMinutes']?.toString() ?? '60') ?? 60,
      reminderType: json['reminderType']?.toString() ?? 'template',
      reminderValueMinutes: int.tryParse(json['reminderValueMinutes']?.toString() ?? '1440') ?? 1440,
      reasoning: json['reasoning']?.toString() ?? '',
      subjectName: json['subjectName']?.toString(),
      categoryName: json['categoryName']?.toString(),
      isCreatable: type == 'assignment' || type == 'event',
      isSuggestion: type == 'suggestion',
      isGreeting: type == 'greeting',
      isHelp: type == 'help',
    );
  }
}

// Response analyzer
class AIResponseAnalyzer {
  static AIResponseType analyzeResponse(List<AIOption> options) {
    if (options.isEmpty) {
      return AIResponseType.error;
    }
    
    final firstOption = options.first;
    
    // Check for different response types
    if (firstOption.isGreeting) {
      return AIResponseType.greeting;
    }
    
    if (firstOption.isSuggestion) {
      return AIResponseType.suggestions;
    }
    
    if (firstOption.isHelp) {
      return AIResponseType.help;
    }
    
    // Check if all options are creatable
    final allCreatable = options.every((opt) => opt.isCreatable);
    if (allCreatable) {
      return AIResponseType.creationOptions;
    }
    
    return AIResponseType.mixed;
  }
  
  static bool isNonsenseInput(String input) {
    final trimmed = input.trim().toLowerCase();
    
    // Empty or too short
    if (trimmed.length < 2) return true;
    
    // Common greetings
    final greetings = ['hi', 'hello', 'hey', 'good morning', 'good afternoon', 'good evening'];
    if (greetings.contains(trimmed)) return true;
    
    // Help requests
    final helpRequests = ['help', 'what can you do', 'how does this work', '?'];
    if (helpRequests.contains(trimmed)) return true;
    
    // Random characters or numbers only
    if (RegExp(r'^[0-9\s\W]+$').hasMatch(trimmed)) return true;
    
    return false;
  }
}

class AICreateDialog extends ConsumerStatefulWidget {
  const AICreateDialog({super.key});

  @override
  ConsumerState<AICreateDialog> createState() => _AICreateDialogState();
}

class _AICreateDialogState extends ConsumerState<AICreateDialog> with TickerProviderStateMixin {
  final _prompt = TextEditingController();
  bool _loading = false;
  List<AIOption> _options = [];
  String? _conversationId;
  AIResponseType _responseType = AIResponseType.welcome;
  String? _errorMessage;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _prompt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[400]!, Colors.purple[400]!],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('AI Assistant', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Input field
              TextField(
                controller: _prompt,
                decoration: InputDecoration(
                  hintText: 'Describe what you want to create...',
                  helperText: "Try: 'Create math assignment due tomorrow' or 'Schedule team meeting'",
                  prefixIcon: const Icon(Icons.chat_bubble_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onSubmitted: (_) => _handleUserInput(_prompt.text),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              
              // Generate button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate Options'),
                  onPressed: _loading ? null : () => _handleUserInput(_prompt.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CalendarTheme.secondaryColor, 
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Content area
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_responseType) {
      case AIResponseType.welcome:
        return _buildWelcomeState();
      case AIResponseType.creationOptions:
        return _buildCreationOptions();
      case AIResponseType.suggestions:
        return _buildSuggestions();
      case AIResponseType.greeting:
        return _buildGreeting();
      case AIResponseType.help:
        return _buildHelp();
      case AIResponseType.error:
        return _buildErrorMessage();
      default:
        return _loading ? _buildLoadingState() : _buildWelcomeState();
    }
  }

  void _handleUserInput(String input) {
    final trimmed = input.trim();
    
    if (trimmed.isEmpty) {
      setState(() {
        _responseType = AIResponseType.welcome;
      });
      return;
    }
    
    // Check for nonsense input
    if (AIResponseAnalyzer.isNonsenseInput(trimmed)) {
      setState(() {
        _responseType = AIResponseType.suggestions;
        _options = _generateExampleOptions();
      });
      return;
    }
    
    // Valid input - call API
    _generate();
  }

  List<AIOption> _generateExampleOptions() {
    return [
      AIOption(
        type: 'suggestion',
        title: 'Assignment Examples',
        description: 'Try these assignment prompts',
        priority: 'Medium',
        estimatedTimeMinutes: 60,
        reminderType: 'template',
        reminderValueMinutes: 1440,
        reasoning: 'Example prompts for assignments',
        isSuggestion: true,
        isCreatable: false,
      ),
      AIOption(
        type: 'suggestion',
        title: 'Event Examples',
        description: 'Try these event prompts',
        priority: 'Medium',
        estimatedTimeMinutes: 60,
        reminderType: 'template',
        reminderValueMinutes: 1440,
        reasoning: 'Example prompts for events',
        isSuggestion: true,
        isCreatable: false,
      ),
    ];
  }

  Future<void> _generate() async {
    final msg = _prompt.text.trim();
    if (msg.isEmpty) return;
    
    setState(() { 
      _loading = true; 
      _options = [];
      _errorMessage = null;
    });
    
    try {
      final resp = await ref.read(aiServiceProvider).generateOptions(msg);
      final list = (resp['options'] as List);
      final options = list.map((item) {
        if (item is Map<String, dynamic> && item.containsKey('option')) {
          return AIOption.fromJson(item['option'] as Map<String, dynamic>);
        } else {
          return AIOption.fromJson(item as Map<String, dynamic>);
        }
      }).toList();
      
      setState(() { 
        _options = options; 
        _conversationId = resp['conversationId'] as String?;
        _responseType = AIResponseAnalyzer.analyzeResponse(options);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _responseType = AIResponseType.error;
      });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _create(AIOption option) async {
    try {
      final optionMap = {
        'type': option.type,
        'title': option.title,
        'description': option.description,
        'dueDate': option.dueDate?.toIso8601String(),
        'priority': option.priority,
        'estimatedTimeMinutes': option.estimatedTimeMinutes,
        'reminderType': option.reminderType,
        'reminderValueMinutes': option.reminderValueMinutes,
        'reasoning': option.reasoning,
        'subjectName': option.subjectName,
        'categoryName': option.categoryName,
      };
      
      final result = await ref.read(aiServiceProvider).createSelected(optionMap, conversationId: _conversationId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Create failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _useExample(String example) {
    _prompt.text = example;
    
    // Show brief feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Great! This is a clear request that I can work with."),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    
    // Generate options
    _handleUserInput(example);
  }

  Widget _buildWelcomeState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Welcome animation
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 1000),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[400]!, Colors.purple[400]!],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      const Text(
                        'AI Assistant Ready',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        'Describe what you want to create and I\'ll generate smart options for you!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Quick actions
          _buildQuickActions(),
          
          const SizedBox(height: 24),
          
          // Example prompts
          _buildExamplePrompts(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickAction(
                icon: Icons.assignment,
                label: "Assignment",
                example: "Create assignment due tomorrow",
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickAction(
                icon: Icons.event,
                label: "Meeting",
                example: "Schedule meeting this afternoon",
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickAction(
                icon: Icons.school,
                label: "Study",
                example: "Plan study session for Friday",
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required String example,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: () => _useExample(example),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildExamplePrompts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Example Prompts",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        _buildExampleCategory(
          "Assignment Examples",
          [
            "Create assignment due tomorrow",
            "Math homework due Friday",
            "Research paper for history class",
            "Chemistry lab report next week",
          ],
          Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildExampleCategory(
          "Event Examples",
          [
            "Schedule meeting this afternoon",
            "Team presentation next Monday",
            "Doctor appointment tomorrow",
            "Study group session Friday",
          ],
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildExampleCategory(String title, List<String> examples, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          ...examples.map((example) => _buildExampleItem(example, color)),
        ],
      ),
    );
  }

  Widget _buildExampleItem(String example, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _useExample(example),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(Icons.chat_bubble_outline, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  example,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            color: CalendarTheme.secondaryColor,
          ),
          const SizedBox(height: 24),
          const Text(
            'AI is analyzing your request...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCreationOptions() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Great! Here are your options:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: _options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final option = _options[index];
              return _buildOptionCard(option);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(AIOption option) {
    final isAssignment = option.type.toLowerCase() == 'assignment';
    final color = isAssignment ? Colors.blue : Colors.green;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    option.type.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${option.estimatedTimeMinutes} min',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              option.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (option.description != null && option.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                option.description!,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _create(option),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Create ${option.type}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Here are some examples to help you:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(child: _buildExamplePrompts()),
      ],
    );
  }

  Widget _buildGreeting() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.blue[400]!],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.waving_hand, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 24),
          const Text(
            'Hello there!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'I\'m here to help you create assignments and events. Try describing what you need!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildHelp() {
    return const Center(
      child: Text(
        'Help content coming soon!',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Something went wrong",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[800],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ?? 'An unexpected error occurred',
                  style: TextStyle(color: Colors.red[700], fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _handleUserInput(_prompt.text),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _responseType = AIResponseType.welcome;
                    _errorMessage = null;
                  });
                },
                icon: const Icon(Icons.help_outline),
                label: const Text('See Examples'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}