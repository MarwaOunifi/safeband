import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/patient_header_widget.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/battery_card_widget.dart';
import '../widgets/alert_banner_widget.dart';
import '../widgets/sos_button_widget.dart';
import '../widgets/section_title_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final braceletAsync = ref.watch(braceletStatusProvider(kBraceletId));
    final patientAsync  = ref.watch(patientProvider(kPatientId));

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── AppBar ──
            SliverAppBar(
              pinned: true,
              backgroundColor: AppTheme.bg,
              elevation: 0,
              title: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.accent, AppTheme.accent2]),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Center(child: Text('🩺', style: TextStyle(fontSize: 16))),
                ),
                const SizedBox(width: 10),
                RichText(text: const TextSpan(
                  style: TextStyle(fontFamily: 'Sora', fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  children: [
                    TextSpan(text: 'Safe'),
                    TextSpan(text: 'Band', style: TextStyle(color: AppTheme.accent)),
                  ],
                )),
              ]),
              actions: [
                _NotifButton(braceletAsync: braceletAsync),
                const SizedBox(width: 4),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(delegate: SliverChildListDelegate([

                // ── Patient header ──
                patientAsync.when(
                  data: (p) => PatientHeaderWidget(patient: p, braceletAsync: braceletAsync),
                  loading: () => const _Skeleton(height: 82),
                  error: (e, _) => _ErrorCard(message: e.toString()),
                ),
                const SizedBox(height: 16),

                // ── Alert banners ──
                braceletAsync.when(
                  data: (s) => _AlertBanners(status: s),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // ── Stats ──
                const SectionTitleWidget(title: 'État du bracelet', badge: 'En direct'),
                const SizedBox(height: 10),
                braceletAsync.when(
                  data: (s) => _StatsGrid(status: s),
                  loading: () => const _Skeleton(height: 210),
                  error: (e, _) => _ErrorCard(message: e.toString()),
                ),

                const SizedBox(height: 20),

                // ── SOS ──
                const SectionTitleWidget(title: 'Urgence'),
                const SizedBox(height: 12),
                const SOSButtonWidget(patientId: kPatientId, braceletId: kBraceletId),
                const SizedBox(height: 8),
              ])),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Alert banners ──
class _AlertBanners extends StatelessWidget {
  final BraceletStatus status;
  const _AlertBanners({required this.status});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (status.batteryPercent <= 20)
        AlertBannerWidget(
          icon: '🔋', type: AlertType.battery,
          title: 'Batterie faible',
          subtitle: 'Niveau ${status.batteryPercent.round()}% — Rechargez le bracelet',
        ),
      if (!status.isWorn)
        const AlertBannerWidget(
          icon: '⌚', type: AlertType.removed,
          title: 'Bracelet retiré !',
          subtitle: 'Le patient ne porte plus le bracelet',
        ),
      if (!status.isInZone)
        const AlertBannerWidget(
          icon: '📍', type: AlertType.outOfZone,
          title: 'Sortie de zone !',
          subtitle: 'Le patient a quitté la zone de sécurité',
        ),
      if (status.sosTriggered)
        const AlertBannerWidget(
          icon: '🆘', type: AlertType.sos,
          title: 'ALERTE SOS !',
          subtitle: 'Bouton SOS activé — Intervention requise',
        ),
    ]);
  }
}

// ── Stats grid ──
class _StatsGrid extends StatelessWidget {
  final BraceletStatus status;
  const _StatsGrid({required this.status});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(child: BatteryCardWidget(status: status)),
        const SizedBox(width: 10),
        Expanded(child: StatCardWidget(
          label: 'Port', icon: '⌚',
          value: status.isWorn ? 'Porté' : 'Retiré',
          subtitle: status.isWorn ? 'Depuis 6h12' : 'Alerte active',
          valueColor: status.isWorn ? AppTheme.accent : AppTheme.danger,
          borderColor: status.isWorn ? AppTheme.accent.withOpacity(0.2) : AppTheme.danger.withOpacity(0.3),
        )),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: StatCardWidget(
          label: 'Signal GPS', icon: '📡',
          value: _gpsLabel(status.gpsSignal),
          subtitle: '${status.gpsSignal} satellites',
          valueColor: AppTheme.accent,
        )),
        const SizedBox(width: 10),
        Expanded(child: StatCardWidget(
          label: 'Zone', icon: '🗺️',
          value: status.isInZone ? 'Dans zone' : 'Hors zone',
          subtitle: status.isInZone ? 'Périmètre OK' : '⚠️ Alerte',
          valueColor: status.isInZone ? AppTheme.accent : AppTheme.danger,
          borderColor: status.isInZone ? AppTheme.accent.withOpacity(0.2) : AppTheme.danger.withOpacity(0.3),
        )),
      ]),
    ]);
  }

  String _gpsLabel(int sig) {
    if (sig >= 4) return 'Excellent';
    if (sig >= 2) return 'Bon';
    return 'Faible';
  }
}

// ── Notif button ──
class _NotifButton extends StatelessWidget {
  final AsyncValue<BraceletStatus> braceletAsync;
  const _NotifButton({required this.braceletAsync});

  @override
  Widget build(BuildContext context) {
    final hasAlert = braceletAsync.value?.hasAlert ?? false;
    return Stack(children: [
      IconButton(
        icon: const Icon(Icons.notifications_outlined),
        onPressed: () => _showSheet(context),
      ),
      if (hasAlert)
        Positioned(right: 8, top: 8,
          child: Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(color: AppTheme.danger, shape: BoxShape.circle),
          )),
    ]);
  }

  void _showSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          const Text('Aucune nouvelle notification.',
            style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

// ── Helpers ──
class _Skeleton extends StatelessWidget {
  final double height;
  const _Skeleton({required this.height});
  @override
  Widget build(BuildContext context) => Container(
    height: height, margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      color: AppTheme.surface2,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.border),
    ),
  );
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.danger.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
    ),
    child: Text('Erreur: $message', style: const TextStyle(color: AppTheme.danger, fontSize: 12)),
  );
}
