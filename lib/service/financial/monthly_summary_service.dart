import 'package:dio/dio.dart';
import '../../model/models.dart';
import '../api/base/api_client.dart';

class MonthlySummaryService {
  final Dio dio = ApiClient().dio;

  Future<MonthlySummary> getMonthlySummary(int year, int month) async {
    try {
      final response = await dio.get('/api/monthly-summary', queryParameters: {
        'year': year,
        'month': month,
      });

      if (response.data['isSuccess'] == true) {
        // Manual construction to handle the enhanced budget structure
        final data = response.data['data'];
        
        // Parse categoryBreakdown as Budget objects
        final List<Budget> categoryBreakdown = [];
        if (data['categoryBreakdown'] != null) {
          for (final budgetData in data['categoryBreakdown']) {
            categoryBreakdown.add(Budget(
              budgetId: budgetData['budgetId']?.toString() ?? '',
              categoryId: budgetData['categoryId']?.toString() ?? '',
              accountId: budgetData['accountId']?.toString() ?? '',
              budgetAmount: (budgetData['budgetAmount'] ?? 0.0).toDouble(),
              startDate: DateTime.parse(budgetData['startDate'] ?? DateTime.now().toIso8601String()),
              endDate: DateTime.parse(budgetData['endDate'] ?? DateTime.now().toIso8601String()),
              userId: budgetData['userId']?.toString() ?? '',
              spentAmount: (budgetData['spentAmount'] ?? 0.0).toDouble(),
              remainingAmount: (budgetData['remainingAmount'] ?? 0.0).toDouble(),
              spentPercentage: (budgetData['spentPercentage'] ?? 0.0).toDouble(),
              isOverBudget: budgetData['isOverBudget'] ?? false,
              isLocked: budgetData['isLocked'] ?? false,
              categoryName: budgetData['categoryName'] ?? '',
            ));
          }
        }

        // Parse transactions as Expense objects (same as Balance model)
        final List<Expense> transactions = [];
        if (data['transactions'] != null) {
          for (final txData in data['transactions']) {
            transactions.add(Expense(
              expensesId: txData['expensesId']?.toString() ?? '',
              amount: (txData['amount'] ?? 0.0).toDouble(),
              description: txData['description'] ?? '',
              createdDate: DateTime.parse(txData['createdDate'] ?? DateTime.now().toIso8601String()),
              exCid: txData['exCid']?.toString() ?? '',
              accountId: txData['accountId']?.toString() ?? '',
              userId: data['userId']?.toString() ?? '',
              categoryName: txData['categoryName'] ?? '',
            ));
          }
        }

        return MonthlySummary(
          userId: data['userId']?.toString() ?? '',
          year: data['year'] ?? DateTime.now().year,
          month: data['month'] ?? DateTime.now().month,
          totalIncome: (data['totalIncome'] ?? 0.0).toDouble(),
          totalExpenses: (data['totalExpenses'] ?? 0.0).toDouble(),
          netAmount: (data['netAmount'] ?? 0.0).toDouble(),
          transactionCount: data['transactionCount'] ?? 0,
          categoryBreakdown: categoryBreakdown,
          transactions: transactions,
        );
      } else {
        throw Exception('API Error: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to get monthly summary: ${_formatError(e)}');
    }
  }

  String _formatError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final responseData = e.response!.data;

      if (statusCode == 400) {
        if (responseData is Map) {
          return 'Bad Request (400): ${responseData.toString()}';
        } else if (responseData is String) {
          return 'Bad Request (400): $responseData';
        } else {
          return 'Bad Request (400): Invalid request data';
        }
      }

      return 'HTTP $statusCode: ${responseData ?? e.message}';
    } else {
      return e.message ?? 'Network error';
    }
  }
}