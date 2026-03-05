import 'package:flutter/material.dart';
import 'package:ubicaribe/theme/app_colors.dart';
import 'package:ubicaribe/widgets/custom_header.dart';
import 'package:ubicaribe/widgets/custom_search_bar.dart';
import 'package:ubicaribe/widgets/ar_promo_banner.dart';
import 'package:ubicaribe/widgets/quick_access_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 16),
              CustomHeader(),
              SizedBox(height: 20),
              CustomSearchBar(),
              SizedBox(height: 20),
              ArPromoBanner(),
              SizedBox(height: 24),
              Text(
                'Accesos rápidos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              QuickAccessGrid(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
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
