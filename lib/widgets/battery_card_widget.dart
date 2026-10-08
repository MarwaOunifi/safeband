import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class BatteryCardWidget extends StatelessWidget {
  final BraceletStatus status;
  const BatteryCardWidget({super.key, required this.status});

  Color get _color {
    switch (status.batteryLevel) {
      case BatteryLevel.critical: return AppTheme.danger;
      case BatteryLevel.low:      return AppTheme.warn;
      case BatteryLevel.ok:       return AppTheme.accent;
    }
  }

  String get _subtitle {
    final h = (status.batteryPercent / 5).round();
    return '≈ ${h}h restantes';
  }

  @override
  Widget build(BuildContext context) {
    final pct = status.batteryPercent;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('BATTERIE', style: TextStyle(
              fontSize: 10, color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500, letterSpacing: 0.5)),
          _BatteryIcon(level: status.batteryLevel),
        ]),
        const SizedBox(height: 10),
        Text('${pct.round()}%', style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w700,
            color: _color, letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text(_subtitle, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
        const SizedBox(height: 8),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: pct / 100,
            backgroundColor: AppTheme.border,
            valueColor: AlwaysStoppedAnimation<Color>(_color),
            minHeight: 4,
          ),
        ),
      ]),
    );
  }
}

class _BatteryIcon extends StatelessWidget {
  final BatteryLevel level;
  const _BatteryIcon({required this.level});

  @override
  Widget build(BuildContext context) {
    final icon = level == BatteryLevel.ok
        ? Icons.battery_full
        : level == BatteryLevel.low
            ? Icons.battery_3_bar
            : Icons.battery_1_bar;
    final color = level == BatteryLevel.ok
        ? AppTheme.accent
        : level == BatteryLevel.low
            ? AppTheme.warn
            : AppTheme.danger;
    return Icon(icon, color: color, size: 20);
  }
}
