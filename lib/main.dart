import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Wajib ada
import 'package:sipabersih/screens/login_screen.dart';
import 'package:sipabersih/screens/main_navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // MENGHUBUNGKAN KE SERVER SUPABASE
  await Supabase.initialize(
    url: 'https://udppcpqeismzsakcparz.supabase.co', // Ganti dengan Project URL dari Supabase
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkcHBjcHFlaXNtenNha2NwYXJ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM4MTQ1MTAsImV4cCI6MjA4OTM5MDUxMH0.3_4eeQLrCV2XTKcWjGnIiFhCDLOp0WuLaEoh5x3IfCU', // Ganti dengan anon key dari Supabase
  );

  runApp(const SipabersihApp());
}
class SipabersihApp extends StatelessWidget {
  const SipabersihApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIPABERSIH',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // KUNCI: Set Font Poppins secara global untuk seluruh aplikasi
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        colorSchemeSeed: AppColors.primaryDark,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: Supabase.instance.client.auth.currentUser == null
          ? const LoginScreen()
          : const MainNavigation(),
    );
  }
}
