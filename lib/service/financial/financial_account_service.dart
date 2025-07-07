import '../api/base/generic_handler.dart';
import '../../model/models.dart';

class FinancialAccountService {
  late final ApiService<FinancialAccount, String> _apiService;

  FinancialAccountService() {
    _apiService = ApiService<FinancialAccount, String>(
      endpoint: '/api/financial-accounts',
      fromJson: (json) => FinancialAccount.fromJson(json),
    );
  }

  // Get all accounts for a user
  Future<List<FinancialAccount>> getUserAccounts(String userId) async {
    try {
      final allAccounts = await _apiService.getAll();
      return allAccounts.where((account) => account.userId == userId).toList();
    } catch (e) {
      throw Exception('Failed to get user accounts: $e');
    }
  }

  // Get user's default account
  Future<FinancialAccount?> getUserDefaultAccount(String userId) async {
    try {
      final accounts = await getUserAccounts(userId);
      return accounts.where((account) => account.isDefault).firstOrNull;
    } catch (e) {
      throw Exception('Failed to get default account: $e');
    }
  }

  // Get account by ID
  Future<FinancialAccount> getAccountById(String accountId) async {
    try {
      return await _apiService.getById(accountId);
    } catch (e) {
      throw Exception('Failed to get account: $e');
    }
  }

  // Create new account
  Future<FinancialAccount> createAccount({
    required String accountName,
    required double balance,
    required String userId,
    String currencyCode = 'VND',
    bool isDefault = false,
  }) async {
    try {
      final accountData = {
        'accountId': _generateId(),
        'accountName': accountName,
        'balance': balance,
        'currencyCode': currencyCode,
        'userId': userId,
        'isDefault': isDefault,
      };
      
      return await _apiService.create(accountData);
    } catch (e) {
      throw Exception('Failed to create account: $e');
    }
  }

  // Update account balance
  Future<FinancialAccount> updateAccountBalance(String accountId, double newBalance) async {
    try {
      final updateData = {'balance': newBalance};
      return await _apiService.update(accountId, updateData);
    } catch (e) {
      throw Exception('Failed to update account balance: $e');
    }
  }

  // Update account details
  Future<FinancialAccount> updateAccount(String accountId, Map<String, dynamic> updates) async {
    try {
      return await _apiService.update(accountId, updates);
    } catch (e) {
      throw Exception('Failed to update account: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount(String accountId) async {
    try {
      await _apiService.delete(accountId);
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}