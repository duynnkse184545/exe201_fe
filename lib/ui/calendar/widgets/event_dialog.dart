import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../model/event/event.dart';
import '../../extra/custom_dialog.dart';
import '../../extra/custom_field.dart';
import '../../../provider/service_providers.dart';
import '../../../provider/calendar_providers.dart';

class EventDialog extends StatefulWidget {
  const EventDialog({super.key});

  @override
  State<EventDialog> createState() => _EventDialogState();

  static void show(BuildContext context) {
    final dialogKey = GlobalKey<_EventDialogState>();
    showCustomBottomSheet(
      context: context,
      title: 'Add Event',
      actionText: 'CREATE',
      actionColor: const Color(0xFF6366F1),
      content: EventDialog(key: dialogKey),
      onActionPressed: () async {
        await dialogKey.currentState?._createEvent();
      },
    );
  }
}

class _EventDialogState extends State<EventDialog> {
  // Controllers for the form fields
  final _startDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endDateController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _repeatEndDateController = TextEditingController();

  DateTime? _selectedStartDateTime;
  DateTime? _selectedEndDateTime;
  DateTime? _selectedRepeatEndDate;
  String _selectedRepeatPattern = 'none';

  // Error states for validation
  String? _titleError;
  String? _descriptionError;
  String? _dateTimeError;

  @override
  void initState() {
    super.initState();
    _initializeDateTimes();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _startTimeController.dispose();
    _endDateController.dispose();
    _endTimeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _repeatEndDateController.dispose();
    super.dispose();
  }

  void _initializeDateTimes() {
    // Initialize with minimum allowed time (1 hour from now)
    final now = DateTime.now();
    final minimumDateTime = now.add(const Duration(hours: 1));
    // Round to next 5-minute interval
    final roundedMinutes = ((minimumDateTime.minute / 5).ceil() * 5) % 60;
    final roundedHour =
        minimumDateTime.hour +
        (roundedMinutes == 0 && minimumDateTime.minute > 0 ? 1 : 0);
    final startDateTime = DateTime(
      minimumDateTime.year,
      minimumDateTime.month,
      minimumDateTime.day,
      roundedHour,
      roundedMinutes,
    );

    // End time is 1 hour after start time by default
    final endDateTime = startDateTime.add(const Duration(hours: 1));

    _startDateController.text = _formatDate(startDateTime);
    _startTimeController.text = _formatTime(startDateTime);
    _selectedStartDateTime = startDateTime;

    _endDateController.text = _formatDate(endDateTime);
    _endTimeController.text = _formatTime(endDateTime);
    _selectedEndDateTime = endDateTime;

    // Clear other fields
    _titleController.clear();
    _descriptionController.clear();
    _repeatEndDateController.clear();
    _selectedRepeatEndDate = null;
    _selectedRepeatPattern = 'none';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildFormField(
          label: 'Event Title',
          controller: _titleController,
          errorText: _titleError,
        ),
        const SizedBox(height: 16),
        buildFormField(
          label: 'Description',
          controller: _descriptionController,
          errorText: _descriptionError,
        ),
        const SizedBox(height: 16),

        // Date/Time error display
        if (_dateTimeError != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
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
                    _dateTimeError!,
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
        const SizedBox(height: 16),
        _buildDateTimePickerField(
          context,
          label: 'Start Date & Time',
          dateController: _startDateController,
          timeController: _startTimeController,
          isStartTime: true,
          parentSetState: setState,
        ),
        const SizedBox(height: 16),
        _buildDateTimePickerField(
          context,
          label: 'End Date & Time',
          dateController: _endDateController,
          timeController: _endTimeController,
          isStartTime: false,
          parentSetState: setState,
        ),
        const SizedBox(height: 16),
        _buildRepeatPatternField(context, setState),
        const SizedBox(height: 16),
        if (_selectedRepeatPattern != 'none')
          _buildRepeatEndDateField(context, setState),
      ],
    );
  }

  Future<void> _createEvent() async {
    try {
      print('Starting event creation...');
      // Get ProviderContainer from context for Riverpod access
      final container = ProviderScope.containerOf(context);

      // Clear previous errors
      setState(() {
        _titleError = null;
        _dateTimeError = null;
      });

      bool valid = true;

      // Validate inputs
      if (_titleController.text.trim().isEmpty) {
        setState(() => _titleError = 'Please enter an event title');
        valid = false;
      }
      if (_descriptionController.text.trim().isEmpty) {
        setState(() => _descriptionError = 'Please enter an description');
        valid = false;
      }

      // Parse the selected date and times
      final startDateTime = _parseDateTime(
        _startDateController.text,
        _startTimeController.text,
        true,
      );
      final endDateTime = _parseDateTime(
        _endDateController.text,
        _endTimeController.text,
        false,
      );

      // Validate that end time is after start time
      if (endDateTime.isBefore(startDateTime) ||
          endDateTime.isAtSameMomentAs(startDateTime)) {
        setState(() => _dateTimeError = 'End time must be after start time');
        valid = false;
      }

      if (!valid) return;

      // Create event request object
      final eventRequest = EventRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        recurrencePattern: _selectedRepeatPattern == 'none'
            ? null
            : _selectedRepeatPattern,
        recurrenceEndDate: _selectedRepeatEndDate,
      );

      // Create event using the correct service method
      await container
          .read(eventServiceProvider)
          .createEventFromRequest(eventRequest);

      // Refresh the events data
      container.invalidate(eventsProvider);
      container.invalidate(monthEventsProvider);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Event "${_titleController.text.trim()}" created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to create event: $e');
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  DateTime _parseDateTime(String dateText, String timeText, bool isStartTime) {
    // Use the stored selected DateTime if available
    final selectedDateTime = isStartTime
        ? _selectedStartDateTime
        : _selectedEndDateTime;
    if (selectedDateTime != null) {
      return selectedDateTime;
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

  Widget _buildDateTimePickerField(
    BuildContext context, {
    required String label,
    required TextEditingController dateController,
    required TextEditingController timeController,
    required bool isStartTime,
    StateSetter? parentSetState,
  }) {
    // Use consistent reference time to avoid timing issues
    final now = DateTime.now();
    // Set minimum time to 1 hour from now for start time, or start time for end time
    final minimumDateTime = isStartTime
        ? now.add(const Duration(hours: 1))
        : (_selectedStartDateTime ?? now.add(const Duration(hours: 1)));

    // Round to next 5-minute interval to avoid timing conflicts
    final roundedMinutes = ((minimumDateTime.minute / 5).ceil() * 5) % 60;
    final roundedHour =
        minimumDateTime.hour +
        (roundedMinutes == 0 && minimumDateTime.minute > 0 ? 1 : 0);
    final initialDateTime = DateTime(
      minimumDateTime.year,
      minimumDateTime.month,
      minimumDateTime.day,
      roundedHour,
      roundedMinutes,
    );

    // Ensure initialDateTime is never before minimumDateTime
    final safeInitialDateTime = initialDateTime.isBefore(minimumDateTime)
        ? minimumDateTime
        : initialDateTime;

    return StatefulBuilder(
      builder: (context, setState) {
        return TextField(
          controller: TextEditingController(
            text: '${dateController.text} at ${timeController.text}',
          ),
          readOnly: true,
          onTap: () {
            DateTime selectedDateTime = safeInitialDateTime;

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
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(
                              'Select $label',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            child: const Text("Done"),
                            onPressed: () {
                              // Store the actual selected DateTime for later use
                              if (isStartTime) {
                                _startDateController.text = _formatDate(
                                  selectedDateTime,
                                );
                                _startTimeController.text = _formatTime(
                                  selectedDateTime,
                                );
                                _selectedStartDateTime = selectedDateTime;

                                // Auto-adjust end date if it's before or equal to the start
                                if (_selectedEndDateTime == null ||
                                    _selectedEndDateTime!.isBefore(
                                      selectedDateTime,
                                    ) ||
                                    _selectedEndDateTime!.isAtSameMomentAs(
                                      selectedDateTime,
                                    )) {
                                  _selectedEndDateTime = selectedDateTime.add(
                                    const Duration(hours: 1),
                                  );
                                  _endDateController.text = _formatDate(
                                    _selectedEndDateTime!,
                                  );
                                  _endTimeController.text = _formatTime(
                                    _selectedEndDateTime!,
                                  );
                                }
                              } else {
                                _endDateController.text = _formatDate(
                                  selectedDateTime,
                                );
                                _endTimeController.text = _formatTime(
                                  selectedDateTime,
                                );
                                _selectedEndDateTime = selectedDateTime;
                              }

                              dateController.text = _formatDate(
                                selectedDateTime,
                              );
                              timeController.text = _formatTime(
                                selectedDateTime,
                              );

                              // Update both local and parent state
                              setState(() {});
                              if (parentSetState != null) {
                                parentSetState(() {});
                              }
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      // Combined Cupertino Date & Time Picker
                      Expanded(
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.dateAndTime,
                          initialDateTime: isStartTime
                              ? (_selectedStartDateTime ??
                                    DateTime.now().add(
                                      const Duration(hours: 1),
                                    ))
                              : (_selectedEndDateTime ??
                                    DateTime.now().add(
                                      const Duration(hours: 1),
                                    )),
                          minimumDate: isStartTime
                              ? null
                              : _selectedStartDateTime,
                          maximumDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          use24hFormat: true,
                          minuteInterval: 5,
                          // 5-minute intervals for cleaner selection
                          onDateTimeChanged: (dateTime) {
                            final minTime = isStartTime
                                ? DateTime.now().add(const Duration(hours: 1))
                                : (_selectedStartDateTime ??
                                      DateTime.now().add(
                                        const Duration(hours: 1),
                                      ));

                            // Adjust if needed
                            if (dateTime.isBefore(minTime)) {
                              selectedDateTime = minTime;
                            } else {
                              selectedDateTime = dateTime;
                            }

                            // Always update based on the final selectedDateTime
                            dateController.text = _formatDate(selectedDateTime);
                            timeController.text = _formatTime(selectedDateTime);

                            // Save selection and handle auto-adjustment for start time
                            if (isStartTime) {
                              _selectedStartDateTime = selectedDateTime;

                              // Real-time auto-adjust end date if it's before or equal to the new start time
                              if (_selectedEndDateTime == null ||
                                  _selectedEndDateTime!.isBefore(
                                    selectedDateTime,
                                  ) ||
                                  _selectedEndDateTime!.isAtSameMomentAs(
                                    selectedDateTime,
                                  )) {
                                _selectedEndDateTime = selectedDateTime.add(
                                  const Duration(hours: 1),
                                );
                                _endDateController.text = _formatDate(
                                  _selectedEndDateTime!,
                                );
                                _endTimeController.text = _formatTime(
                                  _selectedEndDateTime!,
                                );
                              }
                            } else {
                              _selectedEndDateTime = selectedDateTime;
                            }

                            // Update both local and parent state
                            setState(() {});
                            if (parentSetState != null) {
                              parentSetState(() {});
                            }
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
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.1),
            suffixIcon: const Icon(Icons.event, size: 20),
          ),
        );
      },
    );
  }

  Widget _buildRepeatPatternField(BuildContext context, StateSetter setState) {
    const repeatOptions = [
      {'value': 'none', 'label': 'None'},
      {'value': 'daily', 'label': 'Daily'},
      {'value': 'weekly', 'label': 'Weekly'},
      {'value': 'monthly', 'label': 'Monthly'},
      {'value': 'yearly', 'label': 'Yearly'},
    ];

    return DropdownButtonFormField<String>(
      value: _selectedRepeatPattern,
      decoration: InputDecoration(
        labelText: 'Repeat Pattern',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.1),
        prefixIcon: const Icon(Icons.repeat, size: 20),
      ),
      items: repeatOptions.map((option) {
        return DropdownMenuItem<String>(
          value: option['value'],
          child: Text(option['label']!),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedRepeatPattern = value!;
          if (value == 'none') {
            _selectedRepeatEndDate = null;
            _repeatEndDateController.clear();
          }
        });
      },
    );
  }

  Widget _buildRepeatEndDateField(BuildContext context, StateSetter setState) {
    return TextField(
      controller: _repeatEndDateController,
      readOnly: true,
      onTap: () {
        final now = DateTime.now();
        final startDate = _selectedStartDateTime ?? now;
        final minimumDate = startDate.add(const Duration(days: 1));

        showModalBottomSheet(
          context: context,
          builder: (_) {
            DateTime selectedDate = _selectedRepeatEndDate ?? minimumDate;

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
                          'Select Repeat End Date',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        child: const Text("Done"),
                        onPressed: () {
                          _selectedRepeatEndDate = selectedDate;
                          _repeatEndDateController.text = _formatDate(
                            selectedDate,
                          );
                          setState(() {});
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  // Date Picker
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: selectedDate,
                      minimumDate: minimumDate,
                      maximumDate: DateTime.now().add(
                        const Duration(days: 365 * 5),
                      ),
                      // 5 years max
                      onDateTimeChanged: (date) {
                        selectedDate = date;
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
        labelText: 'Repeat Until (Optional)',
        hintText: 'Select end date for repeat pattern',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.1),
        suffixIcon: const Icon(Icons.calendar_today, size: 20),
      ),
    );
  }
}
