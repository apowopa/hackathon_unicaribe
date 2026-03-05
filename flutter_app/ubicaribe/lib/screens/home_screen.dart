import 'package:flutter/material.dart';
import 'package:ubicaribe/theme/app_colors.dart';
import 'package:ubicaribe/widgets/custom_header.dart';
import 'package:ubicaribe/widgets/custom_search_bar.dart';
import 'package:ubicaribe/widgets/ar_promo_banner.dart';
import 'package:ubicaribe/widgets/quick_access_grid.dart';
import 'package:ubicaribe/screens/edificios_screen.dart';
import 'package:ubicaribe/screens/avisos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> views = [
      _HomeContent(onNavTap: _onNavTap),
      const AvisosScreen(),
      const EdificiosView(),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: views[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onNavTap,
      backgroundColor: AppColors.backgroundDark,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey.shade500,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Avisos'),
        BottomNavigationBarItem(icon: Icon(Icons.apartment), label: 'Edificios'),
      ],
    );
  }
}

class _HomeContent extends StatelessWidget {
  final void Function(int) onNavTap;

  const _HomeContent({required this.onNavTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const CustomHeader(),
            const SizedBox(height: 20),
            const CustomSearchBar(),
            const SizedBox(height: 20),
            const ArPromoBanner(),
            const SizedBox(height: 24),
            const Text(
              'Accesos rápidos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            QuickAccessGrid(onNavTap: onNavTap),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
