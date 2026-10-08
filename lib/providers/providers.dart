import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/bracelet_service.dart';

// ── Services ──
final authServiceProvider     = Provider<AuthService>((ref) => AuthService());
final braceletServiceProvider = Provider<BraceletService>((ref) => BraceletService());

// ── Auth ──
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.read(authServiceProvider).authStateChanges,
);

final currentAppUserProvider = FutureProvider<AppUser?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  return ref.read(authServiceProvider).getUserProfile(user.uid);
});

// ── Bracelet (Realtime DB stream) ──
final braceletStatusProvider = StreamProvider.family<BraceletStatus, String>((ref, id) {
  return ref.read(braceletServiceProvider).watchBracelet(id);
});

// ── Patient (Firestore stream) ──
final patientProvider = StreamProvider.family<Patient, String>((ref, id) {
  return ref.read(braceletServiceProvider).watchPatient(id);
});

// ── Alerts history ──
final alertsProvider = StreamProvider.family<List<AlertEvent>, String>((ref, patientId) {
  return ref.read(braceletServiceProvider).watchAlerts(patientId);
});

// ── Navigation tab ──
final selectedTabProvider = StateProvider<int>((ref) => 0);

// ── SOS state ──
final sosActiveProvider = StateProvider<bool>((ref) => false);

// ── Auth form ──
enum AuthStatus { idle, loading, success, error }

class AuthFormState {
  final AuthStatus status;
  final String? errorMessage;
  const AuthFormState({this.status = AuthStatus.idle, this.errorMessage});
  AuthFormState copyWith({AuthStatus? status, String? errorMessage}) =>
      AuthFormState(status: status ?? this.status, errorMessage: errorMessage ?? this.errorMessage);
}

class AuthFormNotifier extends StateNotifier<AuthFormState> {
  AuthFormNotifier(this._svc) : super(const AuthFormState());
  final AuthService _svc;

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _svc.login(email: email, password: password);
      state = state.copyWith(status: AuthStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _svc.register(email: email, password: password, displayName: name);
      state = state.copyWith(status: AuthStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
      return false;
    }
  }

  void reset() => state = const AuthFormState();
}

final authFormProvider = StateNotifierProvider<AuthFormNotifier, AuthFormState>(
  (ref) => AuthFormNotifier(ref.read(authServiceProvider)),
);

// ── Constants (remplacer par valeurs depuis Firestore en production) ──
const String kPatientId  = 'patient_001';
const String kBraceletId = 'bracelet_SB0042';
