import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../database/database_helper.dart';

class SavingsProvider extends ChangeNotifier {
  List<SavingsGoalModel> _goals = [];

  List<SavingsGoalModel> get goals => _goals;

  Future<void> loadGoals() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('savings_goals');
    _goals = result.map((e) => SavingsGoalModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addGoal(SavingsGoalModel goal) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('savings_goals', goal.toMap());
    await loadGoals();
  }

  Future<void> deleteGoal(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
    await loadGoals();
  }

  Future<void> addFundsToGoal(int id, double amount) async {
    final db = await DatabaseHelper.instance.database;
    final goal = _goals.firstWhere((g) => g.id == id);
    final newAmount = goal.currentAmount + amount;
    final isCompleted = newAmount >= goal.targetAmount;

    await db.update(
      'savings_goals',
      {
        'currentAmount': newAmount,
        'isCompleted': isCompleted ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    await loadGoals();
  }

  // Hapus semua target tabungan
  Future<void> deleteAllGoals() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('savings_goals');
    await loadGoals();
  }

  List<SavingsGoalModel> get activeGoals =>
      _goals.where((g) => !g.isCompleted).toList();

  List<SavingsGoalModel> get completedGoals =>
      _goals.where((g) => g.isCompleted).toList();

  double get totalSaved =>
      _goals.fold(0, (sum, g) => sum + g.currentAmount);
}