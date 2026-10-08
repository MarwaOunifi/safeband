import 'package:intl/intl.dart';

class Helpers {
  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours   < 24) return 'Il y a ${diff.inHours}h';
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  static String formatDate(DateTime dt) =>
      DateFormat('dd/MM/yyyy • HH:mm').format(dt);

  static String batteryLabel(double pct) {
    if (pct <= 15) return 'Critique';
    if (pct <= 25) return 'Faible';
    if (pct <= 50) return 'Moyen';
    return 'Bon';
  }

  static String gpsLabel(int satellites) {
    if (satellites >= 4) return 'Excellent';
    if (satellites >= 2) return 'Bon';
    if (satellites >= 1) return 'Faible';
    return 'Aucun';
  }
}
