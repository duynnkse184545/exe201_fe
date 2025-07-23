import '../api/base/generic_handler.dart';
import '../api/base/id_generator.dart';
import '../../model/models.dart';

class ExpenseCategoryService {
  late final ApiService<ExpenseCategory, String> _apiService;

  ExpenseCategoryService() {
    _apiService = ApiService<ExpenseCategory, String>(
      endpoint: '/api/ExpensesCategory',
      fromJson: (json) => ExpenseCategory.fromJson(json),
      toJson: (category) => category.toJson(),
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
        'exCId': IdGenerator.generate(),
        'categoryName': categoryName,
        'description': description,
      };
      
      return await _apiService.create(categoryData);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  // Update category
  Future<ExpenseCategory> updateCategory(Map<String, dynamic> updates) async {
    try {
      return await _apiService.update<Map<String, dynamic>>(updates);
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

}