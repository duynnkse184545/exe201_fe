import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../extra/theme_extensions.dart';
import '../../../provider/providers.dart';

class AdminStatsCards extends ConsumerWidget {
  const AdminStatsCards({super.key});

  // VND Currency Formatter
  static final NumberFormat vndFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  // Short VND formatter for large numbers (e.g., 1.2M₫, 5.3K₫)
  static String formatVndShort(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B₫';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M₫';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K₫';
    } else {
      return vndFormatter.format(amount);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardDataAsync = ref.watch(adminDashboardDataProvider);

    return dashboardDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading stats: $error')),
      data: (dashboardData) {
        final userStats = dashboardData['userStats'] as Map<String, dynamic>;
        final revenueStats =
        dashboardData['revenueStats'] as Map<String, dynamic>;
        final financialMetrics =
        dashboardData['financialMetrics'] as Map<String, dynamic>;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    title: "Total Users",
                    value: "${userStats['totalUsers'] ?? 0}",
                    icon: Icons.people,
                    color: context.primaryColor,
                    trend:
                    "${userStats['userGrowthPercentage']?.toStringAsFixed(1) ?? '0'}%",
                    isPositive: (userStats['userGrowthPercentage'] ?? 0) >= 0,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    title: "Active Users",
                    value: "${userStats['activeUsers'] ?? 0}",
                    icon: Icons.person_outline,
                    color: Colors.green,
                    trend: "+${userStats['newUsersThisMonth'] ?? 0}",
                    isPositive: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    title: "Total Revenue",
                    value: formatVndShort(revenueStats['totalRevenue']?.toDouble() ?? 0),
                    icon: Icons.attach_money,
                    color: Colors.orange,
                    trend:
                    "${revenueStats['revenueGrowthPercentage']?.toStringAsFixed(1) ?? '0'}%",
                    isPositive:
                    (revenueStats['revenueGrowthPercentage'] ?? 0) >= 0,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    title: "Monthly Revenue",
                    value: formatVndShort(revenueStats['monthlyRecurringRevenue']?.toDouble() ?? 0),
                    icon: Icons.trending_up,
                    color: Colors.purple,
                    trend:
                    "${financialMetrics['churnRate']?.toStringAsFixed(1) ?? '0'}%",
                    isPositive:
                    (financialMetrics['churnRate'] ?? 0) <=
                        5, // Low churn is positive
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isPositive ? Colors.green : Colors.red,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}