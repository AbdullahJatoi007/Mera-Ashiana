import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HomeLoadingView extends StatelessWidget {
  const HomeLoadingView({super.key, required this.backgroundColor});

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: const Center(
        child: CircularProgressIndicator(color: AppColors.accentYellow),
      ),
    );
  }
}
