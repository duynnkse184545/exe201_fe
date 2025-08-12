import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../model/models.dart';
import '../../../provider/providers.dart';
import '../../../service/storage/token_storage.dart';

class BalanceChart extends ConsumerStatefulWidget {
  const BalanceChart({super.key});

  @override
  ConsumerState<BalanceChart> createState() => _BalanceChartState();
}

class _BalanceChartState extends ConsumerState<BalanceChart> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize wave animation
    _waveController = AnimationController(
      duration: const Duration(seconds: 3), // 3-second wave cycle
      vsync: this,
    );
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
    
    // Start the wave animation and repeat
    _waveController.repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: TokenStorage().getUserId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _buildEmptyChart();
        
        final userId = snapshot.data!;
        
        final balanceAsync = ref.watch(balanceNotifierProvider);
        
        return Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(20),
          child: balanceAsync.when(
            loading: () => _buildLoadingChart(),
            error: (_, __) => _buildEmptyChart(),
            data: (balance) => _buildDataChart(balance),
          ),
        );
      },
    );
  }

  Widget _buildDataChart(Balance balance) {
    // Calculate chart data from balance
    final chartData = _calculateBalanceChartData(balance);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart header with real data
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Financial Overview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Current Month',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Your existing beautiful chart with real data and wave animation
        Expanded(
          child: AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: BalanceChartPainter(
                  balanceData: chartData,
                  maxValue: _getMaxValue(balance),
                  waveOffset: _waveAnimation.value,
                ),
                size: const Size(double.infinity, 100),
              );
            },
          ),
        ),
        
        // Real financial metrics below chart
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildChartMetric('Balance', balance.availableBalance, 
              balance.availableBalance > 0 ? Colors.green : Colors.red),
            _buildChartMetric('Income', balance.monthlyIncome, Colors.green),
            _buildChartMetric('Expenses', balance.monthlyExpenses, Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildChartMetric(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        Text(
          _formatCurrency(value),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  List<double> _calculateBalanceChartData(Balance balance) {
    // Option A: Show budget utilization progression
    final budgets = balance.budgets.where((b) => b.budgetAmount > 0).toList()
      ..sort((a, b) => a.spentPercentage.compareTo(b.spentPercentage));
    
    if (budgets.isNotEmpty) {
      return budgets.map((b) => b.spentPercentage).toList();
    }
    
    // Option B: Show spending trend from expenses
    final expenses = balance.expenses;
    if (expenses.isNotEmpty) {
      // Group by day and show cumulative spending
      final now = DateTime.now();
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      
      List<double> dailySpending = List.filled(daysInMonth, 0);
      
      for (final expense in expenses) {
        final day = expense.createdDate.day - 1; // 0-indexed
        if (day >= 0 && day < daysInMonth) {
          dailySpending[day] += expense.amount;
        }
      }
      
      // Convert to cumulative
      for (int i = 1; i < dailySpending.length; i++) {
        dailySpending[i] += dailySpending[i - 1];
      }
      
      return dailySpending.take(now.day).toList(); // Only up to today
    }
    
    // Option C: Simple balance trend (fallback)
    return [
      balance.availableBalance * 0.8,
      balance.availableBalance * 0.9,
      balance.availableBalance,
    ];
  }

  double _getMaxValue(Balance balance) {
    final totalBudget = balance.budgets.fold<double>(0, (sum, b) => sum + b.budgetAmount);
    return [
      balance.availableBalance,
      balance.monthlyIncome,
      balance.monthlyExpenses,
      totalBudget,
    ].reduce((a, b) => a > b ? a : b);
  }

  Widget _buildLoadingChart() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF6366F1)),
    );
  }

  Widget _buildEmptyChart() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: StaticChartPainter(waveOffset: _waveAnimation.value),
          size: const Size(double.infinity, 100),
        );
      },
    );
  }

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}₫';
  }
}

class BalanceChartPainter extends CustomPainter {
  final List<double> balanceData;
  final double maxValue;
  final double waveOffset;
  
  BalanceChartPainter({
    required this.balanceData,
    required this.maxValue,
    this.waveOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (balanceData.isEmpty || maxValue == 0) {
      _drawAnimatedStaticChart(canvas, size);
      return;
    }

    final paint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Create smooth wave/mountain curve from real data
    for (int i = 0; i < balanceData.length; i++) {
      final x = (i / (balanceData.length - 1)) * size.width;
      final normalizedValue = (balanceData[i] / maxValue).clamp(0.0, 1.0);
      
      // Add wave effect: combine data with sine wave
      final waveAmplitude = size.height * 0.15; // Increased for more visible waves
      final waveFrequency = 2.0; // Number of waves across the width
      final wavePhase = waveOffset * 2 * 3.14159; // Convert to radians
      
      final waveY = waveAmplitude * math.sin((x / size.width) * waveFrequency * 2 * 3.14159 + wavePhase);
      final baseY = size.height * 0.9  - (normalizedValue * size.height * 0.1); // This centers it// Leave more margin for waves
      final y = baseY + waveY;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Create smooth mountain-like curves
        final prevX = ((i - 1) / (balanceData.length - 1)) * size.width;
        final prevNormalizedValue = (balanceData[i - 1] / maxValue).clamp(0.0, 1.0);
        final prevWaveY = waveAmplitude * math.sin((prevX / size.width) * waveFrequency * 2 * 3.14159 + wavePhase);
        final prevBaseY = size.height - (prevNormalizedValue * size.height * 0.7);
        final prevY = prevBaseY + prevWaveY;
        
        final controlX = (prevX + x) / 2;
        final controlY = (prevY + y) / 2;
        
        path.quadraticBezierTo(controlX, controlY, x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Keep your beautiful gradient fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF6366F1).withValues(alpha: 0.3),
          const Color(0xFF6366F1).withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  void _drawAnimatedStaticChart(Canvas canvas, Size size) {
    // Animated version of your original beautiful chart
    final paint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Add wave animation to the static chart points
    final waveAmplitude = size.height * 0.08; // Increased for more visible static waves
    final wavePhase = waveOffset * 2 * 3.14159;
    
    // Animated control points
    final startY = size.height * 0.8 + waveAmplitude * math.sin(wavePhase);
    final midY = size.height * 0.6 + waveAmplitude * math.sin(wavePhase + 1);
    final endY = size.height * 0.5 + waveAmplitude * math.sin(wavePhase + 2);

    path.moveTo(0, startY);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.4 + waveAmplitude * math.sin(wavePhase + 0.5),
      size.width * 0.5,
      midY,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.2 + waveAmplitude * math.sin(wavePhase + 1.5),
      size.width,
      endY,
    );

    canvas.drawPath(path, paint);

    // Your original gradient fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF6366F1).withValues(alpha: 0.3),
          const Color(0xFF6366F1).withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class StaticChartPainter extends CustomPainter {
  final double waveOffset;
  
  StaticChartPainter({this.waveOffset = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Add wave animation to the static chart points
    final waveAmplitude = size.height * 0.08;
    final wavePhase = waveOffset * 2 * 3.14159;
    
    // Animated control points
    final startY = size.height * 0.8 + waveAmplitude * math.sin(wavePhase);
    final midY = size.height * 0.6 + waveAmplitude * math.sin(wavePhase + 1);
    final endY = size.height * 0.5 + waveAmplitude * math.sin(wavePhase + 2);
    
    path.moveTo(0, startY);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.4 + waveAmplitude * math.sin(wavePhase + 0.5),
      size.width * 0.5,
      midY,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.2 + waveAmplitude * math.sin(wavePhase + 1.5),
      size.width,
      endY,
    );

    canvas.drawPath(path, paint);

    // Fill area under curve
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF6366F1).withValues(alpha: 0.3),
          const Color(0xFF6366F1).withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}