import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? existingTransaction;

  const AddTransactionScreen({super.key, this.existingTransaction});

  bool get isEditMode => existingTransaction != null;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String _type = 'expense'; // 'expense' atau 'income'
  String _amount = '0';
  DateTime _selectedDate = DateTime.now();
  String _selectedMood = 'happy';
  final TextEditingController _noteController = TextEditingController();

  // Data kategori
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Makan & minum', 'icon': Icons.ramen_dining_rounded, 'color': AppColors.primary},
    {'name': 'Transportasi', 'icon': Icons.directions_bus_rounded, 'color': const Color(0xFF378ADD)},
    {'name': 'Belanja', 'icon': Icons.shopping_bag_rounded, 'color': const Color(0xFFFDCB6E)},
    {'name': 'Hiburan', 'icon': Icons.sports_esports_rounded, 'color': const Color(0xFF6C5CE7)},
    {'name': 'Kesehatan', 'icon': Icons.favorite_rounded, 'color': const Color(0xFFE17055)},
    {'name': 'Pendidikan', 'icon': Icons.menu_book_rounded, 'color': const Color(0xFFFFD93D)},
    {'name': 'Lainnya', 'icon': Icons.more_horiz_rounded, 'color': AppColors.textTertiary},
  ];
  Map<String, dynamic> _selectedCategory = {};

  final List<Map<String, String>> _moods = [
    {'key': 'happy', 'emoji': '😊'},
    {'key': 'neutral', 'emoji': '😐'},
    {'key': 'sad', 'emoji': '😟'},
    {'key': 'stress', 'emoji': '😤'},
    {'key': 'bored', 'emoji': '🥱'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories[0];

    // Prefill data jika edit mode
    final existing = widget.existingTransaction;
    if (existing != null) {
      _type = existing.type;
      _amount = existing.amount.toStringAsFixed(
        existing.amount == existing.amount.roundToDouble() ? 0 : 2,
      );
      _selectedDate = existing.date;
      _selectedMood = existing.mood;
      _noteController.text = existing.note ?? '';

      // Cari kategori yang sesuai
      final matchedCategory = _categories.firstWhere(
        (c) => c['name'] == existing.category,
        orElse: () => _categories.last, // fallback ke 'Lainnya'
      );
      _selectedCategory = matchedCategory;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // ============ NUMPAD LOGIC ============
  void _onNumpadTap(String value) {
    setState(() {
      if (value == 'backspace') {
        if (_amount.length > 1) {
          _amount = _amount.substring(0, _amount.length - 1);
        } else {
          _amount = '0';
        }
      } else if (value == '.') {
        if (!_amount.contains('.')) {
          _amount += '.';
        }
      } else {
        if (_amount == '0') {
          _amount = value;
        } else {
          _amount += value;
        }
      }
    });
  }

  String get _formattedAmount {
    final value = double.tryParse(_amount) ?? 0;
    final formatter = NumberFormat.decimalPattern('id');
    return formatter.format(value);
  }

  // ============ SAVE TRANSACTION ============
  Future<void> _saveTransaction() async {
    final amountValue = double.tryParse(_amount) ?? 0;

    if (amountValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal tidak boleh kosong')),
      );
      return;
    }

    final provider = context.read<TransactionProvider>();
    final budgetProvider = context.read<BudgetProvider>();
    final existing = widget.existingTransaction;

    if (existing != null) {
      // === EDIT MODE ===
      final updatedTransaction = TransactionModel(
        id: existing.id,
        amount: amountValue,
        type: _type,
        category: _selectedCategory['name'],
        categoryIcon: _selectedCategory['name'],
        date: _selectedDate,
        mood: _selectedMood,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      // Sesuaikan budget: kurangi spent lama, tambah spent baru
      if (existing.type == 'expense') {
        await budgetProvider.adjustBudgetSpent(
          existing.category,
          -existing.amount, // kurangi budget lama
        );
      }
      if (_type == 'expense') {
        await budgetProvider.updateBudgetSpent(
          _selectedCategory['name'],
          amountValue, // tambah budget baru
        );
      }

      await provider.updateTransaction(updatedTransaction);
    } else {
      // === ADD MODE ===
      final transaction = TransactionModel(
        amount: amountValue,
        type: _type,
        category: _selectedCategory['name'],
        categoryIcon: _selectedCategory['name'],
        date: _selectedDate,
        mood: _selectedMood,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      await provider.addTransaction(transaction);

      // Update budget kalau pengeluaran
      if (_type == 'expense' && mounted) {
        await budgetProvider.updateBudgetSpent(
          _selectedCategory['name'],
          amountValue,
        );
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _openCategoryPicker() {
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
              const Text(
                'Pilih Kategori',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat['name'] == _selectedCategory['name'];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      Navigator.pop(context);
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: (cat['color'] as Color).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: isSelected
                                ? Border.all(color: AppColors.primary, width: 2)
                                : null,
                          ),
                          child: Icon(
                            cat['icon'] as IconData,
                            color: cat['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat['name'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildTypeToggle(),
                    const SizedBox(height: 16),
                    _buildAmountAndNumpad(),
                    const SizedBox(height: 16),
                    _buildDetailSection(),
                    const SizedBox(height: 20),
                    _buildSaveButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ TOP BAR ============
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            widget.isEditMode ? 'Edit Transaksi' : 'Tambah Transaksi',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 48), // balance untuk center title
        ],
      ),
    );
  }

  // ============ TYPE TOGGLE ============
  Widget _buildTypeToggle() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _type = 'expense'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _type == 'expense'
                    ? AppColors.expense
                    : AppColors.cardBackground,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Text(
                  '↓ Pengeluaran',
                  style: TextStyle(
                    color: _type == 'expense'
                        ? Colors.white
                        : AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _type = 'income'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _type == 'income'
                    ? AppColors.income
                    : AppColors.cardBackground,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Text(
                  '↑ Pemasukan',
                  style: TextStyle(
                    color: _type == 'income'
                        ? Colors.white
                        : AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============ AMOUNT + NUMPAD ============
  Widget _buildAmountAndNumpad() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'NOMINAL',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rp $_formattedAmount',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildNumpadGrid(),
        ],
      ),
    );
  }

  Widget _buildNumpadGrid() {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', 'backspace'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 2.2,
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        return InkWell(
          onTap: () => _onNumpadTap(key),
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: key == 'backspace'
                ? const Icon(Icons.backspace_outlined,
                    color: Colors.white, size: 18)
                : Text(
                    key,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
          ),
        );
      },
    );
  }

  // ============ DETAIL SECTION ============
  Widget _buildDetailSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _detailRow(
            icon: Icons.grid_view_rounded,
            label: 'Kategori',
            trailing: Row(
              children: [
                Icon(_selectedCategory['icon'] as IconData,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  _selectedCategory['name'] as String,
                  style: TextStyle(color: AppColors.primary, fontSize: 12),
                ),
              ],
            ),
            onTap: _openCategoryPicker,
          ),
          _divider(),
          _detailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Tanggal',
            trailing: Text(
              DateFormat('d MMM yyyy', 'id').format(_selectedDate),
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            onTap: _pickDate,
          ),
          _divider(),
          _buildMoodRow(),
          _divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: TextField(
              controller: _noteController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                icon: const Icon(Icons.edit_outlined,
                    color: Colors.white, size: 18),
                hintText: 'Tambah catatan...',
                hintStyle: TextStyle(color: AppColors.textTertiary),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            trailing,
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_emotions_outlined,
                  color: Colors.white, size: 18),
              const SizedBox(width: 10),
              const Text(
                'Mood saat belanja',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _moods.map((mood) {
              final isSelected = _selectedMood == mood['key'];
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = mood['key']!),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: Text(
                    mood['emoji']!,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 0.5,
      color: AppColors.background,
      indent: 14,
      endIndent: 14,
    );
  }

  // ============ SAVE BUTTON ============
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTransaction,
        child: Text(widget.isEditMode ? 'Simpan Perubahan' : 'Simpan Transaksi'),
      ),
    );
  }
}