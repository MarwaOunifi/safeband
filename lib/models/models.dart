import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid, email, displayName;
  final String? patientId;
  AppUser({required this.uid, required this.email, required this.displayName, this.patientId});
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppUser(uid: doc.id, email: d['email'] ?? '', displayName: d['displayName'] ?? '', patientId: d['patientId']);
  }
  Map<String, dynamic> toMap() => {
    'email': email, 'displayName': displayName,
    if (patientId != null) 'patientId': patientId,
  };
}

class Patient {
  final String id, name, braceletId;
  final int age;
  final List<EmergencyContact> contacts;
  final GeoZone safeZone;

  Patient({
    required this.id, required this.name, required this.age,
    required this.braceletId, required this.contacts, required this.safeZone,
  });

  factory Patient.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Patient(
      id: doc.id,
      name: d['name'] ?? 'Patient',
      age: d['age'] ?? 0,
      braceletId: d['braceletId'] ?? '',
      contacts: (d['contacts'] as List<dynamic>? ?? [])
          .map((c) => EmergencyContact.fromMap(c as Map<String, dynamic>)).toList(),
      safeZone: GeoZone.fromMap(d['safeZone'] as Map<String, dynamic>? ?? {}),
    );
  }

  // ← Renommé en demoPatient() pour éviter le conflit avec demo()
  static Patient demoPatient() => Patient(
    id: 'patient_001',
    name: 'Mohamed Karim',
    age: 72,
    braceletId: 'bracelet_SB0042',
    contacts: [
      EmergencyContact(name: 'Fatma Karim',  phone: '+21671234567', relation: 'Fille'),
      EmergencyContact(name: 'Dr. Ben Salem', phone: '+21698765432', relation: 'Médecin'),
    ],
    safeZone: GeoZone(latitude: 36.8065, longitude: 10.1815, radiusMeters: 200),
  );

  Map<String, dynamic> toMap() => {
    'name': name, 'age': age, 'braceletId': braceletId,
    'contacts': contacts.map((c) => c.toMap()).toList(),
    'safeZone': safeZone.toMap(),
  };
}

class EmergencyContact {
  final String name, phone, relation;
  EmergencyContact({required this.name, required this.phone, required this.relation});
  factory EmergencyContact.fromMap(Map<String, dynamic> m) =>
      EmergencyContact(name: m['name'] ?? '', phone: m['phone'] ?? '', relation: m['relation'] ?? '');
  Map<String, dynamic> toMap() => {'name': name, 'phone': phone, 'relation': relation};
}

class GeoZone {
  final double latitude, longitude, radiusMeters;
  final bool active;
  GeoZone({required this.latitude, required this.longitude, required this.radiusMeters, this.active = true});
  factory GeoZone.fromMap(Map<String, dynamic> m) => GeoZone(
    latitude:  (m['latitude']  ?? 36.8065).toDouble(),
    longitude: (m['longitude'] ?? 10.1815).toDouble(),
    radiusMeters: (m['radiusMeters'] ?? 200).toDouble(),
    active: m['active'] ?? true,
  );
  Map<String, dynamic> toMap() => {
    'latitude': latitude, 'longitude': longitude,
    'radiusMeters': radiusMeters, 'active': active,
  };
}

class BraceletStatus {
  final double batteryPercent;
  final bool isWorn, isInZone, sosTriggered;
  final double latitude, longitude;
  final DateTime lastSync;
  final int gpsSignal;

  const BraceletStatus({
    required this.batteryPercent, required this.isWorn, required this.isInZone,
    required this.latitude, required this.longitude, required this.lastSync,
    required this.gpsSignal, this.sosTriggered = false,
  });

  factory BraceletStatus.fromMap(Map<String, dynamic> m) => BraceletStatus(
    batteryPercent: (m['battery'] ?? 100).toDouble(),
    isWorn:         m['worn']   ?? true,
    isInZone:       m['inZone'] ?? true,
    latitude:  (m['lat'] ?? 36.8065).toDouble(),
    longitude: (m['lng'] ?? 10.1815).toDouble(),
    lastSync: m['lastSync'] != null
        ? DateTime.fromMillisecondsSinceEpoch(m['lastSync'] as int)
        : DateTime.now(),
    gpsSignal:    m['gpsSignal'] ?? 4,
    sosTriggered: m['sos']       ?? false,
  );

  bool get hasAlert => batteryPercent <= 20 || !isWorn || !isInZone || sosTriggered;

  BatteryLevel get batteryLevel {
    if (batteryPercent <= 15) return BatteryLevel.critical;
    if (batteryPercent <= 25) return BatteryLevel.low;
    return BatteryLevel.ok;
  }
}

enum BatteryLevel { ok, low, critical }

class AlertEvent {
  final String id, message;
  final AlertType type;
  final DateTime timestamp;
  final bool resolved;

  AlertEvent({
    required this.id, required this.type,
    required this.message, required this.timestamp,
    this.resolved = false,
  });

  factory AlertEvent.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AlertEvent(
      id: doc.id,
      type: AlertType.values.firstWhere(
          (e) => e.name == d['type'], orElse: () => AlertType.other),
      message:   d['message']   ?? '',
      timestamp: (d['timestamp'] as Timestamp).toDate(),
      resolved:  d['resolved']  ?? false,
    );
  }

  static List<AlertEvent> demoList() => [
    AlertEvent(id: '1', type: AlertType.sos,       message: 'Bouton SOS déclenché',    timestamp: DateTime.now().subtract(const Duration(hours: 2)),  resolved: true),
    AlertEvent(id: '2', type: AlertType.outOfZone, message: 'Sortie de zone détectée', timestamp: DateTime.now().subtract(const Duration(hours: 5)),  resolved: true),
    AlertEvent(id: '3', type: AlertType.battery,   message: 'Batterie faible (18%)',   timestamp: DateTime.now().subtract(const Duration(hours: 7)),  resolved: true),
    AlertEvent(id: '4', type: AlertType.removed,   message: 'Bracelet retiré',         timestamp: DateTime.now().subtract(const Duration(days: 1)),   resolved: true),
  ];
}

enum AlertType { battery, removed, outOfZone, sos, other }
