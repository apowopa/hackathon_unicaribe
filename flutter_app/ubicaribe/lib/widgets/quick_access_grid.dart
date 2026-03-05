import 'package:flutter/material.dart';
import 'package:ubicaribe/theme/app_colors.dart';

class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key});

  static const _items = [
    {'icon': Icons.apartment, 'label': 'Edificios'},
    {'icon': Icons.people, 'label': 'Directorio'},
    {'icon': Icons.access_time, 'label': 'Horarios'},
    {'icon': Icons.chat_bubble_outline, 'label': 'Avisos'},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      children: _items.map((item) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item['icon'] as IconData, color: AppColors.lightBlue, size: 40),
              const SizedBox(height: 10),
              Text(
                item['label'] as String,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
