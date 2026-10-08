import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class AlertBannerWidget extends StatefulWidget {
  final String icon;
  final String title;
  final String subtitle;
  final AlertType type;

  const AlertBannerWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.type,
  });

  @override
  State<AlertBannerWidget> createState() => _AlertBannerWidgetState();
}

class _AlertBannerWidgetState extends State<AlertBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.3), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _dismiss() {
    _ctrl.reverse().then((_) {
      if (mounted) setState(() => _dismissed = true);
    });
  }

  Color get _color {
    switch (widget.type) {
      case AlertType.battery:   return AppTheme.warn;
      case AlertType.sos:       return AppTheme.danger;
      case AlertType.removed:   return AppTheme.danger;
      case AlertType.outOfZone: return AppTheme.danger;
      default:                  return AppTheme.accent2;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _color.withOpacity(0.35)),
            ),
            child: Row(children: [
              Text(widget.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.title, style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: _color)),
                const SizedBox(height: 1),
                Text(widget.subtitle, style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
              ])),
              GestureDetector(
                onTap: _dismiss,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close, color: _color.withOpacity(0.7), size: 16),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
