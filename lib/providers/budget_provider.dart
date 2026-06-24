import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../database/database_helper.dart';

class BudgetProvider extends ChangeNotifier {
  List<BudgetModel> _budgets = [];

  List<BudgetModel> get budgets => _budgets;

  Future<void> loadBudgets() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('budgets');
    _budgets = result.map((e) => BudgetModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addBudget(BudgetModel budget) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('budgets', budget.toMap());
    await loadBudgets();
  }

  // Edit nominal limit budget yang sudah ada
  Future<void> editBudgetLimit(int id, double newLimit) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'budgets',
      {'monthlyLimit': newLimit},
      where: 'id = ?',
      whereArgs: [id],
    );
    await loadBudgets();
  }

  Future<void> updateBudgetSpent(String category, double amount) async {
    final db = await DatabaseHelper.instance.database;
    final budget = _budgets.firstWhere(
      (b) => b.category == category,
      orElse: () => BudgetModel(
        category: category,
        categoryIcon: '',
        monthlyLimit: 0,
      ),
    );

    if (budget.id != null) {
      await db.update(
        'budgets',
        {'currentSpent': budget.currentSpent + amount},
        where: 'id = ?',
        whereArgs: [budget.id],
      );
      await loadBudgets();
    }
  }

  // Sesuaikan budget saat edit transaksi (delta bisa negatif)
  Future<void> adjustBudgetSpent(String category, double delta) async {
    final db = await DatabaseHelper.instance.database;
    final budget = _budgets.firstWhere(
      (b) => b.category == category,
      orElse: () => BudgetModel(
        category: category,
        categoryIcon: '',
        monthlyLimit: 0,
      ),
    );

    if (budget.id != null) {
      final newSpent = (budget.currentSpent + delta).clamp(0, double.infinity);
      await db.update(
        'budgets',
        {'currentSpent': newSpent},
        where: 'id = ?',
        whereArgs: [budget.id],
      );
      await loadBudgets();
    }
  }

  // Hapus semua budget
  Future<void> deleteAllBudgets() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('budgets');
    await loadBudgets();
  }

  // Budget yang hampir habis (untuk warning banner di Dashboard)
  List<BudgetModel> get warningBudgets {
    return _budgets.where((b) => b.isWarning || b.isDanger).toList();
  }

  double get totalBudgetPercentage {
    if (_budgets.isEmpty) return 0;
    final totalLimit = _budgets.fold(0.0, (sum, b) => sum + b.monthlyLimit);
    final totalSpent = _budgets.fold(0.0, (sum, b) => sum + b.currentSpent);
    return totalLimit == 0 ? 0 : (totalSpent / totalLimit).clamp(0, 1);
  }
}