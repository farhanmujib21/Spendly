class TransactionModel {
  final int? id;
  final double amount;
  final String type; // 'income' atau 'expense'
  final String category;
  final String categoryIcon;
  final DateTime date;
  final String mood; // 'happy', 'neutral', 'sad', 'stress', 'bored'
  final String? note;
  final String? photoPath;

  TransactionModel({
    this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.categoryIcon,
    required this.date,
    required this.mood,
    this.note,
    this.photoPath,
  });

  // Convert ke Map untuk disimpan ke database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'category': category,
      'categoryIcon': categoryIcon,
      'date': date.millisecondsSinceEpoch,
      'mood': mood,
      'note': note,
      'photoPath': photoPath,
    };
  }

  // Copy dengan perubahan tertentu (untuk edit)
  TransactionModel copyWith({
    int? id,
    double? amount,
    String? type,
    String? category,
    String? categoryIcon,
    DateTime? date,
    String? mood,
    String? note,
    String? photoPath,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  // Convert dari Map (hasil query database) ke object
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: map['amount'],
      type: map['type'],
      category: map['category'],
      categoryIcon: map['categoryIcon'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      mood: map['mood'],
      note: map['note'],
      photoPath: map['photoPath'],
    );
  }
}