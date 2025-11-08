import 'package:flutter/material.dart';
import 'package:trackerapp/widgets/appearance_widgets/appearance_body.dart';
import 'package:trackerapp/widgets/appearance_widgets/appearance_header.dart';
class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.brightness == Brightness.dark
        ? const Color(0xFF121212)
        : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const AppearanceHeader(),
      body: const AppearanceBody(),
    );
  }
}
