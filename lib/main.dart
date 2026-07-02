import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/supabase_config.dart';
import 'theme/app_theme.dart';

import 'screens/splash/splash_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/home/home_page.dart';
import 'screens/dokter/dokter_page.dart';
import 'screens/reservasi/reservasi_page.dart';
import 'screens/antrian/antrian_page.dart';
import 'screens/profile/profile_page.dart';
import 'screens/notifikasi/notifikasi_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const PoligoApp());
}

class PoligoApp extends StatelessWidget {
  const PoligoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'POLIGO',

      theme: AppTheme.lightTheme,

      initialRoute: '/',

      routes: {
        '/': (context) => const SplashPage(),

        '/login': (context) => const LoginPage(),

        '/register': (context) => const RegisterPage(),

        '/home': (context) => const HomePage(),

        '/dokter': (context) => const DokterPage(),

        '/reservasi': (context) => const ReservasiPage(),

        '/antrian': (context) => const AntrianPage(),

        '/profile': (context) => const ProfilePage(),

        '/notifikasi': (context) => const NotifikasiPage(),
      },
    );
  }
}
