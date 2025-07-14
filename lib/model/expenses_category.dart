class ExpensesCategory {
  final String? exCid;
  final String? categoryName;
  final String? description;

  ExpensesCategory({
    this.exCid,
    required this.categoryName,
    this.description,
  });

  factory ExpensesCategory.fromJson(Map<String, dynamic> json) {
    return ExpensesCategory(
      exCid: json['exCid'],
      categoryName: json['categoryName'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exCid': exCid,
      'categoryName': categoryName,
      'description': description,
    };
  }
}