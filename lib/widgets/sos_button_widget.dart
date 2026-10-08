import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../providers/providers.dart';
import '../services/bracelet_service.dart';
import '../theme/app_theme.dart';

class SOSButtonWidget extends ConsumerStatefulWidget {
  final String patientId;
  final String braceletId;

  const SOSButtonWidget({
    super.key,
    required this.patientId,
    required this.braceletId,
  });

  @override
  ConsumerState<SOSButtonWidget> createState() => _SOSButtonWidgetState();
}

class _SOSButtonWidgetState extends ConsumerState<SOSButtonWidget>
    with TickerProviderStateMixin {
  // Animations
  late AnimationController _pulseCtrl;
  late AnimationController _shakeCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _shakeAnim;

  // State
  _SOSState _state = _SOSState.idle;
  int _countdown = 3;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(_shakeCtrl);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  // ── Tap SOS ──
  void _onTap() {
    HapticFeedback.heavyImpact();
    setState(() {
      _state = _SOSState.countdown;
      _countdown = 3;
    });
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || _state != _SOSState.countdown) return;
      setState(() => _countdown = 2);
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted || _state != _SOSState.countdown) return;
        setState(() => _countdown = 1);
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted || _state != _SOSState.countdown) return;
          _sendSOS();
        });
      });
    });
  }
 
 
  void _cancel() {
    HapticFeedback.mediumImpact();
    setState(() => _state = _SOSState.idle);
    ref.read(sosActiveProvider.notifier).state = false;
  }

  Future<void> _sendSOS() async {
    HapticFeedback.vibrate();
    setState(() => _state = _SOSState.sent);
    ref.read(sosActiveProvider.notifier).state = true;
    try {
      await BraceletService().triggerSOS(widget.braceletId, widget.patientId);
    } catch (_) {}
    // Retour à idle après 6s
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() => _state = _SOSState.idle);
        ref.read(sosActiveProvider.notifier).state = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case _SOSState.idle:      return _buildIdle();
      case _SOSState.countdown: return _buildCountdown();
      case _SOSState.sent:      return _buildSent();
    }
  }

  // ── IDLE button ──
  Widget _buildIdle() {
    return Column(children: [
      AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, child) {
          final p = (math.sin(_pulseAnim.value * math.pi) + 1) / 2;
          return Stack(alignment: Alignment.center, children: [
            // Outer ring
            Container(
              width: 130 + p * 16,
              height: 130 + p * 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.danger.withOpacity(0.04 + p * 0.04),
              ),
            ),
            // Middle ring
            Container(
              width: 112 + p * 8,
              height: 112 + p * 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.danger.withOpacity(0.06 + p * 0.05),
              ),
            ),
            // Button
            child!,
          ]);
        },
        child: GestureDetector(
          onTap: _onTap,
          child: Container(
            width: 96, height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFFF7070), AppTheme.danger, Color(0xFFC0392B)],
                center: Alignment(-0.3, -0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.danger.withOpacity(0.55),
                  blurRadius: 24, spreadRadius: 2,
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('SOS', style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800,
                  color: Colors.white, letterSpacing: 2)),
              SizedBox(height: 2),
              Text('URGENCE', style: TextStyle(
                  fontSize: 8, color: Colors.white70, letterSpacing: 2)),
            ]),
          ),
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        'Appuyez pour déclencher une alerte d\'urgence',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
      ),
    ]);
  }

  // ── COUNTDOWN ──
  Widget _buildCountdown() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.danger.withOpacity(0.4)),
      ),
      child: Column(children: [
        const Text('⚠️  Alerte SOS dans...',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.danger)),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: Text(
            '$_countdown',
            key: ValueKey(_countdown),
            style: const TextStyle(
              fontSize: 72, fontWeight: FontWeight.w800,
              color: AppTheme.danger, letterSpacing: -2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _cancel,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.danger),
              foregroundColor: AppTheme.danger,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('✕  Annuler', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }

  // ── SENT ──
  Widget _buildSent() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.danger.withOpacity(0.5)),
      ),
      child: Column(children: [
        const Text('🆘', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        const Text('ALERTE SOS ENVOYÉE',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
              color: AppTheme.danger, letterSpacing: 1)),
        const SizedBox(height: 8),
        const Text(
          'Les secours ont été contactés.\nVotre localisation est transmise en temps réel.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 16),
        _PulsingDot(),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _cancel,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.danger.withOpacity(0.5)),
              foregroundColor: AppTheme.textSecondary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Annuler l\'alerte',
                style: TextStyle(fontSize: 13)),
          ),
        ),
      ]),
    );
  }
}

enum _SOSState { idle, countdown, sent }

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) {
      final t = _ctrl.value;
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _dot(t, 0),
        const SizedBox(width: 6),
        _dot(t, 0.2),
        const SizedBox(width: 6),
        _dot(t, 0.4),
      ]);
    },
  );

  Widget _dot(double t, double offset) {
    final v = math.sin((t - offset) * math.pi * 2).clamp(0.0, 1.0);
    return Opacity(
      opacity: 0.3 + v * 0.7,
      child: Container(
        width: 8, height: 8,
        decoration: const BoxDecoration(
            color: AppTheme.danger, shape: BoxShape.circle),
      ),
    );
  }
}

// ignore: non_constant_identifier_names
double math_sin_clamp(double v) => (math.sin(v * math.pi * 2)).clamp(0.0, 1.0);
