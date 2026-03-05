import 'package:flutter/material.dart';
import 'package:ubicaribe/theme/app_colors.dart';

class QuickAccessGrid extends StatelessWidget {
  final void Function(int)? onNavTap;

  const QuickAccessGrid({super.key, this.onNavTap});

  // tabIndex: índice del BottomNav al que navega este ítem (-1 = sin acción aún)
  static const _items = [
    {'icon': Icons.apartment, 'label': 'Edificios', 'tabIndex': 2},
    {'icon': Icons.people, 'label': 'Directorio', 'tabIndex': -1},
    {'icon': Icons.access_time, 'label': 'Horarios', 'tabIndex': -1},
    {'icon': Icons.chat_bubble_outline, 'label': 'Avisos', 'tabIndex': 1},
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
        final tabIndex = item['tabIndex'] as int;
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: tabIndex >= 0 ? () => onNavTap?.call(tabIndex) : null,
          child: Ink(
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
          ),
        );
      }).toList(),
    );
  }
}
