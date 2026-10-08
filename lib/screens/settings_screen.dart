import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/providers.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool notifSOS     = true;
  bool notifBattery = true;
  bool notifZone    = true;
  bool notifRemoved = true;
  double battThreshold = 20;
  double geoRadius     = 200;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Patient ──
          const _SectionHeader('Patient'),
          _Row(icon: '👴', iconBg: AppTheme.accent2.withOpacity(0.12),
            label: 'Mohamed Karim', subtitle: '72 ans • Bracelet #SB-0042',
            trailing: _chip('Actif', AppTheme.accent), onTap: () {}),

          const SizedBox(height: 16),
          const _SectionHeader('Alertes & seuils'),

          // Battery threshold slider
          _SliderRow(
            icon: '🔋', iconBg: AppTheme.warn.withOpacity(0.12),
            label: 'Seuil batterie faible',
            value: battThreshold, min: 10, max: 40, unit: '%',
            onChanged: (v) => setState(() => battThreshold = v),
          ),

          // Geo radius slider
          _SliderRow(
            icon: '🗺️', iconBg: AppTheme.accent2.withOpacity(0.12),
            label: 'Rayon zone de sécurité',
            value: geoRadius, min: 50, max: 500, unit: ' m',
            onChanged: (v) => setState(() => geoRadius = v),
          ),

          _Row(icon: '📡', iconBg: AppTheme.accent.withOpacity(0.1),
            label: 'Fréquence GPS', subtitle: 'Mise à jour de la position',
            trailing: _chip('30 sec', AppTheme.accent2), onTap: () {}),

          const SizedBox(height: 16),
          const _SectionHeader('Notifications push'),

          _Toggle(icon: '🆘', iconBg: AppTheme.danger.withOpacity(0.1),
            label: 'Alertes SOS', subtitle: 'Notification critique immédiate',
            value: notifSOS, onChanged: (v) => setState(() => notifSOS = v)),
          _Toggle(icon: '🔋', iconBg: AppTheme.warn.withOpacity(0.1),
            label: 'Batterie faible', subtitle: 'Alerte chargement requis',
            value: notifBattery, onChanged: (v) => setState(() => notifBattery = v)),
          _Toggle(icon: '📍', iconBg: AppTheme.warn.withOpacity(0.1),
            label: 'Sortie de zone', subtitle: 'Alerte géofence',
            value: notifZone, onChanged: (v) => setState(() => notifZone = v)),
          _Toggle(icon: '⌚', iconBg: AppTheme.danger.withOpacity(0.1),
            label: 'Bracelet retiré', subtitle: 'Alerte port du bracelet',
            value: notifRemoved, onChanged: (v) => setState(() => notifRemoved = v)),

          const SizedBox(height: 16),
          const _SectionHeader('Contacts d\'urgence'),

          _Row(icon: '👩', iconBg: AppTheme.accent.withOpacity(0.1),
            label: 'Fatma Karim', subtitle: 'Fille • +216 71 234 567',
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              _chip('Contact 1', AppTheme.accent),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _call('+21671234567'),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.call, color: AppTheme.accent, size: 16),
                ),
              ),
            ]),
            onTap: () {}),

          _Row(icon: '👨‍⚕️', iconBg: AppTheme.accent.withOpacity(0.1),
            label: 'Dr. Ben Salem', subtitle: 'Médecin • +216 98 765 432',
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              _chip('Contact 2', AppTheme.accent),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _call('+21698765432'),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.call, color: AppTheme.accent, size: 16),
                ),
              ),
            ]),
            onTap: () {}),

          _Row(icon: '🚑', iconBg: AppTheme.danger.withOpacity(0.1),
            label: 'SAMU', subtitle: 'Urgences médicales',
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              _chip('190', AppTheme.danger),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _call('190'),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppTheme.danger.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.call, color: AppTheme.danger, size: 16),
                ),
              ),
            ]),
            onTap: () {}),

          const SizedBox(height: 16),
          const _SectionHeader('Compte'),

          _Row(icon: '👤', iconBg: AppTheme.accent2.withOpacity(0.1),
            label: 'Mon profil', subtitle: 'Modifier mes informations',
            trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
            onTap: () {}),

          const SizedBox(height: 8),
          _LogoutButton(onTap: () => _logout(context)),

          const SizedBox(height: 24),
          const Center(child: Text('SafeBand v1.0.0',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 11))),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
  );

  void _call(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  void _logout(BuildContext ctx) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Déconnexion'),
      content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?',
        style: TextStyle(color: AppTheme.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
          child: const Text('Annuler', style: TextStyle(color: AppTheme.textSecondary))),
        TextButton(
          onPressed: () async {
            await AuthService().logout();
            if (ctx.mounted) {
              Navigator.of(ctx).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false);
            }
          },
          child: const Text('Déconnecter', style: TextStyle(color: AppTheme.danger))),
      ],
    ));
  }
}

// ── Widgets helpers ──
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title.toUpperCase(), style: const TextStyle(
      fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.8)),
  );
}

class _Row extends StatelessWidget {
  final String icon; final Color iconBg; final String label, subtitle;
  final Widget? trailing; final VoidCallback onTap;
  const _Row({required this.icon, required this.iconBg, required this.label,
    required this.subtitle, this.trailing, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      onTap: onTap,
      tileColor: AppTheme.surface2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.border)),
      leading: Container(width: 36, height: 36,
        decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(9)),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 17)))),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      trailing: trailing,
    ),
  );
}

class _Toggle extends StatelessWidget {
  final String icon; final Color iconBg; final String label, subtitle;
  final bool value; final ValueChanged<bool> onChanged;
  const _Toggle({required this.icon, required this.iconBg, required this.label,
    required this.subtitle, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      tileColor: AppTheme.surface2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.border)),
      leading: Container(width: 36, height: 36,
        decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(9)),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 17)))),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      trailing: Switch(value: value, onChanged: onChanged, activeColor: AppTheme.accent),
    ),
  );
}

class _SliderRow extends StatelessWidget {
  final String icon; final Color iconBg; final String label, unit;
  final double value, min, max; final ValueChanged<double> onChanged;
  const _SliderRow({required this.icon, required this.iconBg, required this.label,
    required this.value, required this.min, required this.max, required this.unit, required this.onChanged});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(color: AppTheme.surface2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(9)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 17)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            Text('${value.round()}$unit', style: const TextStyle(color: AppTheme.accent2, fontSize: 12, fontFamily: 'monospace')),
          ]),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.accent, inactiveTrackColor: AppTheme.border,
              thumbColor: AppTheme.accent, overlayColor: AppTheme.accent.withOpacity(0.1),
              trackHeight: 3, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(value: value, min: min, max: max, onChanged: onChanged),
          ),
        ])),
      ]),
    ),
  );
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    tileColor: AppTheme.surface2,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: AppTheme.danger.withOpacity(0.3))),
    leading: Container(width: 36, height: 36,
      decoration: BoxDecoration(color: AppTheme.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
      child: const Icon(Icons.logout, color: AppTheme.danger, size: 18)),
    title: const Text('Se déconnecter',
      style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w600, fontSize: 14)),
  );
}
