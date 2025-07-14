import '../../model/models.dart';
import '../api/base/generic_handler.dart';

class BalanceService {
  late final ApiService<Map<String, dynamic>, String> _apiService;

  BalanceService() {
    _apiService = ApiService<Map<String, dynamic>, String>(
      endpoint: '/api/enhanced-financial-dashboard',
      fromJson: (json) => json,
    );
  }

  // Get complete balance data from backend (replaces ALL frontend logic)
  Future<Balance> getCompleteBalanceData(String userId) async {
    try {
      final response = await _apiService.getById('complete-balance/$userId');
      
      // Backend returns wrapped response with isSuccess, code, data structure
      final data = response['data'] ?? response;
      
      // Convert backend response to existing Balance model
      return Balance(
        userId: data['userId'] ?? userId,
        availableBalance: (data['availableBalance'] ?? 0.0).toDouble(),
        monthlyIncome: (data['monthlyIncome'] ?? 0.0).toDouble(),
        monthlyExpenses: (data['monthlyExpenses'] ?? 0.0).toDouble(),
        lastUpdated: DateTime.tryParse(data['lastUpdated'] ?? '') ?? DateTime.now(),
        budgets: _convertBudgets(data['budgets'] ?? []),
        recentTransactions: _convertTransactions(data['recentTransactions'] ?? []),
        accounts: _convertAccounts(data['accounts'] ?? []),
        isLoading: false,
        error: null,
      );
    } catch (e) {
      throw Exception('Failed to get complete balance data: $e');
    }
  }

  // Update account balance (simple passthrough to backend)
  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    try {
      await _apiService.update('account-balance/$accountId', {'balance': newBalance});
    } catch (e) {
      throw Exception('Failed to update account balance: $e');
    }
  }

  // Add expense (now uses backend processing)
  Future<Expense> addExpense(ExpenseRequest request, String userId) async {
    try {
      final expenseData = request.toJson();
      expenseData['userId'] = userId;
      expenseData['expensesId'] = _generateId();
      expenseData['createdDate'] = DateTime.now().toIso8601String();
      
      final response = await _apiService.create(expenseData);
      return _convertSingleTransaction(response);
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }

  // Set budget (now uses backend processing)
  Future<Budget> setBudget(BudgetRequest request, String userId) async {
    try {
      final budgetData = request.toJson();
      budgetData['userId'] = userId;
      budgetData['budgetId'] = _generateId();
      budgetData['isLocked'] = false;
      
      final response = await _apiService.create(budgetData);
      return _convertSingleBudget(response);
    } catch (e) {
      throw Exception('Failed to set budget: $e');
    }
  }

  // Get recent transactions for category (backend processed)
  Future<List<Expense>> getRecentTransactionsForCategory(String userId, String categoryId, {int limit = 5}) async {
    try {
      final response = await _apiService.getById('category-transactions/$userId/$categoryId?limit=$limit');
      final List<dynamic> transactionsList = response['transactions'] ?? [];
      return _convertTransactions(transactionsList);
    } catch (e) {
      throw Exception('Failed to get recent transactions for category: $e');
    }
  }

  // Get budget health (backend computed)
  Future<Map<String, int>> getBudgetHealth(String userId) async {
    try {
      final response = await _apiService.getById('budget-utilization/$userId');
      return {
        'overBudget': response['overBudgetCount'] ?? 0,
        'nearLimit': response['nearLimitCount'] ?? 0,
        'healthy': response['healthyCount'] ?? 0,
        'total': response['totalBudgets'] ?? 0,
      };
    } catch (e) {
      throw Exception('Failed to get budget health: $e');
    }
  }

  // Toggle budget lock for next month
  Future<Budget> toggleBudgetLock(String budgetId, bool isLocked) async {
    try {
      final response = await _apiService.update('budget-lock/$budgetId', {'isLocked': isLocked});
      return _convertSingleBudget(response);
    } catch (e) {
      throw Exception('Failed to toggle budget lock: $e');
    }
  }

  // Convert backend budget data to existing Budget model
  List<Budget> _convertBudgets(List<dynamic> budgetsJson) {
    return budgetsJson.map((json) => _convertSingleBudget(json)).toList();
  }

  Budget _convertSingleBudget(Map<String, dynamic> json) {
    return Budget(
      budgetId: json['budgetId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      accountId: json['accountId'] ?? '',
      budgetAmount: (json['budgetAmount'] ?? 0.0).toDouble(),
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      userId: json['userId'] ?? '',
      spentAmount: (json['spentAmount'] ?? 0.0).toDouble(), // Pre-calculated by backend
      remainingAmount: (json['remainingAmount'] ?? 0.0).toDouble(), // Pre-calculated by backend
      spentPercentage: (json['spentPercentage'] ?? 0.0).toDouble(), // Pre-calculated by backend
      isOverBudget: json['isOverBudget'] ?? false, // Pre-calculated by backend
      isLocked: json['isLocked'] ?? false, // Budget lock for next month
      recentExpenses: _convertTransactions(json['recentExpenses'] ?? []),
      categoryName: json['categoryName'],
    );
  }

  // Convert backend transaction data to existing Expense model
  List<Expense> _convertTransactions(List<dynamic> transactionsJson) {
    return transactionsJson.map((json) => _convertSingleTransaction(json)).toList();
  }

  Expense _convertSingleTransaction(Map<String, dynamic> json) {
    return Expense(
      expensesId: json['expenseId'] ?? json['expensesId'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      description: json['description'],
      createdDate: DateTime.tryParse(json['createdDate'] ?? '') ?? DateTime.now(),
      exCId: json['categoryId'] ?? json['exCId'] ?? '',
      accountId: json['accountId'] ?? '',
      userId: json['userId'] ?? '',
      categoryName: json['categoryName'],
    );
  }

  // Convert backend account data to existing FinancialAccount model
  List<FinancialAccount> _convertAccounts(List<dynamic> accountsJson) {
    return accountsJson.map((json) => FinancialAccount(
      accountId: json['accountId'] ?? '',
      accountName: json['accountName'] ?? '',
      balance: (json['balance'] ?? 0.0).toDouble(),
      currencyCode: json['currencyCode'] ?? 'VND',
      userId: json['userId'] ?? '',
      isDefault: json['isDefault'] ?? false,
    )).toList();
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}