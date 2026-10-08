import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/models.dart';

class BraceletService {
  final _db   = FirebaseFirestore.instance;
  final _rtdb = FirebaseDatabase.instance;
  BraceletStatus? _lastStatus;  // ← nom corrigé

  Stream<BraceletStatus> watchBracelet(String id) {
    return _rtdb.ref('bracelets/$id').onValue.map((e) {
      final raw  = e.snapshot.value;
      final data = raw != null
          ? Map<String, dynamic>.from(raw as Map)
          : <String, dynamic>{};
      final s = BraceletStatus.fromMap(data);
      _lastStatus = s;  // ← nom corrigé
      return s;
    });
  }

  Stream<Patient> watchPatient(String id) {
    return _db.collection('patients').doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return Patient.demoPatient();  // ← méthode corrigée
      }
      return Patient.fromFirestore(doc);
    });
  }

  Stream<List<AlertEvent>> watchAlerts(String patientId) =>
      _db.collection('patients').doc(patientId).collection('alerts')
         .orderBy('timestamp', descending: true).limit(50)
         .snapshots().map((s) => s.docs.map(AlertEvent.fromFirestore).toList());

  Future<void> triggerSOS(String braceletId, String patientId) async {
    await _rtdb.ref('bracelets/$braceletId/sos').set(true);
    await _db.collection('patients').doc(patientId).collection('alerts').add({
      'type': AlertType.sos.name,
      'message': 'Alerte SOS déclenchée',
      'timestamp': FieldValue.serverTimestamp(),
      'resolved': false,
    });
  }

  Future<void> cancelSOS(String braceletId) async =>
      _rtdb.ref('bracelets/$braceletId/sos').set(false);

  Future<void> resolveAlert(String patientId, String alertId) async =>
      _db.collection('patients').doc(patientId)
         .collection('alerts').doc(alertId).update({'resolved': true});

  Future<void> seedDemo() async {
    final patient = Patient.demoPatient();  // ← méthode corrigée
    await _db.collection('patients').doc('patient_001').set(patient.toMap());
    await _rtdb.ref('bracelets/bracelet_SB0042').set({
      'battery': 85,
      'worn': true,
      'inZone': true,
      'lat': 36.8065,
      'lng': 10.1815,
      'gpsSignal': 4,
      'sos': false,
      'lastSync': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
