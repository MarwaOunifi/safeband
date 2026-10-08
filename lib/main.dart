import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/bracelet_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['PRIVATE_KEY']!,
        authDomain: 'safeband-f7c93.firebaseapp.com',
        databaseURL: 'https://safeband-f7c93-default-rtdb.europe-west1.firebasedatabase.app',
        projectId: 'safeband-f7c93',
        storageBucket: 'safeband-f7c93.firebasestorage.app',
        messagingSenderId: '756199776641',
        appId: '1:756199776641:web:34ecd9a101b4db8e9e4880',
        measurementId: 'G-1K7BPCMMDC',
      ),
    );
    await BraceletService().seedDemo();
  } catch (e) {
    print(" Firebase déjà initialisé");
    debugPrint('seedDemo: $e');
  }

  runApp(const ProviderScope(child: SafeBandApp()));
}
class SafeBandApp extends StatelessWidget {
  const SafeBandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeBand',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
