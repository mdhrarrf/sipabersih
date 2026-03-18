import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:sipabersih/viewmodels/map_viewmodel.dart';
import 'package:sipabersih/viewmodels/water_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart'; // Import viewmodel
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: 'https://udppcpqeismzsakcparz.supabase.co', anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkcHBjcHFlaXNtenNha2NwYXJ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM4MTQ1MTAsImV4cCI6MjA4OTM5MDUxMH0.3_4eeQLrCV2XTKcWjGnIiFhCDLOp0WuLaEoh5x3IfCU');

  runApp(
    // Daftarkan semua ViewModel di sini
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(
          create: (_) => WaterViewModel(),
        ), // Tambahkan ini
        ChangeNotifierProvider(create: (_) => MapViewModel()), // TAMBAHKAN INI
      ],
      child: const SipabersihApp(),
    ),
  );
}

class SipabersihApp extends StatelessWidget {
  const SipabersihApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIPABERSIH PRO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // (Theme settings Anda tetap sama)
      ),
      home: Supabase.instance.client.auth.currentUser == null
          ? const LoginScreen()
          : const MainNavigation(),
    );
  }
}
