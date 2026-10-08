import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ── Inscription ──
  Future<AppUser> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password,
      );
      await cred.user?.updateDisplayName(displayName);

      final user = AppUser(
        uid: cred.user!.uid,
        email: email,
        displayName: displayName,
      );
      await _db.collection('users').doc(cred.user!.uid).set(user.toMap());
      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  // ── Connexion ──
  Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password,
      );
      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      return doc.exists ? AppUser.fromFirestore(doc) : null;
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  // ── Reset password ──
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── Déconnexion ──
  Future<void> logout() async => _auth.signOut();

  // ── Profil utilisateur ──
  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? AppUser.fromFirestore(doc) : null;
  }

  // ── Update FCM token ──
  Future<void> updateFcmToken(String uid, String token) async {
    await _db.collection('users').doc(uid).update({'fcmToken': token});
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':      return 'Aucun compte trouvé avec cet email.';
      case 'wrong-password':      return 'Mot de passe incorrect.';
      case 'email-already-in-use':return 'Cet email est déjà utilisé.';
      case 'weak-password':       return 'Mot de passe trop faible (min. 6 caractères).';
      case 'invalid-email':       return 'Adresse email invalide.';
      case 'too-many-requests':   return 'Trop de tentatives. Réessayez plus tard.';
      case 'network-request-failed': return 'Erreur réseau. Vérifiez votre connexion.';
      default: return e.message ?? 'Une erreur est survenue.';
    }
  }
}
