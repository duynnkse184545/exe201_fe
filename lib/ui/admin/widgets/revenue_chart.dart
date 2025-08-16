import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../provider/admin_providers.dart';
import '../../extra/theme_extensions.dart';

class RevenueChart extends ConsumerStatefulWidget {
  const RevenueChart({super.key});

  @override
  ConsumerState<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends ConsumerState<RevenueChart> {
  int selectedDataSetIndex = 0;

  // VND Currency Formatter
  static final NumberFormat vndFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final revenueGrowthAsync = ref.watch(revenueGrowthDataNotifierProvider);
    final userGrowthAsync = ref.watch(userGrowthDataNotifierProvider);

    return revenueGrowthAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          children: [
            Text('Error loading chart data: $error'),
            ElevatedButton(
              onPressed: () => ref.invalidate(revenueGrowthDataNotifierProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (revenueGrowthData) {
        return userGrowthAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              children: [
                Text('Error loading user data: $error'),
                ElevatedButton(
                  onPressed: () => ref.invalidate(userGrowthDataNotifierProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (userGrowthData) {
            // Convert API data to FlSpot format
            final revenueSpots = _convertToFlSpots(revenueGrowthData, 'revenue');
            final userSpots = _convertToFlSpots(userGrowthData, 'users');

            // Calculate max values for better scaling
            final maxRevenue = revenueSpots.isEmpty ? 10000000.0 :
            revenueSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.2;
            final maxUsers = userSpots.isEmpty ? 500.0 :
            userSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.2;

            return Column(
              children: [
                // Chart Type Selector
                Row(
                  children: [
                    _buildChartSelector("Revenue", 0),
                    const SizedBox(width: 12),
                    _buildChartSelector("Users", 1),
                  ],
                ),
                const SizedBox(height: 20),

                // Chart
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: selectedDataSetIndex == 0
                            ? (maxRevenue / 6).roundToDouble()
                            : (maxUsers / 6).roundToDouble(),
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey[200]!,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              const months = [
                                'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                              ];
                              if (value.toInt() >= 1 && value.toInt() <= 12) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    months[value.toInt() - 1],
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }
                              return Container();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: selectedDataSetIndex == 0
                                ? (maxRevenue / 6).roundToDouble()
                                : (maxUsers / 6).roundToDouble(),
                            reservedSize: 60,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              String text;
                              if (selectedDataSetIndex == 0) {
                                // Format VND values
                                if (value >= 1000000000) {
                                  text = '${(value / 1000000000).toStringAsFixed(1)}B₫';
                                } else if (value >= 1000000) {
                                  text = '${(value / 1000000).toStringAsFixed(1)}M₫';
                                } else if (value >= 1000) {
                                  text = '${(value / 1000).toStringAsFixed(0)}K₫';
                                } else {
                                  text = '${value.toInt()}₫';
                                }
                              } else {
                                text = value.toInt().toString();
                              }
                              return Text(
                                text,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      minX: 1,
                      maxX: 12,
                      minY: 0,
                      maxY: selectedDataSetIndex == 0 ? maxRevenue : maxUsers,
                      lineBarsData: [
                        LineChartBarData(
                          spots: selectedDataSetIndex == 0 ? revenueSpots : userSpots,
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              context.primaryColor,
                              context.primaryColor.withValues(alpha: 0.3),
                            ],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: context.primaryColor,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                context.primaryColor.withValues(alpha: 0.2),
                                context.primaryColor.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final flSpot = barSpot;
                              String value;
                              if (selectedDataSetIndex == 0) {
                                value = vndFormatter.format(flSpot.y);
                              } else {
                                value = '${flSpot.y.toInt()} users';
                              }

                              const months = [
                                'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                              ];
                              final month = months[flSpot.x.toInt() - 1];

                              return LineTooltipItem(
                                '$month\n$value',
                                TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<FlSpot> _convertToFlSpots(List<Map<String, dynamic>> data, String valueKey) {
    if (data.isEmpty) {
      // Return default data if API data is empty
      return List.generate(12, (index) => FlSpot((index + 1).toDouble(), 0));
    }

    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final value = (item[valueKey] ?? 0).toDouble();
      return FlSpot((index + 1).toDouble(), value);
    }).toList();
  }

  Widget _buildChartSelector(String title, int index) {
    final isSelected = selectedDataSetIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDataSetIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}