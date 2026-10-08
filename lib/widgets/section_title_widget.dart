import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SectionTitleWidget extends StatelessWidget {
  final String title;
  final String? badge;

  const SectionTitleWidget({super.key, required this.title, this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary, letterSpacing: 0.8)),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.accent2.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 5, height: 5,
                decoration: const BoxDecoration(
                    color: AppTheme.accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text(badge!, style: const TextStyle(
                  fontSize: 10, color: AppTheme.accent2)),
            ]),
          ),
      ],
    );
  }
}
