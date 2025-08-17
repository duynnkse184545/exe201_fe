import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../model/assignment/assignment.dart';
import '../../extra/custom_dialog.dart';
import '../../extra/custom_field.dart';
import '../../../provider/service_providers.dart';
import '../../../provider/calendar_providers.dart';
import '../../../service/api/base/id_generator.dart';

class DeadlineDialog extends StatefulWidget {
  final Assignment? existingAssignment;
  
  const DeadlineDialog({super.key, this.existingAssignment});

  @override
  State<DeadlineDialog> createState() => _DeadlineDialogState();

  static void show(BuildContext context, {Assignment? existingAssignment}) {
    final dialogKey = GlobalKey<_DeadlineDialogState>();
    final isEditing = existingAssignment != null;

    showCustomBottomSheet(
      context: context,
      title: isEditing ? 'Edit Assignment' : 'Add Deadline',
      actionText: isEditing ? 'UPDATE' : 'CREATE',
      actionColor: const Color(0xFF6366F1),
      content: DeadlineDialog(key: dialogKey, existingAssignment: existingAssignment),
      onActionPressed: () async {
        if (isEditing) {
          await dialogKey.currentState?._updateAssignment();
        } else {
          await dialogKey.currentState?._createDeadline();
        }
      },
    );
  }
}

class _DeadlineDialogState extends State<DeadlineDialog> {
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _nameController = TextEditingController();
  final _estimatedTimeController = TextEditingController();
  DateTime? _selectedDateTime;

  // Error states for validation
  String? _nameError;
  String? _estimatedTimeError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    if (widget.existingAssignment != null) {
      _initializeWithExistingAssignment();
    } else {
      _initializeDateTime();
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _nameController.dispose();
    _estimatedTimeController.dispose();
    super.dispose();
  }

  void _initializeDateTime() {
    // Initialize with minimum allowed time (1 hour from now)
    final now = DateTime.now();
    final minimumDateTime = now.add(const Duration(hours: 1));
    // Round to next 5-minute interval
    final roundedMinutes = ((minimumDateTime.minute / 5).ceil() * 5) % 60;
    final roundedHour = minimumDateTime.hour + (roundedMinutes == 0 && minimumDateTime.minute > 0 ? 1 : 0);
    final initialDateTime = DateTime(minimumDateTime.year, minimumDateTime.month, minimumDateTime.day, roundedHour, roundedMinutes);
    
    _dateController.text = _formatDate(initialDateTime);
    _timeController.text = _formatTime(initialDateTime);
    _selectedDateTime = initialDateTime;
    
    // Clear other fields
    _nameController.clear();
    _estimatedTimeController.clear();
  }

  void _initializeWithExistingAssignment() {
    final assignment = widget.existingAssignment!;
    
    // Set form fields with existing assignment data
    _nameController.text = assignment.title;
    // Convert from hours (frontend) to display in the UI
    _estimatedTimeController.text = assignment.estimatedTime.toString();
    
    _selectedDateTime = assignment.dueDate;
    _dateController.text = _formatDate(assignment.dueDate);
    _timeController.text = _formatTime(assignment.dueDate);
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCombinedDateTimePickerField(),
        const SizedBox(height: 16),
        buildFormField(
          label: 'Assignment Title', 
          controller: _nameController,
          errorText: _nameError,
        ),
        const SizedBox(height: 16),
        buildFormField(
          label: 'Estimated Time (hours)', 
          controller: _estimatedTimeController,
          keyboardType: TextInputType.number,
          hintText: 'Enter 1-10 hours',
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2), // Limit to 2 digits (max 99, but validation will catch >24)
          ],
          errorText: _estimatedTimeError,
        ),
        
        // General error display
        if (_generalError != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _generalError!,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _createDeadline() async {
    try {
      // Get ProviderContainer from context for Riverpod access
      final container = ProviderScope.containerOf(context);
      
      // Clear previous errors
      setState(() {
        _nameError = null;
        _estimatedTimeError = null;
        _generalError = null;
      });

      bool valid = true;

      // Validate inputs
      if (_nameController.text.trim().isEmpty) {
        setState(() => _nameError = 'Please enter an assignment title');
        valid = false;
      }

      // Parse estimated time
      int? estimatedHours;
      if (_estimatedTimeController.text.trim().isNotEmpty) {
        estimatedHours = int.tryParse(_estimatedTimeController.text.trim());
        if (estimatedHours == null || estimatedHours < 1 || estimatedHours > 10) {
          setState(() => _estimatedTimeError = 'Please enter a valid estimated time between 1 and 10 hours');
          valid = false;
        }
      }

      // Get default subject and priority (you might want to make these selectable)
      final subjects = await container.read(subjectsProvider.future);
      final priorities = await container.read(prioritiesProvider.future);
      
      if (subjects.isEmpty) {
        setState(() => _generalError = 'No subjects available. Please create a subject first.');
        valid = false;
      }
      
      if (priorities.isEmpty) {
        setState(() => _generalError = 'No priorities available. Please create priorities first.');
        valid = false;
      }

      if (!valid) return;

      // Parse the selected date and time
      final selectedDateTime = _parseDateTime(_dateController.text, _timeController.text);

      // Create assignment request object
      final assignmentRequest = AssignmentRequest(
        title: _nameController.text.trim(),
        description: 'Created via deadline dialog',
        dueDate: selectedDateTime,
        priorityId: priorities.first.priorityId!,
        estimatedTime: estimatedHours! * 60, // Convert hours to minutes for backend
      );

      // Create assignment using the correct service method
      await container.read(assignmentServiceProvider).createAssignmentFromRequest(assignmentRequest);

      // Refresh the assignments data
      container.invalidate(assignmentsProvider);
      container.invalidate(monthAssignmentsProvider);

      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deadline "${_nameController.text.trim()}" created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _generalError = 'Failed to create deadline: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _updateAssignment() async {
    try {
      // Clear previous errors
      setState(() {
        _nameError = null;
        _estimatedTimeError = null;
        _generalError = null;
      });

      bool valid = true;

      // Validate inputs
      if (_nameController.text.trim().isEmpty) {
        setState(() => _nameError = 'Please enter an assignment title');
        valid = false;
      }

      // Parse estimated time
      int? estimatedHours;
      if (_estimatedTimeController.text.trim().isNotEmpty) {
        estimatedHours = int.tryParse(_estimatedTimeController.text.trim());
        if (estimatedHours == null || estimatedHours < 1 || estimatedHours > 10) {
          setState(() => _estimatedTimeError = 'Please enter a valid estimated time between 1 and 10 hours');
          valid = false;
        }
      }

      if (!valid) return;

      final assignmentRequest = Assignment(
        assignmentId: widget.existingAssignment!.assignmentId,
        title: _nameController.text.trim(),
        description: widget.existingAssignment!.description,
        dueDate: _selectedDateTime!,
        priorityId: widget.existingAssignment!.priorityId,
        estimatedTime: estimatedHours != null ? estimatedHours * 60 : widget.existingAssignment!.estimatedTime * 60, // Convert hours to minutes for backend
        status: widget.existingAssignment!.status,
        subjectId: null,
        userId: '',
      );
      final assignmentService = ProviderScope.containerOf(context).read(assignmentServiceProvider);
      await assignmentService.update(assignmentRequest);

      // Refresh the calendar data
      ProviderScope.containerOf(context).refresh(monthAssignmentsProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assignment updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to update assignment: $e');
    }
  }

  DateTime _parseDateTime(String dateText, String timeText) {
    // Use the stored selected DateTime if available
    if (_selectedDateTime != null) {
      return _selectedDateTime!;
    }
    
    // Fallback parsing if somehow the stored DateTime is null
    final now = DateTime.now();
    final timeParts = timeText.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final currentYear = now.year;
    final dateYear = date.year;
    
    // If it's the same year, don't show year
    if (dateYear == currentYear) {
      return DateFormat('EEE, d MMMM').format(date);
    } else {
      // Only show year if it's different (shouldn't happen often with our range)
      return DateFormat('EEE, d MMMM yyyy').format(date);
    }
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  Widget _buildCombinedDateTimePickerField() {
    // Use consistent reference time to avoid timing issues
    final now = DateTime.now();
    // Set minimum time to 1 hour from now
    final minimumDateTime = now.add(const Duration(hours: 1));
    // Round to next 5-minute interval to avoid timing conflicts
    final roundedMinutes = ((minimumDateTime.minute / 5).ceil() * 5) % 60;
    final roundedHour = minimumDateTime.hour + (roundedMinutes == 0 && minimumDateTime.minute > 0 ? 1 : 0);
    final initialDateTime = DateTime(minimumDateTime.year, minimumDateTime.month, minimumDateTime.day, roundedHour, roundedMinutes);

    // Ensure initialDateTime is never before minimumDateTime
    final safeInitialDateTime = initialDateTime.isBefore(minimumDateTime) ? minimumDateTime : initialDateTime;
    DateTime selectedDateTime = safeInitialDateTime;

    return StatefulBuilder(
      builder: (context, setState) {
        return TextField(
          // Use the actual controller values, not a new controller
          controller: TextEditingController(
            text: '${_dateController.text} at ${_timeController.text}',
          ),
          readOnly: true,
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (_) {
                return Container(
                  height: 350,
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      // Header with Done button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text(
                              'Select Date & Time',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            child: const Text("Done"),
                            onPressed: () {
                              // Just close the bottom sheet since values are already updated
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      // Combined Cupertino Date & Time Picker
                      Expanded(
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.dateAndTime,
                          initialDateTime: safeInitialDateTime,
                          minimumDate: minimumDateTime, // Prevent selecting less than 1 hour from now
                          maximumDate: now.add(const Duration(days: 365)),
                          use24hFormat: true,
                          minuteInterval: 5, // 5-minute intervals for cleaner selection
                          onDateTimeChanged: (dateTime) {
                            // Additional validation to ensure selected time is at least 1 hour from now
                            final oneHourFromNow = DateTime.now().add(const Duration(hours: 1));
                            if (dateTime.isBefore(oneHourFromNow)) {
                              // If somehow a time less than 1 hour from now is selected, round up to minimum time
                              final roundedMinutes = ((oneHourFromNow.minute / 5).ceil() * 5) % 60;
                              final roundedHour = oneHourFromNow.hour + (roundedMinutes == 0 && oneHourFromNow.minute > 0 ? 1 : 0);
                              selectedDateTime = DateTime(
                                dateTime.year,
                                dateTime.month,
                                dateTime.day,
                                roundedHour,
                                roundedMinutes,
                              );
                            } else {
                              selectedDateTime = dateTime;
                            }

                            // Update controllers and state immediately as user scrolls
                            _selectedDateTime = selectedDateTime;
                            _dateController.text = _formatDate(selectedDateTime);
                            _timeController.text = _formatTime(selectedDateTime);
                            setState(() {}); // Update the TextField text in real-time
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          decoration: InputDecoration(
            labelText: 'Date & Time',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.1),
            suffixIcon: const Icon(Icons.event, size: 20),
          ),
        );
      },
    );
  }
}