class SavingsGoalModel {
  final int? id;
  final String name;
  final String icon;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final bool isCompleted;

  SavingsGoalModel({
    this.id,
    required this.name,
    required this.icon,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
    this.isCompleted = false,
  });

  double get percentage =>
      targetAmount == 0 ? 0 : (currentAmount / targetAmount).clamp(0, 1);

  // Hitung nominal yang perlu disisihkan per hari
  double get dailySavingsNeeded {
    if (deadline == null || isCompleted) return 0;
    final daysLeft = deadline!.difference(DateTime.now()).inDays;
    if (daysLeft <= 0) return 0;
    final remaining = targetAmount - currentAmount;
    return remaining > 0 ? remaining / daysLeft : 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline?.millisecondsSinceEpoch,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory SavingsGoalModel.fromMap(Map<String, dynamic> map) {
    return SavingsGoalModel(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      targetAmount: map['targetAmount'],
      currentAmount: map['currentAmount'],
      deadline: map['deadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deadline'])
          : null,
      isCompleted: map['isCompleted'] == 1,
    );
  }
}