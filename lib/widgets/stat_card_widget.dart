import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatCardWidget extends StatelessWidget {
  final String label;
  final String icon;
  final String value;
  final String subtitle;
  final Color valueColor;
  final Color? borderColor;

  const StatCardWidget({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.subtitle,
    this.valueColor = AppTheme.accent,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label.toUpperCase(),
            style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500, letterSpacing: 0.5)),
          Text(icon, style: const TextStyle(fontSize: 18)),
        ]),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700, color: valueColor, letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
      ]),
    );
  }
}
