import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'setup_profile_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.receipt_long_rounded,
      title: 'Catat Semua Pengeluaranmu',
      subtitle:
          'Tambah transaksi dalam hitungan detik.\nLengkap dengan kategori, mood, dan foto struk.',
      bgColor: AppColors.primaryLight,
    ),
    _OnboardingData(
      icon: Icons.bar_chart_rounded,
      title: 'Pantau Budget & Kebiasaanmu',
      subtitle:
          'Lihat grafik pengeluaran mingguanmu.\nTemukan kapan kamu paling boros.',
      bgColor: const Color(0xFFEDE9FF),
    ),
    _OnboardingData(
      icon: Icons.flag_rounded,
      title: 'Wujudkan Target Tabunganmu',
      subtitle:
          'Set target tabunganmu dan pantau progressnya.\nSpendly bantu hitung berapa yang harus kamu sisihkan tiap hari.',
      bgColor: const Color(0xFFFFF3E0),
    ),
  ];

  void _goToSetupProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SetupProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Tombol Lewati
            if (_currentPage < _pages.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _goToSetupProfile,
                    child: Text(
                      'Lewati',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 56),

            // PageView untuk slide
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _OnboardingPage(data: _pages[index]);
                },
              ),
            ),

            // Dot Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.textTertiary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Bawah
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    } else {
                      _goToSetupProfile();
                    }
                  },
                  child: Text(
                    _currentPage < _pages.length - 1
                        ? 'Selanjutnya →'
                        : 'Mulai Sekarang',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color bgColor;

  _OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bgColor,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration Box
          Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              color: data.bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Icon(
                data.icon,
                size: 80,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}