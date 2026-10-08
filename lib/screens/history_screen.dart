import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsProvider(kPatientId));

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Historique des alertes')),
      body: alertsAsync.when(
        data: (list) {
          // Si Firebase vide, utiliser données de démo
          final items = list.isEmpty ? AlertEvent.demoList() : list;
          return items.isEmpty
              ? const _Empty()
              : _List(alerts: items);
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
        error: (_, __) => _List(alerts: AlertEvent.demoList()),
      ),
    );
  }
}

class _List extends StatelessWidget {
  final List<AlertEvent> alerts;
  const _List({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _Item(alert: alerts[i]),
    );
  }
}

class _Item extends StatelessWidget {
  final AlertEvent alert;
  const _Item({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alert.resolved ? AppTheme.border : _color.withOpacity(0.4)),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: _color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(_icon, style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(alert.message,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
          const SizedBox(height: 3),
          Text(DateFormat('dd/MM/yyyy • HH:mm').format(alert.timestamp),
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontFamily: 'monospace')),
        ])),
        const SizedBox(width: 8),
        _Badge(resolved: alert.resolved),
      ]),
    );
  }

  String get _icon {
    switch (alert.type) {
      case AlertType.sos:       return '🆘';
      case AlertType.battery:   return '🔋';
      case AlertType.removed:   return '⌚';
      case AlertType.outOfZone: return '📍';
      default:                  return '⚠️';
    }
  }

  Color get _color {
    switch (alert.type) {
      case AlertType.battery:   return AppTheme.warn;
      default:                  return AppTheme.danger;
    }
  }
}

class _Badge extends StatelessWidget {
  final bool resolved;
  const _Badge({required this.resolved});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
      color: (resolved ? AppTheme.accent : AppTheme.danger).withOpacity(0.1),
      borderRadius: BorderRadius.circular(20)),
    child: Text(
      resolved ? 'Résolu' : 'Actif',
      style: TextStyle(
        fontSize: 10, fontWeight: FontWeight.w600,
        color: resolved ? AppTheme.accent : AppTheme.danger),
    ),
  );
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) => const Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text('✅', style: TextStyle(fontSize: 52)),
      SizedBox(height: 16),
      Text('Aucune alerte',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      SizedBox(height: 6),
      Text('Tout va bien pour le moment',
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
    ],
  ));
}
