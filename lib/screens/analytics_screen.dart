import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _activePeriod = 'Bulan ini';
  final List<String> _periods = ['Minggu ini', 'Bulan ini', 'Tahun ini'];

  final Map<String, IconData> _categoryIcons = {
    'Makan & minum': Icons.ramen_dining_rounded,
    'Transportasi': Icons.directions_bus_rounded,
    'Belanja': Icons.shopping_bag_rounded,
    'Hiburan': Icons.sports_esports_rounded,
    'Kesehatan': Icons.favorite_rounded,
    'Pendidikan': Icons.menu_book_rounded,
    'Lainnya': Icons.more_horiz_rounded,
  };

  final Map<String, Color> _categoryColors = {
    'Makan & minum': AppColors.primary,
    'Transportasi': const Color(0xFF378ADD),
    'Belanja': const Color(0xFFFDCB6E),
    'Hiburan': const Color(0xFF6C5CE7),
    'Kesehatan': const Color(0xFFE17055),
    'Pendidikan': const Color(0xFFFFD93D),
    'Lainnya': AppColors.textTertiary,
  };

  final Map<String, String> _moodEmoji = {
    'happy': '😊',
    'neutral': '😐',
    'sad': '😟',
    'stress': '😤',
    'bored': '🥱',
  };

  final Map<String, String> _moodLabel = {
    'happy': 'Happy',
    'neutral': 'Neutral',
    'sad': 'Sedih',
    'stress': 'Stress',
    'bored': 'Bosan',
  };

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.decimalPattern('id');
    return formatter.format(amount);
  }

  // Filter transaksi sesuai periode aktif
  List<TransactionModel> _getFilteredTransactions(
      List<TransactionModel> all) {
    final now = DateTime.now();

    if (_activePeriod == 'Minggu ini') {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      return all.where((t) => t.date.isAfter(startDate)).toList();
    } else if (_activePeriod == 'Bulan ini') {
      return all
          .where((t) => t.date.year == now.year && t.date.month == now.month)
          .toList();
    } else {
      return all.where((t) => t.date.year == now.year).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer2<TransactionProvider, BudgetProvider>(
        builder: (context, txProvider, budgetProvider, child) {
          final filtered = _getFilteredTransactions(txProvider.transactions);
          final expenseFiltered =
              filtered.where((t) => t.type == 'expense').toList();
          final incomeTotal = filtered
              .where((t) => t.type == 'income')
              .fold(0.0, (s, t) => s + t.amount);
          final expenseTotal =
              expenseFiltered.fold(0.0, (s, t) => s + t.amount);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 16),
                _buildPeriodSelector(),
                const SizedBox(height: 16),
                _buildOverviewCard(incomeTotal, expenseTotal),
                const SizedBox(height: 16),
                _buildWeeklyComparisonCard(txProvider),
                const SizedBox(height: 16),
                _buildCategoryCard(expenseFiltered, expenseTotal),
                const SizedBox(height: 16),
                _buildMoodInsightCard(expenseFiltered),
                const SizedBox(height: 16),
                _buildBudgetProgressCard(budgetProvider),
                const SizedBox(height: 16),
                _buildTopSpendingCard(expenseFiltered),
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
    return const Center(
      child: Text(
        'Analisis',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============ PERIOD SELECTOR ============
  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _periods.map((period) {
          final isActive = _activePeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activePeriod = period),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    period,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.white : AppColors.textTertiary,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============ OVERVIEW CARD ============
  Widget _buildOverviewCard(double income, double expense) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pengeluaran',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              Text(
                _activePeriod,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Rp ${_formatCurrency(expense)}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _overviewCol('↑ Pemasukan', income),
              ),
              Expanded(
                child: _overviewCol('↓ Pengeluaran', expense),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overviewCol(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        Text(
          'Rp ${_formatCurrency(value)}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ============ WEEKLY COMPARISON CARD ============
  Widget _buildWeeklyComparisonCard(TransactionProvider txProvider) {
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return DateTime(date.year, date.month, date.day);
    });

    const dayLabels = ['Sn', 'Sl', 'Rb', 'Km', 'Jm', 'Sb', 'Mg'];

    final values = last7Days.map((date) {
      return txProvider.transactions
          .where((t) =>
              t.type == 'expense' &&
              t.date.year == date.year &&
              t.date.month == date.month &&
              t.date.day == date.day)
          .fold(0.0, (sum, t) => sum + t.amount);
    }).toList();

    final maxValue = values.isEmpty || values.every((v) => v == 0)
        ? 100.0
        : (values.reduce((a, b) => a > b ? a : b) * 1.3);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengeluaran Mingguan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= dayLabels.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            dayLabels[index],
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(values.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i] == 0 ? maxValue * 0.02 : values[i],
                        color: AppColors.primary,
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ CATEGORY DONUT CHART ============
  Widget _buildCategoryCard(
      List<TransactionModel> expenses, double total) {
    final Map<String, double> categoryTotals = {};
    for (var t in expenses) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Per Kategori',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (sortedEntries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Belum ada data pengeluaran',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 42,
                      sections: sortedEntries.map((entry) {
                        final color =
                            _categoryColors[entry.key] ?? AppColors.textTertiary;
                        final percentage = (entry.value / total * 100);
                        return PieChartSectionData(
                          value: entry.value,
                          color: color,
                          radius: 26,
                          showTitle: false,
                        );
                      }).toList(),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Rp ${_formatCurrency(total)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'pengeluaran',
                        style: TextStyle(
                            color: AppColors.textTertiary, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: sortedEntries.map((entry) {
                final color =
                    _categoryColors[entry.key] ?? AppColors.textTertiary;
                final percentage = (entry.value / total * 100);
                return SizedBox(
                  width: 130,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(top: 3),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${percentage.toStringAsFixed(0)}% · Rp ${_formatCurrency(entry.value)}',
                              style: TextStyle(
                                  color: AppColors.textTertiary, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ============ MOOD INSIGHT CARD ============
  Widget _buildMoodInsightCard(List<TransactionModel> expenses) {
    final Map<String, double> moodTotals = {};
    for (var t in expenses) {
      moodTotals[t.mood] = (moodTotals[t.mood] ?? 0) + t.amount;
    }

    final sortedMoods = moodTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxMoodValue =
        sortedMoods.isEmpty ? 1.0 : sortedMoods.first.value;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood & Pengeluaran',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kamu paling boros saat...',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
          ),
          const SizedBox(height: 12),
          if (sortedMoods.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Belum cukup data untuk insight mood',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.expense.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(_moodEmoji[sortedMoods.first.key] ?? '',
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_moodLabel[sortedMoods.first.key] ?? sortedMoods.first.key} paling mahal',
                        style: const TextStyle(
                          color: AppColors.expense,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Rp ${_formatCurrency(sortedMoods.first.value)}',
                        style: const TextStyle(
                          color: AppColors.expense,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ...sortedMoods.map((entry) {
              final barWidth = entry.value / maxMoodValue;
              final isTop = entry.key == sortedMoods.first.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_moodEmoji[entry.key] ?? ''} ${_moodLabel[entry.key] ?? entry.key}',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 11),
                        ),
                        Text(
                          'Rp ${_formatCurrency(entry.value)}',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: barWidth,
                        minHeight: 6,
                        backgroundColor: AppColors.background,
                        valueColor: AlwaysStoppedAnimation(
                          isTop ? AppColors.expense : AppColors.primaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Coba tarik napas sebelum belanja saat kamu merasa ${_moodLabel[sortedMoods.first.key]?.toLowerCase() ?? sortedMoods.first.key} ya!',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============ BUDGET PROGRESS CARD ============
  Widget _buildBudgetProgressCard(BudgetProvider budgetProvider) {
    if (budgetProvider.budgets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress Budget',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Atur budget bulanan di halaman Settings',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Budget',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...budgetProvider.budgets.map((budget) {
            final color = budget.isDanger
                ? AppColors.danger
                : budget.isWarning
                    ? AppColors.warning
                    : AppColors.primary;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _categoryIcons[budget.category] ??
                                Icons.category_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            budget.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (budget.isDanger) ...[
                            const SizedBox(width: 6),
                            Text(
                              '⚠️ Hampir habis!',
                              style: TextStyle(
                                  color: AppColors.danger, fontSize: 10),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '${(budget.percentage * 100).toStringAsFixed(0)}%',
                        style: TextStyle(color: color, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: budget.percentage,
                      minHeight: 6,
                      backgroundColor: AppColors.background,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rp ${_formatCurrency(budget.currentSpent)} / Rp ${_formatCurrency(budget.monthlyLimit)}',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 10),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============ TOP SPENDING CARD ============
  Widget _buildTopSpendingCard(List<TransactionModel> expenses) {
    final sorted = [...expenses]
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final top3 = sorted.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengeluaran Terbesar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (top3.isEmpty)
            Text(
              'Belum ada transaksi pengeluaran',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
            )
          else
            ...top3.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final t = entry.value;
              final rankColors = [
                const Color(0xFFFDCB6E),
                AppColors.textTertiary,
                const Color(0xFFCD7F32),
              ];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: rankColors[rank - 1].withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: TextStyle(
                            color: rankColors[rank - 1],
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      _categoryIcons[t.category] ?? Icons.category_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.note?.isNotEmpty == true ? t.note! : t.category,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                          Text(
                            '${t.category} · ${DateFormat('d MMM', 'id').format(t.date)}',
                            style: TextStyle(
                                color: AppColors.textTertiary, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rp ${_formatCurrency(t.amount)}',
                      style: const TextStyle(
                        color: AppColors.expense,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}