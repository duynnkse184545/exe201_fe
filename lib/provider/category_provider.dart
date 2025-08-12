import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/expense_category/expense_category.dart';
import 'service_providers.dart';

part 'category_provider.g.dart';

// Provider for expense categories
@riverpod
class ExpenseCategoriesNotifier extends _$ExpenseCategoriesNotifier {
  @override
  Future<List<ExpenseCategory>> build() async {
    final service = ref.watch(expenseCategoryServiceProvider);
    return await service.getAllCategories();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final service = ref.read(expenseCategoryServiceProvider);
      final categories = await service.getAllCategories();
      state = AsyncData(categories);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  // Create new category
  Future<void> createCategory({
    required String categoryName,
    String? description,
  }) async {
    try {
      final service = ref.read(expenseCategoryServiceProvider);
      await service.createCategory(
        categoryName: categoryName,
        description: description,
      );
      
      // Refresh to include new category
      await refresh();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  // Update category
  Future<void> updateCategory({
    required String categoryId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final service = ref.read(expenseCategoryServiceProvider);
      await service.updateCategory(updates);
      
      // Refresh to reflect changes
      await refresh();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  // Delete category
  Future<void> deleteCategory(String categoryId) async {
    try {
      final service = ref.read(expenseCategoryServiceProvider);
      await service.delete(categoryId);
      
      // Refresh to reflect changes
      await refresh();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  // Search categories
  Future<List<ExpenseCategory>> searchCategories(String searchTerm) async {
    try {
      final service = ref.read(expenseCategoryServiceProvider);
      return await service.searchCategories(searchTerm);
    } catch (e) {
      throw Exception('Failed to search categories: $e');
    }
  }
}