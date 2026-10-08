import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class PatientHeaderWidget extends StatelessWidget {
  final Patient patient;
  final AsyncValue<BraceletStatus> braceletAsync;

  const PatientHeaderWidget({
    super.key,
    required this.patient,
    required this.braceletAsync,
  });

  @override
  Widget build(BuildContext context) {
    final status = braceletAsync.value;
    final isOk   = status == null || (!status.hasAlert);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOk
              ? [const Color(0xFF1A2535), const Color(0xFF0F1923)]
              : [const Color(0xFF2A1A1A), const Color(0xFF1A0F0F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOk ? AppTheme.border : AppTheme.danger.withOpacity(0.4)),
      ),
      child: Row(children: [
        // Avatar
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF2D4A3E), Color(0xFF1A2D26)]),
            border: Border.all(
              color: isOk ? AppTheme.accent : AppTheme.danger, width: 2),
          ),
          child: const Center(child: Text('👴', style: TextStyle(fontSize: 24))),
        ),
        const SizedBox(width: 14),

        // Info
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(patient.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textPrimary)),
          const SizedBox(height: 2),
          Text('${patient.age} ans • ${patient.braceletId}',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ])),

        // Status badge
        _StatusBadge(status: status),
      ]),
    );
  }
}

class _StatusBadge extends StatefulWidget {
  final BraceletStatus? status;
  const _StatusBadge({required this.status});
  @override
  State<_StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<_StatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final hasAlert = widget.status?.hasAlert ?? false;
    return FadeTransition(
      opacity: hasAlert ? _anim : const AlwaysStoppedAnimation(1.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: hasAlert
              ? AppTheme.danger.withOpacity(0.15)
              : AppTheme.accent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: hasAlert
              ? AppTheme.danger.withOpacity(0.4)
              : AppTheme.accent.withOpacity(0.3)),
        ),
        child: Text(
          hasAlert ? '⚠️ Alerte' : '✅ En sécurité',
          style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: hasAlert ? AppTheme.danger : AppTheme.accent),
        ),
      ),
    );
  }
}
