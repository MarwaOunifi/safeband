import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});
  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapCtrl;
  Set<Circle>  _circles = {};
  Set<Marker>  _markers = {};

  @override
  Widget build(BuildContext context) {
    final braceletAsync = ref.watch(braceletStatusProvider(kBraceletId));
    final patientAsync  = ref.watch(patientProvider(kPatientId));

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Localisation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_outlined),
            tooltip: 'Centrer',
            onPressed: () => _center(braceletAsync.value),
          ),
        ],
      ),
      body: Column(children: [
        // Status chips
        braceletAsync.when(
          data:    (s) => _StatusBar(status: s),
          loading: () => const SizedBox(height: 52),
          error:   (_, __) => const SizedBox.shrink(),
        ),

        // Map
        Expanded(child: braceletAsync.when(
          data: (status) {
            patientAsync.whenData((p) => _build(status, p));
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(status.latitude, status.longitude), zoom: 16),
              onMapCreated: (c) { _mapCtrl = c; },
              circles: _circles,
              markers: _markers,
              myLocationEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              style: _kStyle,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
          error:   (e, _) => Center(child: Text('Erreur GPS\n$e',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.danger))),
        )),

        // Bottom coords
        braceletAsync.when(
          data:    (s) => _BottomBar(status: s),
          loading: () => const SizedBox(height: 72),
          error:   (_, __) => const SizedBox.shrink(),
        ),
      ]),
    );
  }

  void _build(BraceletStatus status, Patient patient) {
    final patPos  = LatLng(status.latitude, status.longitude);
    final homePos = LatLng(patient.safeZone.latitude, patient.safeZone.longitude);
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('patient'),
          position: patPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            status.isInZone ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: patient.name,
            snippet: status.isInZone ? ' Dans la zone' : ' Hors zone'),
        ),
        Marker(
          markerId: const MarkerId('home'),
          position: homePos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: '🏠 Domicile'),
        ),
      };
      _circles = {
        Circle(
          circleId: const CircleId('zone'),
          center: homePos,
          radius: patient.safeZone.radiusMeters,
          fillColor: const Color(0x153DD68C),
          strokeColor: const Color(0xFF3DD68C),
          strokeWidth: 2,
        ),
      };
    });
  }

  void _center(BraceletStatus? s) {
    if (s == null || _mapCtrl == null) return;
    _mapCtrl!.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(s.latitude, s.longitude), zoom: 17)));
  }

  static const String _kStyle = '''[
    {"elementType":"geometry","stylers":[{"color":"#0d1117"}]},
    {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#8b949e"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#0d1117"}]},
    {"featureType":"road","elementType":"geometry","stylers":[{"color":"#1c2330"}]},
    {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#30363d"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0d2030"}]},
    {"featureType":"poi","stylers":[{"visibility":"off"}]}
  ]''';
}

class _StatusBar extends StatelessWidget {
  final BraceletStatus status;
  const _StatusBar({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border))),
      child: Row(children: [
        _Chip(
          label: status.isInZone ? 'Dans la zone' : 'Hors zone',
          icon:  status.isInZone ? '✅' : '⚠️',
          color: status.isInZone ? AppTheme.accent : AppTheme.danger),
        const SizedBox(width: 8),
        _Chip(label: '${status.gpsSignal} sat.', icon: '📡', color: AppTheme.accent2),
        const SizedBox(width: 8),
        _Chip(
          label: '${status.batteryPercent.round()}%',
          icon: '🔋',
          color: status.batteryPercent <= 20 ? AppTheme.warn : AppTheme.accent),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String icon, label;
  final Color color;
  const _Chip({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(icon, style: const TextStyle(fontSize: 12)),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _BottomBar extends StatelessWidget {
  final BraceletStatus status;
  const _BottomBar({required this.status});

  String _ago(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'À l\'instant';
    if (d.inMinutes < 60) return 'Il y a ${d.inMinutes} min';
    return 'Il y a ${d.inHours}h';
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: AppTheme.surface,
      border: Border(top: BorderSide(color: AppTheme.border))),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Dernière position', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        const SizedBox(height: 2),
        Text('${status.latitude.toStringAsFixed(5)}, ${status.longitude.toStringAsFixed(5)}',
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppTheme.accent2)),
        const SizedBox(height: 2),
        Text('Sync: ${_ago(status.lastSync)}',
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
      ])),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.accent.withOpacity(0.3))),
        child: const Text('📍', style: TextStyle(fontSize: 22)),
      ),
    ]),
  );
}
