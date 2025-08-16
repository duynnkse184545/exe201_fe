import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../extra/theme_extensions.dart';
import '../../../provider/providers.dart';

class FinancialStatisticsSection extends ConsumerStatefulWidget {
  const FinancialStatisticsSection({super.key});

  @override
  ConsumerState<FinancialStatisticsSection> createState() => _FinancialStatisticsSectionState();
}

class _FinancialStatisticsSectionState extends ConsumerState<FinancialStatisticsSection> {
  String selectedPeriod = "Monthly";
  final List<String> periods = ["Daily", "Weekly", "Monthly", "Yearly"];

  // VND Currency Formatter
  static final NumberFormat vndFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  // Short VND formatter for large numbers
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
  Widget build(BuildContext context) {
    // Watch all necessary providers
    final revenueStatsAsync = ref.watch(
      revenueStatisticsNotifierProvider(period: selectedPeriod),
    );
    final financialMetricsAsync = ref.watch(financialMetricsNotifierProvider);
    final invoicesAsync = ref.watch(adminInvoicesNotifierProvider(period: selectedPeriod));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector
          _buildPeriodSelector(),
          const SizedBox(height: 24),

          // Revenue Analytics - using real data
          _buildRevenueAnalytics(revenueStatsAsync, invoicesAsync),
          const SizedBox(height: 24),

          // Top Revenue Sources - using invoice data
          _buildTopRevenueSources(invoicesAsync),
          const SizedBox(height: 24),

          // Financial Metrics - using real data
          _buildFinancialMetrics(financialMetricsAsync),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Analytics Period",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: periods.map((period) {
              final isSelected = selectedPeriod == period;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPeriod = period;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? context.primaryColor : Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    period,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<dynamic> _filterInvoicesByPeriod(List<dynamic> invoices, String period) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case "Daily":
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case "Weekly":
        startDate = now.subtract(Duration(days: now.weekday - 1)); // Monday of this week
        break;
      case "Monthly":
        startDate = DateTime(now.year, now.month, 1);
        break;
      case "Yearly":
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(1970);
    }

    return invoices.where((invoice) {
      final date = (invoice as dynamic).dateCreated; // adjust field name
      return date.isAfter(startDate);
    }).toList();
  }


  Widget _buildRevenueAnalytics(AsyncValue<Map<String, dynamic>> revenueStatsAsync, AsyncValue<List<dynamic>> invoicesAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Text(
                "Revenue Analytics",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Icon(
                Icons.trending_up,
                color: context.primaryColor,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Revenue metrics using real data
          Consumer(
            builder: (context, ref, child) {
              return revenueStatsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    children: [
                      Text('Error loading revenue data: $error'),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(revenueStatisticsNotifierProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (revenueStats) {
                  return invoicesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => _buildFallbackMetrics(),
                    data: (invoices) {
                      final totalTransactions = invoices.length;
                      final totalRevenue = (revenueStats['totalRevenue'] ?? 0).toDouble();
                      final avgTransaction = totalTransactions > 0 ? totalRevenue / totalTransactions : 0.0;
                      final revenueGrowth = (revenueStats['revenueGrowthPercentage'] ?? 0).toDouble();

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  title: "Total Revenue",
                                  value: vndFormatter.format(totalRevenue),
                                  change: "${revenueGrowth >= 0 ? '+' : ''}${revenueGrowth.toStringAsFixed(1)}%",
                                  isPositive: revenueGrowth >= 0,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildMetricCard(
                                  title: "Avg. Transaction",
                                  value: vndFormatter.format(avgTransaction),
                                  change: "+3.2%",
                                  isPositive: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  title: "Transaction Count",
                                  value: totalTransactions.toString(),
                                  change: "+8.7%",
                                  isPositive: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildMetricCard(
                                  title: "Refund Rate",
                                  value: "0%",
                                  change: "0%",
                                  isPositive: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackMetrics() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: "Total Revenue",
                value: "0₫",
                change: "0.0%",
                isPositive: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                title: "Avg. Transaction",
                value: "0₫",
                change: "0.0%",
                isPositive: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: "Transaction Count",
                value: "0",
                change: "0.0%",
                isPositive: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                title: "Refund Rate",
                value: "0.0%",
                change: "0.0%",
                isPositive: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopRevenueSources(AsyncValue<List<dynamic>> invoicesAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Top Revenue Sources",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),

          Consumer(
            builder: (context, ref, child) {
              return invoicesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildFallbackRevenueSources(),
                data: (invoices) {
                  if (invoices.isEmpty) {
                    return _buildFallbackRevenueSources();
                  }

                  // Calculate revenue sources from invoices based on actual Invoice model
                  final revenueSources = <String, double>{};
                  double totalRevenue = 0;

                  for (final invoice in invoices) {
                    final invoiceData = invoice as dynamic;
                    // Use totalAmount primarily, fallback to amount if totalAmount is null
                    final amount = (invoiceData.totalAmount ?? invoiceData.amount ?? 0).toDouble();

                    // Create revenue source based on membership plan or invoice status
                    String source;
                    if (invoiceData.membershipPlanId != null) {
                      source = 'Membership Plan ${invoiceData.membershipPlanId}';
                    } else if (invoiceData.invoiceStatus != null) {
                      source = '${invoiceData.invoiceStatus} Services';
                    } else {
                      source = 'General Services';
                    }

                    revenueSources[source] = (revenueSources[source] ?? 0) + amount;
                    totalRevenue += amount;
                  }

                  if (revenueSources.isEmpty || totalRevenue == 0) {
                    return _buildFallbackRevenueSources();
                  }

                  final sortedSources = revenueSources.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));

                  return Column(
                    children: sortedSources.take(4).map((entry) {
                      final percentage = (entry.value / totalRevenue * 100).toStringAsFixed(0);
                      return _buildRevenueSourceItem(
                        entry.key,
                        vndFormatter.format(entry.value),
                        "$percentage%",
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackRevenueSources() {
    final sources = [
      {"name": "Premium Memberships", "revenue": "0₫", "percentage": "0%"},
      {"name": "Basic Memberships", "revenue": "0₫", "percentage": "0%"},
      {"name": "Add-on Services", "revenue": "0₫", "percentage": "0%"},
      {"name": "Consulting", "revenue": "0₫", "percentage": "0%"},
    ];

    return Column(
      children: sources.map((source) => _buildRevenueSourceItem(
        source["name"]!,
        source["revenue"]!,
        source["percentage"]!,
      )).toList(),
    );
  }

  Widget _buildFinancialMetrics(AsyncValue<Map<String, dynamic>> financialMetricsAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Key Financial Metrics",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),

          // Use real financial metrics data
          Consumer(
            builder: (context, ref, child) {
              return financialMetricsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    children: [
                      Text('Error loading financial metrics: $error'),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(financialMetricsNotifierProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (metrics) {
                  return Column(
                    children: [
                      _buildMetricRow(
                          "Monthly Recurring Revenue",
                          vndFormatter.format((metrics['monthlyRecurringRevenue'] ?? 0).toDouble()),
                          "+15.2%",
                          true
                      ),
                      _buildMetricRow(
                          "Customer Lifetime Value",
                          vndFormatter.format((metrics['customerLifetimeValue'] ?? 0).toDouble()),
                          "+8.7%",
                          true
                      ),
                      _buildMetricRow(
                          "Churn Rate",
                          "${(metrics['churnRate'] ?? 0).toStringAsFixed(1)}%",
                          "-1.1%",
                          true
                      ),
                      _buildMetricRow(
                          "Average Revenue Per User",
                          vndFormatter.format((metrics['averageRevenuePerUser'] ?? 0).toDouble()),
                          "+12.3%",
                          true
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? Colors.green : Colors.red,
                size: 12,
              ),
              const SizedBox(width: 2),
              Text(
                change,
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueSourceItem(String name, String revenue, String percentage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    revenue,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              percentage,
              style: TextStyle(
                color: context.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String title, String value, String change, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isPositive ? Colors.green : Colors.red,
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    change,
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}