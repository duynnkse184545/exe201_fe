import '../../model/models.dart';
import 'financial_account_service.dart';
import 'expense_service.dart';
import 'budget_service.dart';
import 'expense_category_service.dart';

class BalanceService {
  final FinancialAccountService _accountService;
  final ExpenseService _expenseService;
  final BudgetService _budgetService;
  final ExpenseCategoryService _categoryService;

  BalanceService({
    FinancialAccountService? accountService,
    ExpenseService? expenseService,
    BudgetService? budgetService,
    ExpenseCategoryService? categoryService,
  }) : _accountService = accountService ?? FinancialAccountService(),
       _expenseService = expenseService ?? ExpenseService(),
       _budgetService = budgetService ?? BudgetService(),
       _categoryService = categoryService ?? ExpenseCategoryService();

  // Get complete balance data (combines all services)
  Future<Balance> getCompleteBalanceData(String userId) async {
    try {
      // Get all data in parallel for better performance
      final futures = await Future.wait([
        _accountService.getUserAccounts(userId),
        _expenseService.getUserExpensesForMonth(userId, DateTime.now()),
        _budgetService.getUserBudgets(userId),
        _categoryService.getAllCategories(),
      ]);
      
      final accounts = futures[0] as List<FinancialAccount>;
      final expenses = futures[1] as List<Expense>;
      final budgets = futures[2] as List<Budget>;
      final categories = futures[3] as List<ExpenseCategory>;
      
      // Get default account balance
      final defaultAccount = accounts.where((account) => account.isDefault).firstOrNull;
      final availableBalance = defaultAccount?.balance ?? 0.0;
      
      // Calculate monthly totals
      double monthlyIncome = 0;
      double monthlyExpenses = 0;
      
      for (final expense in expenses) {
        if (expense.type == ExpenseType.income) {
          monthlyIncome += expense.amount;
        } else {
          monthlyExpenses += expense.amount;
        }
      }
      
      // Enhance budgets with spent amounts and recent transactions
      final enhancedBudgets = await _enhanceBudgetsWithSpentData(budgets, expenses, categories);
      
      // Get recent transactions (last 10 across all categories)
      final recentTransactions = _getRecentTransactionsWithCategoryNames(expenses, categories);
      
      return Balance(
        userId: userId,
        availableBalance: availableBalance,
        monthlyIncome: monthlyIncome,
        monthlyExpenses: monthlyExpenses,
        lastUpdated: DateTime.now(),
        budgets: enhancedBudgets,
        recentTransactions: recentTransactions,
        accounts: accounts,
      );
    } catch (e) {
      throw Exception('Failed to get complete balance data: $e');
    }
  }

  // Update account balance
  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    try {
      await _accountService.updateAccountBalance(accountId, newBalance);
    } catch (e) {
      throw Exception('Failed to update account balance: $e');
    }
  }

  // Add expense/income transaction
  Future<Expense> addExpense(ExpenseRequest request, String userId) async {
    try {
      return await _expenseService.addExpense(request, userId);
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }

  // Set spending limit (create/update budget)
  Future<Budget> setBudget(BudgetRequest request, String userId) async {
    try {
      return await _budgetService.setBudget(request, userId);
    } catch (e) {
      throw Exception('Failed to set budget: $e');
    }
  }

  // Get recent transactions for a specific category
  Future<List<Expense>> getRecentTransactionsForCategory(String userId, String categoryId, {int limit = 5}) async {
    try {
      final categoryExpenses = await _expenseService.getExpensesByCategory(userId, categoryId);
      
      // Sort by date (newest first) and take limit
      categoryExpenses.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      return categoryExpenses.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get recent transactions for category: $e');
    }
  }

  // Get budget health summary
  Future<Map<String, int>> getBudgetHealth(String userId) async {
    try {
      final expenses = await _expenseService.getUserExpensesForMonth(userId, DateTime.now());
      final budgets = await _budgetService.getBudgetsWithSpentAmounts(userId, expenses);
      
      int overBudget = 0;
      int nearLimit = 0; // >80% of budget
      int healthy = 0;   // <80% of budget
      
      for (final budget in budgets) {
        if (budget.isOverBudget) {
          overBudget++;
        } else if (budget.spentPercentage > 80) {
          nearLimit++;
        } else {
          healthy++;
        }
      }
      
      return {
        'overBudget': overBudget,
        'nearLimit': nearLimit,
        'healthy': healthy,
        'total': budgets.length,
      };
    } catch (e) {
      throw Exception('Failed to get budget health: $e');
    }
  }

  // Private helper methods
  Future<List<Budget>> _enhanceBudgetsWithSpentData(
    List<Budget> budgets, 
    List<Expense> expenses, 
    List<ExpenseCategory> categories
  ) async {
    final enhancedBudgets = <Budget>[];
    
    for (final budget in budgets) {
      // Calculate spent amount for this budget
      final spentAmount = await _budgetService.calculateSpentAmount(budget, expenses);
      
      // Get recent transactions for this budget (last 3)
      final relevantExpenses = expenses.where((expense) =>
        expense.exCId == budget.categoryId &&
        expense.type == ExpenseType.expense &&
        expense.createdDate.isAfter(budget.startDate) &&
        expense.createdDate.isBefore(budget.endDate.add(const Duration(days: 1)))
      ).toList();
      
      relevantExpenses.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      final recentTransactions = relevantExpenses.take(3).toList();
      
      // Get category name
      final category = categories.where((cat) => cat.exCId == budget.categoryId).firstOrNull;
      
      enhancedBudgets.add(budget.copyWith(
        spentAmount: spentAmount,
        recentExpenses: recentTransactions,
        categoryName: category?.categoryName,
      ));
    }
    
    return enhancedBudgets;
  }

  // Get recent transactions with category names
  List<Expense> _getRecentTransactionsWithCategoryNames(
    List<Expense> expenses, 
    List<ExpenseCategory> categories
  ) {
    // Sort by date (newest first) and take last 10
    final sortedExpenses = expenses.toList()
      ..sort((a, b) => b.createdDate.compareTo(a.createdDate));
    
    final recentExpenses = sortedExpenses.take(10).toList();
    
    // Add category names
    return recentExpenses.map((expense) {
      final category = categories.where((cat) => cat.exCId == expense.exCId).firstOrNull;
      return expense.copyWith(categoryName: category?.categoryName);
    }).toList();
  }
}