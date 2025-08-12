import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../model/assignment/assignment.dart';
import '../../../../provider/service_providers.dart';
import '../../../../provider/calendar_providers.dart';

class TimerPage extends ConsumerStatefulWidget {
  final Assignment assignment;
  final int focusMinutes;
  final int breakMinutes;

  const TimerPage({
    super.key,
    required this.assignment,
    this.focusMinutes = 25,
    this.breakMinutes = 5,
  });

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isFocusTime = true;
  int _completedSessions = 0;
  int _totalFocusMinutesCompleted = 0;
  bool _isAssignmentCompleted = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.focusMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isPaused) {
      _resumeTimer();
      return;
    }

    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _onTimerComplete();
        }
      });
    });

    HapticFeedback.lightImpact();
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isPaused = true;
      _isRunning = false;
    });
    HapticFeedback.lightImpact();
  }

  void _resumeTimer() {
    _startTimer();
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = _isFocusTime ? widget.focusMinutes * 60 : widget.breakMinutes * 60;
    });
    HapticFeedback.mediumImpact();
  }

  void _onTimerComplete() {
    _timer?.cancel();

    HapticFeedback.heavyImpact();

    setState(() {
      _isRunning = false;
      _isPaused = false;

      if (_isFocusTime) {
        _completedSessions++;
        _totalFocusMinutesCompleted += widget.focusMinutes;
        _isFocusTime = false;
        _remainingSeconds = widget.breakMinutes * 60;
        
        // Check if we've completed enough focus time for the assignment
        final estimatedMinutes = widget.assignment.estimatedTime * 60;
        if (_totalFocusMinutesCompleted >= estimatedMinutes) {
          _isAssignmentCompleted = true;
        }
      } else {
        _isFocusTime = true;
        _remainingSeconds = widget.focusMinutes * 60;
      }
    });

    _showSessionCompleteDialog();
  }

  void _showSessionCompleteDialog() {
    if (_isAssignmentCompleted && !_isFocusTime) {
      // Assignment is completed, show completion dialog
      _showAssignmentCompleteDialog();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_isFocusTime ? 'Break Complete!' : 'Focus Session Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isFocusTime
                  ? 'Ready for another focus session?'
                  : 'Time for a ${widget.breakMinutes}-minute break!',
            ),
            const SizedBox(height: 12),
            // Show progress
            Text(
              'Progress: ${_totalFocusMinutesCompleted}/${widget.assignment.estimatedTime * 60} minutes',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _totalFocusMinutesCompleted / (widget.assignment.estimatedTime * 60),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Finish'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startTimer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: Text(_isFocusTime ? 'Start Focus' : 'Start Break'),
          ),
        ],
      ),
    );
  }

  void _showAssignmentCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text('Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Congratulations! You\'ve completed "${widget.assignment.title}"',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'Total focus time: $_totalFocusMinutesCompleted minutes',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Sessions completed: $_completedSessions/${_getTotalSessionsNeeded()}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Continue Working'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _markAssignmentAsCompleted();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Mark as Completed'),
          ),
        ],
      ),
    );
  }

  Future<void> _markAssignmentAsCompleted() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Marking assignment as completed...'),
            ],
          ),
        ),
      );

      // Call the backend to mark assignment as completed
      await ref.read(assignmentServiceProvider).markAsCompleted(widget.assignment.assignmentId);
      
      // Refresh the assignments data
      ref.invalidate(dayAssignmentsProvider);
      ref.invalidate(monthAssignmentsProvider);
      
      if (!mounted) return;
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assignment marked as completed!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Exit timer page
      Navigator.of(context).pop();
      
    } catch (e) {
      if (!mounted) return;
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark assignment as completed: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getBackgroundColor() {
    if (_isFocusTime) {
      return const Color(0xFFB85450); // Red color from the image
    } else {
      return const Color(0xFF4CAF50); // Break time - green
    }
  }

  double _getProgress() {
    final totalSeconds = _isFocusTime ? widget.focusMinutes * 60 : widget.breakMinutes * 60;
    final elapsedSeconds = totalSeconds - _remainingSeconds;
    return elapsedSeconds / totalSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back/close button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => _showExitDialog(),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // Timer Circle
            Expanded(
              flex: 3,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress circle
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: CircularProgressIndicator(
                        value: _getProgress(),
                        strokeWidth: 6,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    // Timer text
                    Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Control buttons section
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Play/Pause and Skip buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Play/Pause button
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _isRunning ? _pauseTimer : _startTimer,
                          icon: Icon(
                            _isRunning ? Icons.pause : Icons.play_arrow,
                            color: _getBackgroundColor(),
                            size: 40,
                          ),
                        ),
                      ),

                      const SizedBox(width: 40),

                      // Skip button
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _onTimerComplete,
                          icon: const Icon(
                            Icons.skip_next,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Session indicators (dots)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_getTotalSessionsNeeded(), (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index < _completedSessions
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Bottom section with session info
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _isFocusTime ? 'Focus Time' : 'Break Time',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Assignment title (smaller)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      widget.assignment.title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Calculate total number of focus sessions needed based on estimated time
  int _getTotalSessionsNeeded() {
    final estimatedMinutes = widget.assignment.estimatedTime * 60;
    final sessionsNeeded = (estimatedMinutes / widget.focusMinutes).ceil();
    // Cap at reasonable maximum for UI purposes
    return sessionsNeeded.clamp(1, 8);
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Timer?'),
        content: const Text('Are you sure you want to exit? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}