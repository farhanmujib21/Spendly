import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/budget.dart';
import '../providers/budget_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/savings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = 'Pengguna';
  String _currency = 'Rupiah (Rp)';
  String _resetDate = 'Tanggal 1';

  bool _reminderEnabled = true;
  bool _budgetWarningEnabled = true;
  bool _weeklyRecapEnabled = false;

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
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Pengguna';
      _currency = prefs.getString('currency') ?? 'Rupiah (Rp)';
      _resetDate = prefs.getString('reset_date') ?? 'Tanggal 1';
      _reminderEnabled = prefs.getBool('reminder_enabled') ?? true;
      _budgetWarningEnabled = prefs.getBool('budget_warning_enabled') ?? true;
      _weeklyRecapEnabled = prefs.getBool('weekly_recap_enabled') ?? false;
    });
  }

  Future<void> _saveToggle(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.decimalPattern('id');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<TransactionProvider>(
        builder: (context, txProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 16),
                _buildProfileCard(txProvider),
                const SizedBox(height: 20),
                _buildSectionLabel('KEUANGAN'),
                const SizedBox(height: 8),
                _buildKeuanganSection(),
                const SizedBox(height: 20),
                _buildSectionLabel('NOTIFIKASI'),
                const SizedBox(height: 8),
                _buildNotifikasiSection(),
                const SizedBox(height: 20),
                _buildSectionLabel('DATA & PRIVASI'),
                const SizedBox(height: 8),
                _buildDataSection(),
                const SizedBox(height: 20),
                _buildSectionLabel('TENTANG APLIKASI'),
                const SizedBox(height: 8),
                _buildAboutSection(),
                const SizedBox(height: 24),
                _buildLogoutButton(),
                const SizedBox(height: 20),
                _buildBranding(),
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
        'Profil & Pengaturan',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============ PROFILE CARD ============
  Widget _buildProfileCard(TransactionProvider txProvider) {
    final initial = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'P';
    final totalTransactions = txProvider.transactions.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _openEditProfileSheet,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.cardBackground, width: 2),
                    ),
                    child: const Icon(Icons.edit, size: 11, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Member sejak Mei 2026',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _statCol('$totalTransactions', 'Transaksi'),
              _statDivider(),
              _statCol('1', 'Bulan Aktif'),
              _statDivider(),
              Consumer<SavingsProvider>(
                builder: (context, savingsProvider, child) {
                  return _statCol(
                      '${savingsProvider.completedGoals.length}', 'Target Selesai');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCol(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: AppColors.textTertiary, fontSize: 10),
        ),
      ],
    );
  }

  Widget _statDivider() {
    return Container(
      width: 0.5,
      height: 28,
      color: AppColors.background,
      margin: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  // ============ SECTION LABEL ============
  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textTertiary,
        letterSpacing: 0.8,
      ),
    );
  }

  // ============ KEUANGAN SECTION ============
  Widget _buildKeuanganSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _menuRow(
            icon: Icons.attach_money_rounded,
            label: 'Mata Uang',
            trailingText: _currency.split(' ')[0],
            onTap: _openCurrencyPicker,
          ),
          _divider(),
          _menuRow(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Atur Budget Bulanan',
            onTap: _openBudgetManager,
          ),
          _divider(),
          _menuRow(
            icon: Icons.calendar_month_rounded,
            label: 'Tanggal Reset Budget',
            trailingText: _resetDate,
            onTap: _openResetDatePicker,
          ),
          _divider(),
          _menuRow(
            icon: Icons.description_outlined,
            label: 'Ekspor Laporan',
            subtitle: 'Excel/PDF',
            onTap: () => _showComingSoon('Ekspor Laporan'),
          ),
        ],
      ),
    );
  }

  // ============ NOTIFIKASI SECTION ============
  Widget _buildNotifikasiSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _toggleRow(
            icon: Icons.notifications_active_outlined,
            label: 'Pengingat Catat Transaksi',
            subtitle: 'Setiap hari 20:00',
            value: _reminderEnabled,
            onChanged: (value) {
              setState(() => _reminderEnabled = value);
              _saveToggle('reminder_enabled', value);
            },
          ),
          _divider(),
          _toggleRow(
            icon: Icons.warning_amber_rounded,
            label: 'Peringatan Budget',
            subtitle: 'Notifikasi saat budget hampir habis',
            value: _budgetWarningEnabled,
            onChanged: (value) {
              setState(() => _budgetWarningEnabled = value);
              _saveToggle('budget_warning_enabled', value);
            },
          ),
          _divider(),
          _toggleRow(
            icon: Icons.summarize_outlined,
            label: 'Ringkasan Mingguan',
            subtitle: 'Laporan otomatis tiap Senin pagi',
            value: _weeklyRecapEnabled,
            onChanged: (value) {
              setState(() => _weeklyRecapEnabled = value);
              _saveToggle('weekly_recap_enabled', value);
            },
          ),
        ],
      ),
    );
  }

  // ============ DATA SECTION ============
  Widget _buildDataSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _menuRow(
            icon: Icons.cloud_upload_outlined,
            label: 'Backup Data',
            onTap: () => _showComingSoon('Backup Data'),
          ),
          _divider(),
          _menuRow(
            icon: Icons.restore_rounded,
            label: 'Pulihkan Data',
            onTap: () => _showComingSoon('Pulihkan Data'),
          ),
          _divider(),
          _menuRow(
            icon: Icons.delete_outline_rounded,
            label: 'Hapus Semua Data',
            labelColor: AppColors.danger,
            onTap: _confirmDeleteAllData,
          ),
        ],
      ),
    );
  }

  // ============ ABOUT SECTION ============
  Widget _buildAboutSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _menuRow(
            icon: Icons.info_outline_rounded,
            label: 'Versi Aplikasi',
            trailingText: 'v1.0.0',
            onTap: null,
          ),
          _divider(),
          _menuRow(
            icon: Icons.privacy_tip_outlined,
            label: 'Kebijakan Privasi',
            onTap: () => _showComingSoon('Kebijakan Privasi'),
          ),
          _divider(),
          _menuRow(
            icon: Icons.support_agent_rounded,
            label: 'Hubungi Kami',
            onTap: () => _showComingSoon('Hubungi Kami'),
          ),
        ],
      ),
    );
  }

  // ============ REUSABLE ROW WIDGETS ============
  Widget _menuRow({
    required IconData icon,
    required String label,
    String? subtitle,
    String? trailingText,
    Color? labelColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Icon(icon, size: 18, color: labelColor ?? AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: labelColor ?? Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                            color: AppColors.textTertiary, fontSize: 10),
                      ),
                  ],
                ),
              ),
              if (trailingText != null)
                Text(
                  trailingText,
                  style:
                      TextStyle(color: AppColors.textTertiary, fontSize: 12),
                ),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                Icon(Icons.chevron_right,
                    size: 18, color: labelColor ?? AppColors.textTertiary),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 13)),
                  Text(
                    subtitle,
                    style:
                        TextStyle(color: AppColors.textTertiary, fontSize: 10),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
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

  // ============ LOGOUT BUTTON ============
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.danger),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () => _showComingSoon('Logout'),
        icon: Icon(Icons.logout_rounded, color: AppColors.danger, size: 18),
        label: Text('Keluar dari Akun',
            style: TextStyle(color: AppColors.danger)),
      ),
    );
  }

  // ============ BRANDING ============
  Widget _buildBranding() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('S',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ),
          const SizedBox(height: 6),
          const Text('Spendly',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
          const SizedBox(height: 2),
          Text('© 2026 Spendly',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
        ],
      ),
    );
  }

  // ============ COMING SOON SNACKBAR ============
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature akan segera hadir 🚀'),
        backgroundColor: AppColors.cardBackground,
      ),
    );
  }

  // ============ CURRENCY PICKER ============
  void _openCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final options = ['Rupiah (Rp)', 'US Dollar (\$)', 'Euro (€)'];
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pilih Mata Uang',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ...options.map((opt) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(opt,
                        style: const TextStyle(color: Colors.white)),
                    trailing: _currency == opt
                        ? Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () async {
                      setState(() => _currency = opt);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('currency', opt);
                      if (context.mounted) Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  // ============ RESET DATE PICKER ============
  void _openResetDatePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final options = ['Tanggal 1', 'Tanggal 15', 'Tanggal 25'];
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tanggal Reset Budget',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ...options.map((opt) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(opt,
                        style: const TextStyle(color: Colors.white)),
                    trailing: _resetDate == opt
                        ? Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () async {
                      setState(() => _resetDate = opt);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('reset_date', opt);
                      if (context.mounted) Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  // ============ EDIT PROFILE SHEET ============
  void _openEditProfileSheet() {
    final nameController = TextEditingController(text: _userName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Profil',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Text('Nama Panggilan',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      setState(() => _userName = name);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('user_name', name);
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Simpan Perubahan'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============ BUDGET MANAGER (FUNGSIONAL PENUH) ============
  void _openBudgetManager() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Consumer<BudgetProvider>(
              builder: (context, budgetProvider, child) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Atur Budget Bulanan',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            ..._categoryIcons.keys.map((category) {
                              final existing = budgetProvider.budgets
                                  .where((b) => b.category == category)
                                  .toList();
                              final budget = existing.isNotEmpty
                                  ? existing.first
                                  : null;
                              return _budgetEditRow(
                                  context, category, budget, budgetProvider);
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _budgetEditRow(
    BuildContext context,
    String category,
    BudgetModel? existing,
    BudgetProvider budgetProvider,
  ) {
    final controller = TextEditingController(
      text: existing != null && existing.monthlyLimit > 0
          ? existing.monthlyLimit.toStringAsFixed(0)
          : '',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_categoryIcons[category],
                size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(category,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
          SizedBox(
            width: 110,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Rp 0',
                hintStyle: TextStyle(color: AppColors.textTertiary),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (value) =>
                  _saveBudgetValue(category, existing, value, budgetProvider),
            ),
          ),
          IconButton(
            icon: Icon(Icons.check_circle_outline,
                size: 18, color: AppColors.primary),
            onPressed: () => _saveBudgetValue(
                category, existing, controller.text, budgetProvider),
          ),
        ],
      ),
    );
  }

  Future<void> _saveBudgetValue(
    String category,
    BudgetModel? existing,
    String value,
    BudgetProvider budgetProvider,
  ) async {
    final limit = double.tryParse(value) ?? 0;
    if (limit <= 0) return;

    if (existing != null && existing.id != null) {
      await budgetProvider.editBudgetLimit(existing.id!, limit);
    } else {
      final newBudget = BudgetModel(
        category: category,
        categoryIcon: category,
        monthlyLimit: limit,
      );
      await budgetProvider.addBudget(newBudget);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Budget $category disimpan')),
      );
    }
  }

  // ============ DELETE ALL DATA ============
  Future<void> _confirmDeleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Hapus Semua Data?',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Text(
          'Semua transaksi, budget, dan target tabungan akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                Text('Batal', style: TextStyle(color: AppColors.textTertiary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus Semua', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<TransactionProvider>().deleteAllTransactions();
      await context.read<BudgetProvider>().deleteAllBudgets();
      await context.read<SavingsProvider>().deleteAllGoals();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua data berhasil dihapus')),
        );
      }
    }
  }
}