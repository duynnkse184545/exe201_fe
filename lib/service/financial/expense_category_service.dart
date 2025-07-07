import '../api/base/generic_handler.dart';
import '../../model/models.dart';

class ExpenseCategoryService {
  late final ApiService<ExpenseCategory, String> _apiService;

  ExpenseCategoryService() {
    _apiService = ApiService<ExpenseCategory, String>(
      endpoint: '/api/expense-categories',
      fromJson: (json) => ExpenseCategory.fromJson(json),
    );
  }

  // Get all expense categories
  Future<List<ExpenseCategory>> getAllCategories() async {
    try {
      return await _apiService.getAll();
    } catch (e) {
      throw Exception('Failed to get expense categories: $e');
    }
  }

  // Get category by ID
  Future<ExpenseCategory> getCategoryById(String categoryId) async {
    try {
      return await _apiService.getById(categoryId);
    } catch (e) {
      throw Exception('Failed to get category: $e');
    }
  }

  // Create new category
  Future<ExpenseCategory> createCategory({
    required String categoryName,
    String? description,
  }) async {
    try {
      final categoryData = {
        'exCId': _generateId(),
        'categoryName': categoryName,
        'description': description,
      };
      
      return await _apiService.create(categoryData);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  // Update category
  Future<ExpenseCategory> updateCategory(String categoryId, Map<String, dynamic> updates) async {
    try {
      return await _apiService.update(categoryId, updates);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  // Delete category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _apiService.delete(categoryId);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // Search categories by name
  Future<List<ExpenseCategory>> searchCategories(String searchTerm) async {
    try {
      final allCategories = await getAllCategories();
      return allCategories
          .where((category) => 
            category.categoryName.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search categories: $e');
    }
  }

  // Get category by name
  Future<ExpenseCategory?> getCategoryByName(String categoryName) async {
    try {
      final allCategories = await getAllCategories();
      return allCategories
          .where((category) => 
            category.categoryName.toLowerCase() == categoryName.toLowerCase())
          .firstOrNull;
    } catch (e) {
      throw Exception('Failed to get category by name: $e');
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}