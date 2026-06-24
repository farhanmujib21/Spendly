import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _activeFilter = 'Semua';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = ['Semua', 'Pengeluaran', 'Pemasukan'];

  final Map<String, String> _moodEmoji = {
    'happy': '😊',
    'neutral': '😐',
    'sad': '😟',
    'stress': '😤',
    'bored': '🥱',
  };

  final Map<String, IconData> _categoryIcons = {
    'Makan & minum': Icons.ramen_dining_rounded,
    'Transportasi': Icons.directions_bus_rounded,
    'Belanja': Icons.shopping_bag_rounded,
    'Hiburan': Icons.sports_esports_rounded,
    'Kesehatan': Icons.favorite_rounded,
    'Pendidikan': Icons.menu_book_rounded,
    'Lainnya': Icons.more_horiz_rounded,
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionModel> _filterTransactions(List<TransactionModel> all) {
    var result = all;

    // Filter by type
    if (_activeFilter == 'Pengeluaran') {
      result = result.where((t) => t.type == 'expense').toList();
    } else if (_activeFilter == 'Pemasukan') {
      result = result.where((t) => t.type == 'income').toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((t) =>
              t.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (t.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                  false))
          .toList();
    }

    return result;
  }

  Map<String, List<TransactionModel>> _groupByDate(
      List<TransactionModel> transactions) {
    final Map<String, List<TransactionModel>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var t in transactions) {
      final tDate = DateTime(t.date.year, t.date.month, t.date.day);
      String label;

      if (tDate == today) {
        label = 'Hari ini · ${DateFormat('EEEE, d MMM yyyy', 'id').format(t.date)}';
      } else if (tDate == yesterday) {
        label = 'Kemarin · ${DateFormat('EEEE, d MMM yyyy', 'id').format(t.date)}';
      } else {
        label = DateFormat('EEEE, d MMM yyyy', 'id').format(t.date);
      }

      grouped.putIfAbsent(label, () => []).add(t);
    }

    return grouped;
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.decimalPattern('id');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            final filtered = _filterTransactions(provider.transactions);
            final grouped = _groupByDate(filtered);

            return Column(
              children: [
                _buildTopBar(),
                _buildSummaryCard(provider),
                const SizedBox(height: 12),
                _buildFilterRow(),
                const SizedBox(height: 12),
                _buildSearchBar(),
                const SizedBox(height: 12),
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState()
                      : _buildGroupedList(grouped),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============ TOP BAR ============
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Riwayat Transaksi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============ SUMMARY CARD ============
  Widget _buildSummaryCard(TransactionProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: _summaryCol(
                'Pemasukan',
                'Rp ${_formatCurrency(provider.totalIncome)}',
                AppColors.income,
              ),
            ),
            Container(
              width: 0.5,
              height: 32,
              color: AppColors.background,
            ),
            Expanded(
              child: _summaryCol(
                'Pengeluaran',
                'Rp ${_formatCurrency(provider.totalExpense)}',
                AppColors.expense,
              ),
            ),
            Container(
              width: 0.5,
              height: 32,
              color: AppColors.background,
            ),
            Expanded(
              child: _summaryCol(
                'Selisih',
                'Rp ${_formatCurrency(provider.balance)}',
                AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // ============ FILTER ROW ============
  Widget _buildFilterRow() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isActive = _activeFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============ SEARCH BAR ============
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Cari transaksi...',
          hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13),
          prefixIcon: Icon(Icons.search, color: AppColors.textTertiary, size: 20),
          filled: true,
          fillColor: AppColors.cardBackground,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ============ EMPTY STATE ============
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(
            'Belum ada transaksi',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ============ GROUPED LIST ============
  Widget _buildGroupedList(Map<String, List<TransactionModel>> grouped) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                entry.key.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...entry.value.map((t) => _buildTransactionTile(t)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTransactionTile(TransactionModel t) {
    final isExpense = t.type == 'expense';
    return Dismissible(
      key: Key('tx_${t.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) => _confirmDelete(t),
      onDismissed: (direction) {
        context.read<TransactionProvider>().deleteTransaction(t.id!);
      },
      child: GestureDetector(
        onTap: () => _openDetailSheet(t),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
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
                      color: isExpense ? AppColors.expense : AppColors.income,
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
        ),
      ),
    );
  }

  // ============ DELETE CONFIRMATION ============
  Future<bool> _confirmDelete(TransactionModel t) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Hapus Transaksi?',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Text(
          'Transaksi "${t.note?.isNotEmpty == true ? t.note! : t.category}" akan dihapus permanen.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal',
                style: TextStyle(color: AppColors.textTertiary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ============ DETAIL BOTTOM SHEET ============
  void _openDetailSheet(TransactionModel t) {
    final isExpense = t.type == 'expense';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _categoryIcons[t.category] ?? Icons.category_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.note?.isNotEmpty == true ? t.note! : t.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          DateFormat('EEEE, d MMM yyyy', 'id').format(t.date),
                          style: TextStyle(
                              color: AppColors.textTertiary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '${isExpense ? '-' : '+'} Rp ${_formatCurrency(t.amount)}',
                  style: TextStyle(
                    color: isExpense ? AppColors.expense : AppColors.income,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _detailLine(Icons.calendar_today_rounded, 'Tanggal',
                  '${DateFormat('d MMM yyyy', 'id').format(t.date)} · ${DateFormat('HH:mm').format(t.date)}'),
              _detailLine(Icons.grid_view_rounded, 'Kategori', t.category),
              _detailLine(Icons.emoji_emotions_outlined, 'Mood',
                  '${_moodEmoji[t.mood] ?? ''} ${t.mood}'),
              if (t.note?.isNotEmpty == true)
                _detailLine(Icons.edit_outlined, 'Catatan', t.note!),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.danger),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        final confirmed = await _confirmDelete(t);
                        if (confirmed && mounted) {
                          Navigator.pop(context);
                          context
                              .read<TransactionProvider>()
                              .deleteTransaction(t.id!);
                        }
                      },
                      child: Text('Hapus',
                          style: TextStyle(color: AppColors.danger)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                      onPressed: () {
                        Navigator.pop(context); // tutup bottom sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddTransactionScreen(
                              existingTransaction: t,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailLine(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}