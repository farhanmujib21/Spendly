import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../models/budget.dart';
import '../providers/budget_provider.dart';
import 'main_navigation.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedCurrency = 'Rupiah (Rp)';
  String _selectedResetDate = 'Tanggal 1';
  bool _isSaving = false;

  final Map<String, TextEditingController> _budgetControllers = {
    'Makan & minum': TextEditingController(),
    'Transportasi': TextEditingController(),
    'Belanja': TextEditingController(),
    'Hiburan': TextEditingController(),
    'Kesehatan': TextEditingController(),
  };

  final Map<String, IconData> _categoryIcons = {
    'Makan & minum': Icons.restaurant_rounded,
    'Transportasi': Icons.directions_bus_rounded,
    'Belanja': Icons.shopping_bag_rounded,
    'Hiburan': Icons.sports_esports_rounded,
    'Kesehatan': Icons.favorite_rounded,
  };

  final List<String> _resetDateOptions = [
    'Tanggal 1',
    'Tanggal 15',
    'Tanggal 25',
    'Custom',
  ];

  Future<void> _saveProfileAndContinue() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();

    // Simpan nama, default "Pengguna" kalau kosong
    final name = _nameController.text.trim().isEmpty
        ? 'Pengguna'
        : _nameController.text.trim();

    await prefs.setString('user_name', name);
    await prefs.setString('currency', _selectedCurrency);
    await prefs.setString('reset_date', _selectedResetDate);
    await prefs.setBool('is_setup_complete', true);

    // Simpan budget per kategori LANGSUNG KE DATABASE
    // (bukan cuma SharedPreferences) supaya tersambung ke
    // BudgetProvider, Dashboard, dan Analytics
    final budgetProvider = context.read<BudgetProvider>();
    await budgetProvider.loadBudgets(); // pastikan data terbaru

    for (var entry in _budgetControllers.entries) {
      final value = double.tryParse(entry.value.text) ?? 0;
      if (value <= 0) continue; // skip kategori yang dikosongkan

      // Cek apakah budget kategori ini sudah ada di database
      final existing = budgetProvider.budgets
          .where((b) => b.category == entry.key)
          .toList();

      if (existing.isNotEmpty && existing.first.id != null) {
        // Sudah ada -> update limit-nya
        await budgetProvider.editBudgetLimit(existing.first.id!, value);
      } else {
        // Belum ada -> buat budget baru
        final newBudget = BudgetModel(
          category: entry.key,
          categoryIcon: entry.key,
          monthlyLimit: value,
        );
        await budgetProvider.addBudget(newBudget);
      }
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var c in _budgetControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SETUP PROFILE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Hai, kenalan dulu yuk!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Nama
              _buildLabel('Nama panggilanmu'),
              _buildTextField(
                controller: _nameController,
                hint: 'contoh: Rafi',
              ),
              const SizedBox(height: 16),

              // Mata Uang
              _buildLabel('Mata uang'),
              _buildDropdown(),
              const SizedBox(height: 24),

              // Budget Section
              const Text(
                'Budget bulanan per kategori',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Boleh dikosongkan, bisa diisi nanti di Settings',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 12),

              ..._budgetControllers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildBudgetRow(entry.key, entry.value),
                );
              }),

              const SizedBox(height: 12),

              // Tanggal Reset Budget
              const Text(
                'Tanggal reset budget',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _resetDateOptions.map((option) {
                  final isSelected = _selectedResetDate == option;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedResetDate = option);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryLight
                            : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primaryDark
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Tombol Mulai
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfileAndContinue,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Mulai pakai Spendly'),
                ),
              ),
              const SizedBox(height: 12),

              // Lewati
              Center(
                child: TextButton(
                  onPressed: _isSaving ? null : _saveProfileAndContinue,
                  child: Text(
                    'Lewati, isi nanti →',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCurrency,
          isExpanded: true,
          dropdownColor: AppColors.cardBackground,
          style: const TextStyle(color: Colors.white),
          items: ['Rupiah (Rp)', 'US Dollar (\$)', 'Euro (€)']
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCurrency = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildBudgetRow(String category, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
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
            child: Icon(
              _categoryIcons[category],
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              category,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
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
            ),
          ),
        ],
      ),
    );
  }
}