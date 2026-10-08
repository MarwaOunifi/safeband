import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'map_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _pages = <Widget>[
    DashboardScreen(),
    MapScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = ref.watch(selectedTabProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: IndexedStack(index: idx, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: idx,
          onTap: (i) => ref.read(selectedTabProvider.notifier).state = i,
          backgroundColor: AppTheme.surface,
          selectedItemColor: AppTheme.accent,
          unselectedItemColor: AppTheme.textMuted,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Sora', fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined),    activeIcon: Icon(Icons.home_rounded),    label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined),     activeIcon: Icon(Icons.map_rounded),     label: 'Carte'),
            BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history_rounded), label: 'Historique'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined),activeIcon: Icon(Icons.settings_rounded),label: 'Paramètres'),
          ],
        ),
      ),
    );
  }
}
