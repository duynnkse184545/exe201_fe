import '../api/base/generic_handler.dart';
import '../api/base/id_generator.dart';
import '../../model/models.dart';

class FinancialAccountService extends ApiService<FinancialAccount, String> {
  FinancialAccountService() : super(endpoint: '/api/FinancialAccount');

  @override
  FinancialAccount fromJson(Map<String, dynamic> json) => FinancialAccount.fromJson(json);

  @override
  Map<String, dynamic> toJson(dynamic data) {
    if (data is FinancialAccount) return data.toJson();
    if (data is FinancialAccountRequest) return data.toJson();
    if (data is Map<String, dynamic>) return data;
    throw ArgumentError('Unsupported data type for toJson: ${data.runtimeType}');
  }

  // Get all accounts for a user
  Future<List<FinancialAccount>> getUserAccounts(String userId) async {
    try {
      final allAccounts = await getAll();
      return allAccounts.where((account) => account.userId == userId).toList();
    } catch (e) {
      throw Exception('Failed to get user accounts: $e');
    }
  }

  // Get account by ID (inherited method)
  // Future<FinancialAccount> getById(String accountId) is inherited

  // Get default account for user
  Future<FinancialAccount?> getDefaultAccount(String userId) async {
    try {
      final userAccounts = await getUserAccounts(userId);
      return userAccounts.where((account) => account.isDefault).firstOrNull;
    } catch (e) {
      throw Exception('Failed to get default account: $e');
    }
  }

  // Create new account (inherited method with domain-specific wrapper)
  Future<FinancialAccount> createAccount(FinancialAccountRequest request) async {
    try {
      return await create<FinancialAccountRequest>(request);
    } catch (e) {
      throw Exception('Failed to create account: $e');
    }
  }

  // Update account (inherited method with domain-specific wrapper)
  Future<FinancialAccount> updateAccount(FinancialAccountRequest updates) async {
    try {
      if (updates.accountId == null) {
        throw ArgumentError('accountId is required for update operations');
      }
      return await updateById<FinancialAccountRequest>(updates.accountId!, updates);
    } catch (e) {
      throw Exception('Failed to update account: $e');
    }
  }

  // Update account balance
  Future<FinancialAccount> updateBalance(String accountId, double newBalance, String userId, String accountName) async {
    try {
      final request = FinancialAccountRequest(
        accountId: accountId,
        accountName: accountName,
        balance: newBalance,
        userId: userId,
      );
      return await updateAccount(request);
    } catch (e) {
      throw Exception('Failed to update balance: $e');
    }
  }

  // Set account as default (and unset others)
  Future<FinancialAccount> setAsDefault(String accountId, String userId) async {
    try {
      // First, unset all other accounts as default
      final userAccounts = await getUserAccounts(userId);
      for (final account in userAccounts) {
        if (account.isDefault && account.accountId != accountId) {
          final request = FinancialAccountRequest(
            accountId: account.accountId,
            accountName: account.accountName,
            balance: account.balance,
            currencyCode: account.currencyCode,
            userId: account.userId,
            isDefault: false,
          );
          await updateAccount(request);
        }
      }
      
      // Then set the target account as default
      final targetAccount = await getById(accountId);
      final request = FinancialAccountRequest(
        accountId: targetAccount.accountId,
        accountName: targetAccount.accountName,
        balance: targetAccount.balance,
        currencyCode: targetAccount.currencyCode,
        userId: targetAccount.userId,
        isDefault: true,
      );
      return await updateAccount(request);
    } catch (e) {
      throw Exception('Failed to set default account: $e');
    }
  }

  // Delete account (inherited method)
  // Future<void> delete(String accountId) is inherited

  // Check if user has any accounts
  Future<bool> hasAccounts(String userId) async {
    try {
      final accounts = await getUserAccounts(userId);
      return accounts.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check accounts: $e');
    }
  }

  // Create default account for new user
  Future<FinancialAccount> createDefaultAccount(String userId, {double initialBalance = 0}) async {
    try {
      final request = FinancialAccountRequest(
        accountName: 'Main Account',
        balance: initialBalance,
        userId: userId,
        isDefault: true,
      );
      return await createAccount(request);
    } catch (e) {
      throw Exception('Failed to create default account: $e');
    }
  }

}