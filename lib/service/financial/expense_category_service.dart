import '../api/base/generic_handler.dart';
import '../api/base/id_generator.dart';
import '../../model/expense_category/expense_category.dart';

class ExpenseCategoryService extends ApiService<ExpenseCategory, String> {
  ExpenseCategoryService() : super(endpoint: '/api/ExpensesCategory');

  @override
  ExpenseCategory fromJson(Map<String, dynamic> json) => ExpenseCategory.fromJson(json);

  @override
  Map<String, dynamic> toJson(dynamic data) {
    if (data is ExpenseCategory) return data.toJson();
    if (data is Map<String, dynamic>) return data;
    throw ArgumentError('Unsupported data type for toJson: ${data.runtimeType}');
  }

  // Get all expense categories (inherited method with domain-specific wrapper)
  Future<List<ExpenseCategory>> getAllCategories() async {
    try {
      return await getAll();
    } catch (e) {
      throw Exception('Failed to get expense categories: $e');
    }
  }

  // Get category by ID (inherited method)
  // Future<ExpenseCategory> getById(String categoryId) is inherited

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
      
      return await create(categoryData);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  // Update category (inherited method with domain-specific wrapper)
  Future<ExpenseCategory> updateCategory(Map<String, dynamic> updates) async {
    try {
      return await update<Map<String, dynamic>>(updates);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  // Delete category (inherited method)
  // Future<void> delete(String categoryId) is inherited

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