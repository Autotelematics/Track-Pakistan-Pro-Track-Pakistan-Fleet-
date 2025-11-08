import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackerapp/providers/theme_provider.dart';
import 'theme_option_card.dart';

class AppearanceBody extends StatelessWidget {
  const AppearanceBody({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);

    final themes = [
      {
        'title': 'Light',
        'bg': Colors.white,
        'isDark': false,
        'mode': ThemeMode.light,
      },
      {
        'title': 'Dark',
        'bg': const Color(0xFF1E1E1E),
        'isDark': true,
        'mode': ThemeMode.dark,
      },
      {
        'title': 'System',
        'bg': Colors.grey[200]!,
        'isDark': false,
        'mode': ThemeMode.system,
      },
    ];

    return Column(
      children: [
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(themes.length, (index) {
            final item = themes[index];
            return ThemeOptionCard(
              title: item['title'] as String,
              bgColor: item['bg'] as Color, // ✅ FIX: explicit cast to Color
              isDark: item['isDark'] as bool,
              isSelected: provider.selectedIndex == index,
              onTap: () => provider.setTheme(item['mode'] as ThemeMode, index),
            );
          }),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            "If ‘System’ is selected, the app will automatically adjust its appearance based on your device’s settings.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
