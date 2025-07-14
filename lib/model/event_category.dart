class EventCategory {
  final String? evCategoryId;
  final String? categoryName;
  final String? description;

  EventCategory({
    this.evCategoryId,
    required this.categoryName,
    this.description,
  });

  factory EventCategory.fromJson(Map<String, dynamic> json) {
    return EventCategory(
      evCategoryId: json['evCategoryId'],
      categoryName: json['categoryName'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evCategoryId': evCategoryId,
      'categoryName': categoryName,
      'description': description,
    };
  }
}