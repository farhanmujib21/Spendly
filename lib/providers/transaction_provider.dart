import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../database/database_helper.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => _transactions;

  // Ambil semua transaksi dari database
  Future<void> loadTransactions() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    _transactions = result.map((e) => TransactionModel.fromMap(e)).toList();
    notifyListeners();
  }

  // Tambah transaksi baru
  Future<void> addTransaction(TransactionModel transaction) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('transactions', transaction.toMap());
    await loadTransactions(); // refresh data
  }

  // Hapus transaksi
  Future<void> deleteTransaction(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    await loadTransactions();
  }

  // Update transaksi (untuk fitur edit)
  Future<void> updateTransaction(TransactionModel transaction) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
    await loadTransactions();
  }

  // Ambil transaksi berdasarkan ID
  TransactionModel? getTransactionById(int id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  // Hapus semua transaksi
  Future<void> deleteAllTransactions() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('transactions');
    await loadTransactions();
  }

  // Total pemasukan bulan ini
  double get totalIncome {
    return _transactions
        .where((t) => t.type == 'income')
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Total pengeluaran bulan ini
  double get totalExpense {
    return _transactions
        .where((t) => t.type == 'expense')
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Saldo (pemasukan - pengeluaran)
  double get balance => totalIncome - totalExpense;

  // Transaksi terbaru (untuk Dashboard, ambil 3 teratas)
  List<TransactionModel> get recentTransactions {
    return _transactions.take(3).toList();
  }

  // Pengeluaran berdasarkan mood (untuk Analytics)
  Map<String, double> get expenseByMood {
    final Map<String, double> result = {};
    for (var t in _transactions.where((t) => t.type == 'expense')) {
      result[t.mood] = (result[t.mood] ?? 0) + t.amount;
    }
    return result;
  }

  // Pengeluaran berdasarkan kategori (untuk Analytics)
  Map<String, double> get expenseByCategory {
    final Map<String, double> result = {};
    for (var t in _transactions.where((t) => t.type == 'expense')) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }
}