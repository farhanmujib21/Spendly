class BudgetModel {
  final int? id;
  final String category;
  final String categoryIcon;
  final double monthlyLimit;
  final double currentSpent;

  BudgetModel({
    this.id,
    required this.category,
    required this.categoryIcon,
    required this.monthlyLimit,
    this.currentSpent = 0,
  });

  double get percentage =>
      monthlyLimit == 0 ? 0 : (currentSpent / monthlyLimit).clamp(0, 1);

  bool get isWarning => percentage >= 0.7 && percentage < 0.9;
  bool get isDanger => percentage >= 0.9;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'categoryIcon': categoryIcon,
      'monthlyLimit': monthlyLimit,
      'currentSpent': currentSpent,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      category: map['category'],
      categoryIcon: map['categoryIcon'],
      monthlyLimit: map['monthlyLimit'],
      currentSpent: map['currentSpent'],
    );
  }
}