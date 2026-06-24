import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/savings_goal.dart';
import '../providers/savings_provider.dart';

class SavingsGoalScreen extends StatefulWidget {
  const SavingsGoalScreen({super.key});

  @override
  State<SavingsGoalScreen> createState() => _SavingsGoalScreenState();
}

class _SavingsGoalScreenState extends State<SavingsGoalScreen> {
  String _activeTab = 'Aktif';

  final List<Map<String, dynamic>> _iconOptions = [
    {'emoji': '💻', 'icon': Icons.laptop_mac_rounded},
    {'emoji': '✈️', 'icon': Icons.flight_rounded},
    {'emoji': '🏠', 'icon': Icons.home_rounded},
    {'emoji': '🚗', 'icon': Icons.directions_car_rounded},
    {'emoji': '📱', 'icon': Icons.smartphone_rounded},
    {'emoji': '👟', 'icon': Icons.directions_run_rounded},
    {'emoji': '🎓', 'icon': Icons.school_rounded},
    {'emoji': '🎮', 'icon': Icons.sports_esports_rounded},
  ];

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.decimalPattern('id');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<SavingsProvider>(
        builder: (context, provider, child) {
          final goals =
              _activeTab == 'Aktif' ? provider.activeGoals : provider.completedGoals;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 16),
                    _buildSummaryCard(provider),
                    const SizedBox(height: 16),
                    _buildTabToggle(),
                    const SizedBox(height: 16),
                    if (goals.isEmpty)
                      _buildEmptyState()
                    else
                      ...goals.map((goal) => _activeTab == 'Aktif'
                          ? _buildActiveGoalCard(goal)
                          : _buildCompletedGoalCard(goal)),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  backgroundColor: AppColors.primary,
                  onPressed: () => _openAddGoalSheet(context),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============ TOP BAR ============
  Widget _buildTopBar() {
    return const Center(
      child: Text(
        'Savings Goal',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============ SUMMARY CARD ============
  Widget _buildSummaryCard(SavingsProvider provider) {
    final activeCount = provider.activeGoals.length;
    final completedCount = provider.completedGoals.length;

    double dailyNeeded = 0;
    for (var g in provider.activeGoals) {
      dailyNeeded += g.dailySavingsNeeded;
    }

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
          Text(
            'Total Tabungan',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rp ${_formatCurrency(provider.totalSaved)}',
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
                child: _summaryCol('$activeCount', 'Target Aktif'),
              ),
              Container(
                width: 0.5,
                height: 30,
                color: Colors.white.withValues(alpha: 0.2),
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Expanded(
                child: _summaryCol('$completedCount', 'Tercapai'),
              ),
              Container(
                width: 0.5,
                height: 30,
                color: Colors.white.withValues(alpha: 0.2),
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Expanded(
                child: _summaryCol(
                    'Rp ${_formatCurrency(dailyNeeded)}', 'Perlu/Hari'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCol(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  // ============ TAB TOGGLE ============
  Widget _buildTabToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['Aktif', 'Selesai'].map((tab) {
          final isActive = _activeTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = tab),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    tab,
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

  // ============ EMPTY STATE ============
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.flag_outlined, size: 40, color: AppColors.textTertiary),
            const SizedBox(height: 8),
            Text(
              _activeTab == 'Aktif'
                  ? 'Belum ada target tabungan'
                  : 'Belum ada target yang tercapai',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
            ),
            if (_activeTab == 'Aktif') ...[
              const SizedBox(height: 4),
              Text(
                'Tap tombol + untuk buat target baru',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============ ACTIVE GOAL CARD ============
  Widget _buildActiveGoalCard(SavingsGoalModel goal) {
    final isOnTrack = _isOnTrack(goal);
    final statusColor = isOnTrack ? AppColors.primary : AppColors.warning;
    final statusText = isOnTrack ? 'On Track' : 'Behind Schedule';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(goal.icon, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      goal.deadline != null
                          ? 'Deadline: ${DateFormat('MMMM yyyy', 'id').format(goal.deadline!)}'
                          : 'Tanpa deadline',
                      style: TextStyle(
                          color: AppColors.textTertiary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: AppColors.textTertiary),
                color: AppColors.cardBackground,
                onSelected: (value) {
                  if (value == 'delete') {
                    _confirmDeleteGoal(goal);
                  } else if (value == 'add_funds') {
                    _openAddFundsSheet(context, goal);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'add_funds',
                    child: Text('💰 Tambah Dana',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('🗑️ Hapus Target',
                        style: TextStyle(color: AppColors.danger)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                  color: statusColor, fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rp ${_formatCurrency(goal.currentAmount)} / Rp ${_formatCurrency(goal.targetAmount)}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                '${(goal.percentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: goal.percentage,
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation(statusColor),
            ),
          ),
          if (goal.dailySavingsNeeded > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Sisihkan Rp ${_formatCurrency(goal.dailySavingsNeeded)}/hari',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onPressed: () => _openAddFundsSheet(context, goal),
              child: Text('+ Tambah Dana',
                  style: TextStyle(color: AppColors.primary, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  bool _isOnTrack(SavingsGoalModel goal) {
    if (goal.deadline == null) return true;
    final now = DateTime.now();
    final totalDays = goal.deadline!.difference(now).inDays;
    if (totalDays <= 0) return goal.percentage >= 1;
    // Sederhana: kalau progress saat ini >= progress ideal, dianggap on track
    final idealPercentage = 1 - (totalDays / 365).clamp(0, 1);
    return goal.percentage >= idealPercentage * 0.7;
  }

  // ============ COMPLETED GOAL CARD ============
  Widget _buildCompletedGoalCard(SavingsGoalModel goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(goal.icon, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.name,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Rp ${_formatCurrency(goal.targetAmount)}',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                ),
              ],
            ),
          ),
          const Text('🏆', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  // ============ DELETE CONFIRMATION ============
  Future<void> _confirmDeleteGoal(SavingsGoalModel goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Hapus Target?',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Text(
          'Target "${goal.name}" akan dihapus permanen.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: TextStyle(color: AppColors.textTertiary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<SavingsProvider>().deleteGoal(goal.id!);
    }
  }

  // ============ ADD GOAL BOTTOM SHEET ============
  void _openAddGoalSheet(BuildContext context) {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final initialController = TextEditingController();
    DateTime? selectedDeadline;
    String selectedIcon = _iconOptions[0]['emoji'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Target Tabungan Baru',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Text('Pilih Ikon',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _iconOptions.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final option = _iconOptions[index];
                          final isSelected = selectedIcon == option['emoji'];
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedIcon = option['emoji'];
                              });
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryLight.withValues(alpha: 0.2)
                                    : AppColors.background,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color: AppColors.primary, width: 2)
                                    : null,
                              ),
                              child: Center(
                                child: Text(option['emoji'],
                                    style: const TextStyle(fontSize: 20)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Nama Target',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'contoh: Beli Laptop',
                        hintStyle: TextStyle(color: AppColors.textTertiary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Nominal Target (Rp)',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: targetController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Rp 0',
                        hintStyle: TextStyle(color: AppColors.textTertiary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Sudah Punya Tabungan Awal? (Opsional)',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: initialController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Rp 0',
                        hintStyle: TextStyle(color: AppColors.textTertiary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Deadline (Opsional)',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 90)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedDeadline = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 16, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Text(
                              selectedDeadline != null
                                  ? DateFormat('d MMM yyyy', 'id')
                                      .format(selectedDeadline!)
                                  : 'Pilih tanggal target',
                              style: TextStyle(
                                  color: selectedDeadline != null
                                      ? Colors.white
                                      : AppColors.textTertiary,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final target =
                              double.tryParse(targetController.text) ?? 0;
                          final initial =
                              double.tryParse(initialController.text) ?? 0;

                          if (name.isEmpty || target <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Nama dan nominal target wajib diisi')),
                            );
                            return;
                          }

                          final goal = SavingsGoalModel(
                            name: name,
                            icon: selectedIcon,
                            targetAmount: target,
                            currentAmount: initial,
                            deadline: selectedDeadline,
                          );

                          await context.read<SavingsProvider>().addGoal(goal);

                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Buat Target'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============ ADD FUNDS BOTTOM SHEET ============
  void _openAddFundsSheet(BuildContext context, SavingsGoalModel goal) {
    final amountController = TextEditingController();

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
              Text(
                'Tambah Dana — ${goal.name}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                'Terkumpul saat ini: Rp ${_formatCurrency(goal.currentAmount)}',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Text('Nominal yang ditambahkan',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Rp 0',
                  hintStyle: TextStyle(color: AppColors.textTertiary),
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
                    final amount =
                        double.tryParse(amountController.text) ?? 0;
                    if (amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nominal tidak valid')),
                      );
                      return;
                    }

                    await context
                        .read<SavingsProvider>()
                        .addFundsToGoal(goal.id!, amount);

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}