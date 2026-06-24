import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = 'Pengguna';

  final Map<String, IconData> _categoryIcons = {
    'Makan & minum': Icons.ramen_dining_rounded,
    'Transportasi': Icons.directions_bus_rounded,
    'Belanja': Icons.shopping_bag_rounded,
    'Hiburan': Icons.sports_esports_rounded,
    'Kesehatan': Icons.favorite_rounded,
    'Pendidikan': Icons.menu_book_rounded,
    'Lainnya': Icons.more_horiz_rounded,
  };

  final Map<String, String> _moodEmoji = {
    'happy': '😊',
    'neutral': '😐',
    'sad': '😟',
    'stress': '😤',
    'bored': '🥱',
  };

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('user_name') ?? 'Pengguna';
      });
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.decimalPattern('id');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer2<TransactionProvider, BudgetProvider>(
        builder: (context, txProvider, budgetProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 16),
                _buildBalanceCard(txProvider, budgetProvider),
                const SizedBox(height: 16),
                if (budgetProvider.warningBudgets.isNotEmpty) ...[
                  _buildWarningBanner(budgetProvider),
                  const SizedBox(height: 20),
                ],
                _buildSectionHeader('Pengeluaran Minggu Ini'),
                const SizedBox(height: 12),
                _buildWeeklyChart(txProvider),
                const SizedBox(height: 20),
                _buildSectionHeader('Transaksi Terbaru'),
                const SizedBox(height: 12),
                txProvider.recentTransactions.isEmpty
                    ? _buildEmptyTransactions()
                    : _buildTransactionList(txProvider.recentTransactions),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============ TOP BAR ============
  Widget _buildTopBar() {
    final now = DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hei, $_userName 👋',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('EEEE, d MMM yyyy', 'id').format(now),
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
          ],
        ),
        GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
            // Reload nama setelah balik dari Settings (kalau diedit)
            _loadUserName();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // ============ BALANCE CARD ============
  Widget _buildBalanceCard(
      TransactionProvider txProvider, BudgetProvider budgetProvider) {
    final budgetPercentage = budgetProvider.totalBudgetPercentage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Saldo',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rp ${_formatCurrency(txProvider.balance)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _balanceCol(
                  '↑ Pemasukan',
                  'Rp ${_formatCurrency(txProvider.totalIncome)}',
                ),
              ),
              Container(
                width: 0.5,
                height: 30,
                color: Colors.white.withValues(alpha: 0.2),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: _balanceCol(
                  '↓ Pengeluaran',
                  'Rp ${_formatCurrency(txProvider.totalExpense)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget terpakai',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
              Text(
                '${(budgetPercentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: budgetPercentage,
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ============ WARNING BANNER ============
  Widget _buildWarningBanner(BudgetProvider budgetProvider) {
    final budget = budgetProvider.warningBudgets.first;
    final remaining = budget.monthlyLimit - budget.currentSpent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3D2E0A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded, color: AppColors.warning, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Budget ${budget.category} hampir habis!',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Tersisa Rp ${_formatCurrency(remaining < 0 ? 0 : remaining)} dari Rp ${_formatCurrency(budget.monthlyLimit)}',
                  style: TextStyle(
                    color: AppColors.warning.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ SECTION HEADER ============
  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ============ WEEKLY CHART (data asli 7 hari terakhir) ============
  Widget _buildWeeklyChart(TransactionProvider txProvider) {
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return DateTime(date.year, date.month, date.day);
    });

    final dayLabels = last7Days.map((d) {
      const days = ['Sn', 'Sl', 'Rb', 'Km', 'Jm', 'Sb', 'Mg'];
      return days[d.weekday - 1];
    }).toList();

    final values = last7Days.map((date) {
      final total = txProvider.transactions
          .where((t) =>
              t.type == 'expense' &&
              t.date.year == date.year &&
              t.date.month == date.month &&
              t.date.day == date.day)
          .fold(0.0, (sum, t) => sum + t.amount);
      return total;
    }).toList();

    final maxValue = values.isEmpty
        ? 100.0
        : (values.reduce((a, b) => a > b ? a : b) * 1.3).clamp(100.0, double.infinity);

    final todayIndex = 6; // index terakhir selalu hari ini

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SizedBox(
        height: 120,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxValue,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= dayLabels.length) {
                      return const SizedBox();
                    }
                    final isToday = index == todayIndex;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        dayLabels[index],
                        style: TextStyle(
                          fontSize: 10,
                          color: isToday
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          fontWeight:
                              isToday ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(values.length, (i) {
              final isToday = i == todayIndex;
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: values[i] == 0 ? maxValue * 0.02 : values[i],
                    color: isToday
                        ? AppColors.primary
                        : AppColors.primaryLight.withValues(alpha: 0.15),
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // ============ EMPTY TRANSACTIONS ============
  Widget _buildEmptyTransactions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 40, color: AppColors.textTertiary),
            const SizedBox(height: 8),
            Text(
              'Belum ada transaksi',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap tombol + untuk mulai mencatat',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // ============ TRANSACTION LIST (data asli) ============
  Widget _buildTransactionList(List<TransactionModel> transactions) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: transactions.asMap().entries.map((entry) {
          final i = entry.key;
          final t = entry.value;
          final isLast = i == transactions.length - 1;
          final isExpense = t.type == 'expense';

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: AppColors.background,
                        width: 0.5,
                      ),
                    ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _categoryIcons[t.category] ?? Icons.category_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.note?.isNotEmpty == true ? t.note! : t.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${t.category} · ${_moodEmoji[t.mood] ?? ''}',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isExpense ? '-' : '+'} Rp ${_formatCurrency(t.amount)}',
                      style: TextStyle(
                        color: isExpense
                            ? AppColors.expense
                            : AppColors.income,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(t.date),
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}